CREATE POLICY "Allow authenticated users to insert comments"
ON public.comments
FOR INSERT
TO authenticated
WITH CHECK (true); 