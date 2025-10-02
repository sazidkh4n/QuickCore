-- Create helper functions to insert likes and comments without triggering notifications

-- Function to insert a like without triggering the notification
CREATE OR REPLACE FUNCTION insert_like_without_notification(
  user_id_param UUID,
  skill_id_param UUID
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Directly insert the like without triggering the notification
  INSERT INTO likes (user_id, skill_id)
  VALUES (user_id_param, skill_id_param)
  ON CONFLICT (user_id, skill_id) DO NOTHING;
END;
$$;

-- Function to insert a comment without triggering the notification
CREATE OR REPLACE FUNCTION insert_comment_without_notification(
  id_param UUID,
  skill_id_param UUID,
  user_id_param UUID,
  content_param TEXT,
  parent_comment_id_param UUID DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Directly insert the comment without triggering the notification
  INSERT INTO comments (id, skill_id, user_id, content, parent_comment_id, created_at)
  VALUES (
    id_param, 
    skill_id_param, 
    user_id_param, 
    content_param, 
    parent_comment_id_param,
    now()
  );
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION insert_like_without_notification(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION insert_comment_without_notification(UUID, UUID, UUID, TEXT, UUID) TO authenticated; 