-- Enable RLS policies for conversations table
-- Run this in the Supabase SQL Editor

-- Enable RLS policies for conversations
CREATE POLICY "Users can view their own conversations"
  ON conversations FOR SELECT 
  USING (auth.uid() = user_id OR auth.uid() = other_user_id);

CREATE POLICY "Users can create conversations" 
  ON conversations FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own conversations" 
  ON conversations FOR UPDATE 
  USING (auth.uid() = user_id OR auth.uid() = other_user_id);

CREATE POLICY "Users can delete their own conversations" 
  ON conversations FOR DELETE 
  USING (auth.uid() = user_id OR auth.uid() = other_user_id);

-- Enable RLS policies for messages
CREATE POLICY "Users can view messages they sent or received"
  ON messages FOR SELECT 
  USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can insert messages into their conversations"
  ON messages FOR INSERT 
  WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can update their own sent messages"
  ON messages FOR UPDATE 
  USING (auth.uid() = sender_id);

CREATE POLICY "Users can delete their own sent messages"
  ON messages FOR DELETE 
  USING (auth.uid() = sender_id); 