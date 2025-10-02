-- Create function to get total likes for a user
CREATE OR REPLACE FUNCTION get_total_likes_for_user(target_user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN (
    SELECT COALESCE(COUNT(*), 0)
    FROM likes l
    INNER JOIN skills s ON l.skill_id = s.id
    WHERE s.creator_id = target_user_id
  );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_total_likes_for_user(UUID) TO authenticated; 