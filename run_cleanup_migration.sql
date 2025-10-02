-- Run this script to clean up your database
-- This will fix all the issues with conversations, duplicates, and data consistency

-- Connect to your Supabase database and run this script

-- 1. Clean up duplicate conversations
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

-- 2. Update conversation names with proper user names
UPDATE conversations 
SET other_user_name = COALESCE(
    (SELECT display_name FROM profiles WHERE id = conversations.other_user_id),
    (SELECT username FROM profiles WHERE id = conversations.other_user_id),
    'Unknown User'
)
WHERE other_user_name IS NULL OR other_user_name = 'User' OR other_user_name LIKE '%@%';

-- 3. Sync conversations with latest messages
UPDATE conversations 
SET 
    last_message = (
        SELECT message 
        FROM messages m 
        WHERE (m.sender_id = conversations.user_id AND m.receiver_id = conversations.other_user_id)
           OR (m.sender_id = conversations.other_user_id AND m.receiver_id = conversations.user_id)
        ORDER BY m.created_at DESC 
        LIMIT 1
    ),
    last_message_time = (
        SELECT created_at 
        FROM messages m 
        WHERE (m.sender_id = conversations.user_id AND m.receiver_id = conversations.other_user_id)
           OR (m.sender_id = conversations.other_user_id AND m.receiver_id = conversations.user_id)
        ORDER BY m.created_at DESC 
        LIMIT 1
    )
WHERE id IN (
    SELECT c.id
    FROM conversations c
    WHERE EXISTS (
        SELECT 1 FROM messages m 
        WHERE (m.sender_id = c.user_id AND m.receiver_id = c.other_user_id)
           OR (m.sender_id = c.other_user_id AND m.receiver_id = c.user_id)
    )
);

-- 4. Update unread counts
UPDATE conversations 
SET unread_count = (
    SELECT COUNT(*)
    FROM messages m
    WHERE m.sender_id = conversations.other_user_id 
    AND m.receiver_id = conversations.user_id
    AND m.status < 3
);

-- 5. Clean up orphaned data
DELETE FROM messages 
WHERE sender_id NOT IN (SELECT id FROM auth.users)
   OR receiver_id NOT IN (SELECT id FROM auth.users);

DELETE FROM conversations 
WHERE user_id NOT IN (SELECT id FROM auth.users)
   OR other_user_id NOT IN (SELECT id FROM auth.users);

DELETE FROM notifications 
WHERE user_id NOT IN (SELECT id FROM auth.users);

-- 6. Add performance indexes
CREATE INDEX IF NOT EXISTS idx_conversations_user_other_user 
ON conversations(user_id, other_user_id);

CREATE INDEX IF NOT EXISTS idx_messages_sender_receiver_time 
ON messages(sender_id, receiver_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_user_created 
ON notifications(user_id, created_at DESC);

-- 7. Final cleanup - remove any remaining duplicates
DELETE FROM conversations 
WHERE id IN (
    SELECT c1.id
    FROM conversations c1
    JOIN conversations c2 ON (
        c1.user_id = c2.user_id AND c1.other_user_id = c2.other_user_id
    )
    WHERE c1.id < c2.id
);

-- 8. Show results
SELECT 
    'Conversations after cleanup' as status,
    COUNT(*) as count
FROM conversations;

SELECT 
    'Messages after cleanup' as status,
    COUNT(*) as count
FROM messages;

SELECT 
    'Notifications after cleanup' as status,
    COUNT(*) as count
FROM notifications; 