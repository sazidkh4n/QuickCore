-- migration.sql
CREATE POLICY "Allow authenticated users to insert views"
ON public.views
FOR INSERT
TO authenticated
WITH CHECK (true); 