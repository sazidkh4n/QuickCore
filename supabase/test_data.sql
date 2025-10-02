-- Test data for chat conversations
-- This script will create some test conversations and messages

-- First, let's get some user IDs from the profiles table
-- You'll need to replace these with actual user IDs from your profiles table

-- Insert test conversations
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
-- Replace these UUIDs with actual user IDs from your profiles table
-- You can get these by running: SELECT id, username FROM profiles LIMIT 5;
(
  '00000000-0000-0000-0000-000000000001', -- Replace with actual user ID
  '00000000-0000-0000-0000-000000000002', -- Replace with actual user ID
  'Test User 1',
  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
  'Hey! How are you doing?',
  NOW() - INTERVAL '2 hours',
  1,
  true
),
(
  '00000000-0000-0000-0000-000000000001', -- Replace with actual user ID
  '00000000-0000-0000-0000-000000000003', -- Replace with actual user ID
  'Test User 2',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
  'Thanks for the help!',
  NOW() - INTERVAL '1 hour',
  0,
  false
);

-- Insert test messages
INSERT INTO messages (
  sender_id,
  receiver_id,
  message,
  status,
  created_at
) VALUES 
-- Replace these UUIDs with actual user IDs from your profiles table
(
  '00000000-0000-0000-0000-000000000002', -- Test User 1
  '00000000-0000-0000-0000-000000000001', -- Current user
  'Hey! How are you doing?',
  3, -- Read status
  NOW() - INTERVAL '2 hours'
),
(
  '00000000-0000-0000-0000-000000000001', -- Current user
  '00000000-0000-0000-0000-000000000002', -- Test User 1
  'I\'m doing great! How about you?',
  3, -- Read status
  NOW() - INTERVAL '1 hour 30 minutes'
),
(
  '00000000-0000-0000-0000-000000000002', -- Test User 1
  '00000000-0000-0000-0000-000000000001', -- Current user
  'Pretty good! Working on some new content.',
  1, -- Sent status (unread)
  NOW() - INTERVAL '30 minutes'
),
(
  '00000000-0000-0000-0000-000000000001', -- Current user
  '00000000-0000-0000-0000-000000000003', -- Test User 2
  'Hi there! I have a question about the tutorial.',
  3, -- Read status
  NOW() - INTERVAL '2 hours'
),
(
  '00000000-0000-0000-0000-000000000003', -- Test User 2
  '00000000-0000-0000-0000-000000000001', -- Current user
  'Sure! What would you like to know?',
  3, -- Read status
  NOW() - INTERVAL '1 hour 45 minutes'
),
(
  '00000000-0000-0000-0000-000000000001', -- Current user
  '00000000-0000-0000-0000-000000000003', -- Test User 2
  'How do I implement the authentication flow?',
  3, -- Read status
  NOW() - INTERVAL '1 hour 30 minutes'
),
(
  '00000000-0000-0000-0000-000000000003', -- Test User 2
  '00000000-0000-0000-0000-000000000001', -- Current user
  'Thanks for the help!',
  3, -- Read status
  NOW() - INTERVAL '1 hour'
); 