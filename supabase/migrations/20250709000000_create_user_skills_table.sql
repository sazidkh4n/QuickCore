-- Create the user_skills table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.user_skills (
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  skill TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, skill)
);

-- Also, add the RLS policies for this table here to keep it self-contained
ALTER TABLE public.user_skills ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own skill interests"
ON public.user_skills
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own skill interests"
ON public.user_skills
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own skill interests"
ON public.user_skills
FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own skill interests"
ON public.user_skills
FOR DELETE USING (auth.uid() = user_id); 