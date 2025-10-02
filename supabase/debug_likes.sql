-- Debug script to check likes data and test the function

-- 1. Check if there are any likes in the database
SELECT 'Total likes in database:' as info, COUNT(*) as count FROM likes;

-- 2. Check if there are any skills in the database
SELECT 'Total skills in database:' as info, COUNT(*) as count FROM skills;

-- 3. Check specific user's skills
SELECT 'User skills:' as info, id, title, creator_id FROM skills WHERE creator_id = 'a2fe861c-45c2-44d5-b15e-38e0ec4af2c3';

-- 4. Check likes for specific user's skills
SELECT 'Likes for user skills:' as info, l.skill_id, s.title, COUNT(l.user_id) as like_count
FROM likes l
JOIN skills s ON l.skill_id = s.id
WHERE s.creator_id = 'a2fe861c-45c2-44d5-b15e-38e0ec4af2c3'
GROUP BY l.skill_id, s.title;

-- 5. Test the function directly
SELECT 'Function result:' as info, get_total_likes_for_user('a2fe861c-45c2-44d5-b15e-38e0ec4af2c3') as total_likes;

-- 6. Check all likes with skill details
SELECT 'All likes with details:' as info, l.skill_id, s.title, s.creator_id, l.user_id
FROM likes l
JOIN skills s ON l.skill_id = s.id
ORDER BY l.liked_at DESC; 