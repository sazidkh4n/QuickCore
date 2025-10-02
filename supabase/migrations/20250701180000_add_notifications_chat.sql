-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type text NOT NULL,
  data jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_read BOOLEAN DEFAULT FALSE
);

-- Create messages table for chat
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  image_url TEXT,
  status SMALLINT DEFAULT 1, -- 0: sending, 1: sent, 2: delivered, 3: read
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create conversations table to track chat threads
CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  other_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  other_user_name TEXT NOT NULL,
  other_user_avatar TEXT,
  last_message TEXT,
  last_message_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  unread_count INTEGER DEFAULT 0,
  is_online BOOLEAN DEFAULT FALSE,
  UNIQUE(user_id, other_user_id)
);

-- Add RLS policies

-- Notifications policies
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications" 
  ON notifications FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "System can insert notifications" 
  ON notifications FOR INSERT 
  WITH CHECK (true);

CREATE POLICY "Users can update their own notifications" 
  ON notifications FOR UPDATE 
  USING (auth.uid() = user_id);

-- Messages policies
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- RLS policies for conversations and messages

-- Policies for conversations
-- CREATE POLICY "Users can view their own conversations"
-- ON conversations FOR SELECT USING (auth.uid() = user_id);

-- CREATE POLICY "Users can create their own conversations"
-- ON conversations FOR INSERT WITH CHECK (auth.uid() = user_id);

-- CREATE POLICY "Users can update their own conversations"
-- ON conversations FOR UPDATE USING (auth.uid() = user_id);

-- CREATE POLICY "Users can delete their own conversations"
-- ON conversations FOR DELETE USING (auth.uid() = user_id);

-- Policies for messages
-- CREATE POLICY "Users can view messages they sent or received"
-- ON messages FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- CREATE POLICY "Users can insert messages into their conversations"
-- ON messages FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- CREATE POLICY "Users can update their own sent messages"
-- ON messages FOR UPDATE USING (auth.uid() = sender_id);

-- Conversations policies
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;

-- CREATE POLICY "Users can view their own conversations" 
--   ON conversations FOR SELECT 
--   USING (auth.uid() = user_id OR auth.uid() = other_user_id);

-- CREATE POLICY "Users can create conversations" 
--   ON conversations FOR INSERT 
--   WITH CHECK (auth.uid() = user_id);

-- CREATE POLICY "Users can update their own conversations" 
--   ON conversations FOR UPDATE 
--   USING (auth.uid() = user_id OR auth.uid() = other_user_id);

-- Create function to update conversation on new message
CREATE OR REPLACE FUNCTION update_conversation_on_message()
RETURNS TRIGGER AS $$
DECLARE
  sender_profile RECORD;
  receiver_profile RECORD;
  conv_id UUID;
  conv_exists BOOLEAN;
