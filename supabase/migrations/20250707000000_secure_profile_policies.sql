-- Create the user_skills table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.user_skills (
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  skill TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, skill)
);


-- First, add the 'role' column to the 'profiles' table so it can be used in policies
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'learner';

-- We also need to update the function that creates new profiles
-- to populate the role from the user's metadata upon signup.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, username, display_name, avatar_url, role)
  VALUES (
    new.id,
    new.raw_user_meta_data->>'username',
    new.raw_user_meta_data->>'display_name',
    new.raw_user_meta_data->>'avatar_url',
    new.raw_user_meta_data->>'role'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 1. Secure the 'profiles' table
-- Drop the old, permissive update policy
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;

-- Create a new, stricter update policy that prevents role changes.
-- Users can update their own name, username, bio, and avatar_url, but not their role or other fields.
CREATE POLICY "Users can update their own profile data"
ON public.profiles
FOR UPDATE USING (auth.uid() = id)
WITH CHECK (
  auth.uid() = id AND
  role = (SELECT role FROM public.profiles WHERE id = auth.uid())
);


-- 2. Add RLS policies for the 'skills' (videos) table
ALTER TABLE public.skills ENABLE ROW LEVEL SECURITY;

-- Anyone can read videos
CREATE POLICY "Allow public read access to skills"
ON public.skills
FOR SELECT USING (true);

-- Only users with the 'tutor' role can insert videos
CREATE POLICY "Tutors can insert their own skills"
ON public.skills
FOR INSERT
WITH CHECK (
  auth.uid() = creator_id AND
  (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'tutor'
);

-- Tutors can update their own videos
CREATE POLICY "Tutors can update their own skills"
ON public.skills
FOR UPDATE
USING (auth.uid() = creator_id)
WITH CHECK (auth.uid() = creator_id);

-- Tutors can delete their own videos
CREATE POLICY "Tutors can delete their own skills"
ON public.skills
FOR DELETE
USING (auth.uid() = creator_id);


-- 3. Add RLS policy for reading 'views' (history) table
ALTER TABLE public.views ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own history"
ON public.views
FOR SELECT USING (auth.uid() = user_id);


-- 4. RLS policies for 'user_skills' have been moved to their own migration file. 