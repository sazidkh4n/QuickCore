-- Enable select for users on their own favorites
CREATE POLICY "Enable select for users on their own favorites"
ON public.favorites
FOR SELECT
USING (auth.uid() = user_id); 