BEGIN
  -- Get sender profile
  SELECT username, avatar_url INTO sender_profile 
  FROM profiles WHERE id = NEW.sender_id;
  
  -- Get receiver profile
  SELECT username, avatar_url INTO receiver_profile
  FROM profiles WHERE id = NEW.receiver_id;
  
  -- Check if conversation exists from sender to receiver
  SELECT id, TRUE INTO conv_id, conv_exists
  FROM conversations
  WHERE (user_id = NEW.sender_id AND other_user_id = NEW.receiver_id)
  LIMIT 1;
  
  IF conv_exists THEN
    -- Update existing conversation
    UPDATE conversations
    SET last_message = NEW.message,
        last_message_time = NEW.created_at
    WHERE id = conv_id;
  ELSE
    -- Create new conversation for sender
    INSERT INTO conversations (
      user_id, other_user_id, other_user_name, other_user_avatar, 
      last_message, last_message_time
    ) VALUES (
      NEW.sender_id, NEW.receiver_id, receiver_profile.username, receiver_profile.avatar_url,
      NEW.message, NEW.created_at
    );
  END IF;
  
  -- Check if conversation exists from receiver to sender
  SELECT id, TRUE INTO conv_id, conv_exists
  FROM conversations
  WHERE (user_id = NEW.receiver_id AND other_user_id = NEW.sender_id)
  LIMIT 1;
  
  IF conv_exists THEN
    -- Update existing conversation and increment unread count
    UPDATE conversations
    SET last_message = NEW.message,
        last_message_time = NEW.created_at,
        unread_count = unread_count + 1
    WHERE id = conv_id;
  ELSE
    -- Create new conversation for receiver
    INSERT INTO conversations (
      user_id, other_user_id, other_user_name, other_user_avatar, 
      last_message, last_message_time, unread_count
    ) VALUES (
      NEW.receiver_id, NEW.sender_id, sender_profile.username, sender_profile.avatar_url,
      NEW.message, NEW.created_at, 1
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for message insertion
CREATE TRIGGER on_message_inserted
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE PROCEDURE update_conversation_on_message();

-- Create function to create notification on various events
CREATE OR REPLACE FUNCTION create_notification_on_event()
RETURNS TRIGGER AS $$
DECLARE
  action_user_profile RECORD;
  target_user_id UUID;
  skill_record RECORD;
  notification_data JSONB;
BEGIN
  -- Get action user profile
  SELECT username, avatar_url INTO action_user_profile 
  FROM profiles WHERE id = auth.uid();
  
  -- Different handling based on table
  IF TG_TABLE_NAME = 'likes' THEN
    -- Get skill info and creator
    SELECT id, title, creator_id INTO skill_record
    FROM skills WHERE id = NEW.skill_id;
    
    target_user_id := skill_record.creator_id;
    
    notification_data := jsonb_build_object(
      'skill_id', skill_record.id,
      'skill_title', skill_record.title,
      'action_user_id', auth.uid(),
      'action_user_name', action_user_profile.username,
      'action_user_avatar', action_user_profile.avatar_url,
      'message', action_user_profile.username || ' liked your skill: ' || skill_record.title
    );
    
  ELSIF TG_TABLE_NAME = 'comments' THEN
    -- Get skill info and creator
    SELECT id, title, creator_id INTO skill_record
    FROM skills WHERE id = NEW.skill_id;
    
    target_user_id := skill_record.creator_id;
    
    notification_data := jsonb_build_object(
      'skill_id', skill_record.id,
      'skill_title', skill_record.title,
      'action_user_id', auth.uid(),
      'action_user_name', action_user_profile.username,
      'action_user_avatar', action_user_profile.avatar_url,
      'comment_id', NEW.id,
      'comment_text', NEW.content,
      'message', action_user_profile.username || ' commented on your skill: ' || skill_record.title
    );
    
  ELSIF TG_TABLE_NAME = 'follows' THEN
    target_user_id := NEW.followed_id;
    
    notification_data := jsonb_build_object(
      'action_user_id', auth.uid(),
      'action_user_name', action_user_profile.username,
      'action_user_avatar', action_user_profile.avatar_url,
      'message', action_user_profile.username || ' started following you'
    );
    
  ELSIF TG_TABLE_NAME = 'skills' THEN
    -- This would be for notifying followers about new uploads
    -- Requires a more complex implementation to notify all followers
    RETURN NEW;
  END IF;
  
  -- Don't notify yourself
  IF target_user_id = auth.uid() THEN
    RETURN NEW;
  END IF;
  
  -- Create notification
  INSERT INTO notifications (
    user_id, type, data
  ) VALUES (
    target_user_id, 
    TG_TABLE_NAME, -- 'likes', 'comments', 'follows', etc.
    notification_data
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create triggers for various events
CREATE TRIGGER on_like_inserted
  AFTER INSERT ON likes
  FOR EACH ROW
  EXECUTE PROCEDURE create_notification_on_event();

CREATE TRIGGER on_comment_inserted
  AFTER INSERT ON comments
  FOR EACH ROW
  EXECUTE PROCEDURE create_notification_on_event();

CREATE TRIGGER on_follow_inserted
  AFTER INSERT ON follows
  FOR EACH ROW
  EXECUTE PROCEDURE create_notification_on_event();

-- Enable RLS on all tables if not already enabled
ALTER TABLE IF EXISTS public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.comment_likes ENABLE ROW LEVEL SECURITY;

-- Create policies for likes
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'likes' 
        AND policyname = 'Allow authenticated users to insert likes'
    ) THEN
        CREATE POLICY "Allow authenticated users to insert likes"
        ON public.likes
        FOR INSERT
        TO authenticated
        WITH CHECK (true);
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'likes' 
        AND policyname = 'Allow users to delete their own likes'
    ) THEN
        CREATE POLICY "Allow users to delete their own likes"
        ON public.likes
        FOR DELETE
        TO authenticated
        USING (auth.uid() = user_id);
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'likes' 
        AND policyname = 'Allow users to read all likes'
    ) THEN
        CREATE POLICY "Allow users to read all likes"
        ON public.likes
        FOR SELECT
        TO authenticated
        USING (true);
    END IF;
END
$$;

-- Create policies for comments
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'comments' 
        AND policyname = 'Allow authenticated users to insert comments'
    ) THEN
        CREATE POLICY "Allow authenticated users to insert comments"
        ON public.comments
        FOR INSERT
        TO authenticated
        WITH CHECK (true);
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'comments' 
        AND policyname = 'Allow users to read all comments'
    ) THEN
        CREATE POLICY "Allow users to read all comments"
        ON public.comments
        FOR SELECT
        TO authenticated
        USING (true);
    END IF;
END
$$;

-- Create policies for comment likes
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'comment_likes' 
        AND policyname = 'Allow authenticated users to insert comment likes'
    ) THEN
        CREATE POLICY "Allow authenticated users to insert comment likes"
        ON public.comment_likes
        FOR INSERT
        TO authenticated
        WITH CHECK (true);
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'comment_likes' 
        AND policyname = 'Allow users to delete their own comment likes'
    ) THEN
        CREATE POLICY "Allow users to delete their own comment likes"
        ON public.comment_likes
        FOR DELETE
        TO authenticated
        USING (auth.uid() = user_id);
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'comment_likes' 
        AND policyname = 'Allow users to read all comment likes'
    ) THEN
        CREATE POLICY "Allow users to read all comment likes"
        ON public.comment_likes
        FOR SELECT
        TO authenticated
        USING (true);
    END IF;
END
$$; 