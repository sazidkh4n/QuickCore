-- Quick test data for chat conversations
-- This script creates test conversations for the current authenticated user

-- Create test conversations for the current user
-- Replace 'YOUR_USER_ID_HERE' with your actual user ID from the profiles table

INSERT INTO conversations (
  user_id,
  other_user_id,
  other_user_name,
  other_user_avatar,
  last_message,
  last_message_time,
  unread_count,
  is_online
) VALUES 
(
  'YOUR_USER_ID_HERE', -- Replace with your actual user ID
  gen_random_uuid(), -- Generate a random UUID for the other user
  'John Doe',
  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
  'Hey! How are you doing?',
  NOW() - INTERVAL '2 hours',
  1,
  true
),
(
  'YOUR_USER_ID_HERE', -- Replace with your actual user ID
  gen_random_uuid(), -- Generate a random UUID for the other user
  'Jane Smith',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
  'Thanks for the help!',
  NOW() - INTERVAL '1 hour',
  0,
  false
);

-- Get the conversation IDs we just created
WITH new_conversations AS (
  SELECT id, other_user_id FROM conversations 
  WHERE user_id = 'YOUR_USER_ID_HERE' -- Replace with your actual user ID
  ORDER BY created_at DESC 
  LIMIT 2
)
-- Insert some test messages
INSERT INTO messages (
  sender_id,
  receiver_id,
  message,
  status,
  created_at
)
SELECT 
  nc.other_user_id,
  'YOUR_USER_ID_HERE', -- Replace with your actual user ID
  'Hey! How are you doing?',
  3,
  NOW() - INTERVAL '2 hours'
FROM new_conversations nc
WHERE nc.id = (SELECT id FROM conversations WHERE user_id = 'YOUR_USER_ID_HERE' ORDER BY created_at DESC LIMIT 1)
UNION ALL
SELECT 
  'YOUR_USER_ID_HERE', -- Replace with your actual user ID
  nc.other_user_id,
  'I''m doing great! How about you?',
  3,
  NOW() - INTERVAL '1 hour 30 minutes'
FROM new_conversations nc
WHERE nc.id = (SELECT id FROM conversations WHERE user_id = 'YOUR_USER_ID_HERE' ORDER BY created_at DESC LIMIT 1)
UNION ALL
SELECT 
  nc.other_user_id,
  'YOUR_USER_ID_HERE', -- Replace with your actual user ID
  'Pretty good! Working on some new content.',
  1,
  NOW() - INTERVAL '30 minutes'
FROM new_conversations nc
WHERE nc.id = (SELECT id FROM conversations WHERE user_id = 'YOUR_USER_ID_HERE' ORDER BY created_at DESC LIMIT 1); 