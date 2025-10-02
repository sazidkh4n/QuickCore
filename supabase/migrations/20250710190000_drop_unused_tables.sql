-- Drop unused tables to clean up the database schema.
-- These tables were identified as not being used by the application code.

DROP TABLE IF EXISTS "public"."achievements" CASCADE;
DROP TABLE IF EXISTS "public"."answers" CASCADE;
DROP TABLE IF EXISTS "public"."questions" CASCADE;
DROP TABLE IF EXISTS "public"."quizzes" CASCADE;
DROP TABLE IF EXISTS "public"."responses" CASCADE;
DROP TABLE IF EXISTS "public"."skill_bookmarks" CASCADE;
DROP TABLE IF EXISTS "public"."skill_comments" CASCADE;
DROP TABLE IF EXISTS "public"."skill_likes" CASCADE;
DROP TABLE IF EXISTS "public"."skill_shares" CASCADE;
DROP TABLE IF EXISTS "public"."user_follows" CASCADE;
DROP TABLE IF EXISTS "public"."views" CASCADE;
DROP TABLE IF EXISTS "public"."user_skills" CASCADE; 