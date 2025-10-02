-- Comprehensive Database Cleanup and Fix Migration
-- This migration will clean up duplicates, fix conversations, and update the database structure

-- 1. First, let's clean up duplicate conversations
-- Delete duplicate conversations keeping only the most recent one for each user pair
DELETE FROM conversations 
WHERE id IN (
    SELECT c1.id
    FROM conversations c1
    JOIN conversations c2 ON (
        (c1.user_id = c2.user_id AND c1.other_user_id = c2.other_user_id) OR
        (c1.user_id = c2.other_user_id AND c1.other_user_id = c2.user_id)
    )
    WHERE c1.id < c2.id
);

-- 2. Update conversation names with proper user names from profiles
UPDATE conversations 
SET other_user_name = COALESCE(
    (SELECT display_name FROM profiles WHERE id = conversations.other_user_id),
    (SELECT username FROM profiles WHERE id = conversations.other_user_id),
    'Unknown User'
)
WHERE other_user_name IS NULL OR other_user_name = 'User';

-- 3. Sync conversations with latest messages
-- Create a temporary table to store the latest messages for each conversation
CREATE TEMP TABLE latest_messages AS
SELECT 
    CASE 
        WHEN sender_id < receiver_id THEN sender_id 
        ELSE receiver_id 
    END as user1_id,
    CASE 
        WHEN sender_id < receiver_id THEN receiver_id 
        ELSE sender_id 
    END as user2_id,
    message,
    created_at,
    ROW_NUMBER() OVER (
        PARTITION BY 
            CASE WHEN sender_id < receiver_id THEN sender_id ELSE receiver_id END,
            CASE WHEN sender_id < receiver_id THEN receiver_id ELSE sender_id END
        ORDER BY created_at DESC
    ) as rn
FROM messages;

-- Update conversations with the latest messages
UPDATE conversations 
SET 
    last_message = lm.message,
    last_message_time = lm.created_at
FROM latest_messages lm
WHERE 
    conversations.user_id = lm.user1_id AND conversations.other_user_id = lm.user2_id
    AND lm.rn = 1;

UPDATE conversations 
SET 
    last_message = lm.message,
    last_message_time = lm.created_at
FROM latest_messages lm
WHERE 
    conversations.user_id = lm.user2_id AND conversations.other_user_id = lm.user1_id
    AND lm.rn = 1;

-- 4. Clean up orphaned messages (messages without corresponding conversations)
DELETE FROM messages 
WHERE id IN (
    SELECT m.id
    FROM messages m
    LEFT JOIN conversations c ON (
        (m.sender_id = c.user_id AND m.receiver_id = c.other_user_id) OR
        (m.sender_id = c.other_user_id AND m.receiver_id = c.user_id)
    )
    WHERE c.id IS NULL
);

-- 5. Clean up orphaned notifications
DELETE FROM notifications 
WHERE id IN (
    SELECT n.id
    FROM notifications n
    LEFT JOIN auth.users u ON n.user_id = u.id
    WHERE u.id IS NULL
);

-- 6. Add missing indexes for better performance
CREATE INDEX IF NOT EXISTS idx_conversations_user_other_user 
ON conversations(user_id, other_user_id);

CREATE INDEX IF NOT EXISTS idx_messages_sender_receiver_time 
ON messages(sender_id, receiver_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_user_created 
ON notifications(user_id, created_at DESC);

-- 7. Update conversation unread counts
UPDATE conversations 
SET unread_count = (
    SELECT COUNT(*)
    FROM messages m
    WHERE m.sender_id = conversations.other_user_id 
    AND m.receiver_id = conversations.user_id
    AND m.status < 3  -- messages that are not read
);

-- 8. Clean up any conversations with invalid user references
DELETE FROM conversations 
WHERE user_id NOT IN (SELECT id FROM auth.users)
   OR other_user_id NOT IN (SELECT id FROM auth.users);

-- 9. Ensure all conversations have valid names
UPDATE conversations 
SET other_user_name = 'Unknown User'
WHERE other_user_name IS NULL OR other_user_name = '';

-- 10. Add a function to automatically update conversation names
CREATE OR REPLACE FUNCTION update_conversation_names()
RETURNS TRIGGER AS $$
BEGIN
    -- Update conversation names when profiles are updated
    UPDATE conversations 
    SET other_user_name = COALESCE(NEW.display_name, NEW.username, 'Unknown User')
    WHERE other_user_id = NEW.id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update conversation names
DROP TRIGGER IF EXISTS trigger_update_conversation_names ON profiles;
CREATE TRIGGER trigger_update_conversation_names
    AFTER UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_conversation_names();

-- 11. Add a function to clean up old messages (optional - uncomment if needed)
-- CREATE OR REPLACE FUNCTION cleanup_old_messages()
-- RETURNS void AS $$
-- BEGIN
--     DELETE FROM messages 
--     WHERE created_at < NOW() - INTERVAL '90 days';
-- END;
-- $$ LANGUAGE plpgsql;

-- 12. Add RLS policies if they don't exist
DO $$
BEGIN
    -- Enable RLS on conversations if not already enabled
    IF NOT EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE tablename = 'conversations' 
        AND rowsecurity = true
    ) THEN
        ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
    END IF;
    
    -- Add conversation policies if they don't exist
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'conversations' 
        AND policyname = 'Users can view their own conversations'
    ) THEN
        CREATE POLICY "Users can view their own conversations" 
        ON conversations FOR SELECT 
        USING (auth.uid() = user_id);
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'conversations' 
        AND policyname = 'Users can create their own conversations'
    ) THEN
        CREATE POLICY "Users can create their own conversations" 
        ON conversations FOR INSERT 
        WITH CHECK (auth.uid() = user_id);
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'conversations' 
        AND policyname = 'Users can update their own conversations'
    ) THEN
        CREATE POLICY "Users can update their own conversations" 
        ON conversations FOR UPDATE 
        USING (auth.uid() = user_id);
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'conversations' 
        AND policyname = 'Users can delete their own conversations'
    ) THEN
        CREATE POLICY "Users can delete their own conversations" 
        ON conversations FOR DELETE 
        USING (auth.uid() = user_id);
    END IF;
END $$;

-- 13. Clean up any remaining issues
-- Remove any conversations with empty or invalid data
DELETE FROM conversations 
WHERE last_message IS NULL 
   OR last_message_time IS NULL 
   OR user_id IS NULL 
   OR other_user_id IS NULL;

-- 14. Final cleanup - remove any remaining duplicates
DELETE FROM conversations 
WHERE id IN (
    SELECT c1.id
    FROM conversations c1
    JOIN conversations c2 ON (
        c1.user_id = c2.user_id AND c1.other_user_id = c2.other_user_id
    )
    WHERE c1.id < c2.id
);

-- 15. Add a comment to track this migration
COMMENT ON TABLE conversations IS 'Updated and cleaned conversations table - migration 20250729000000'; 