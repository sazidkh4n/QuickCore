-- Enable insert for users to add their own favorites
CREATE POLICY "Enable insert for users to add their own favorites"
ON public.favorites
FOR INSERT
WITH CHECK (auth.uid() = user_id); 