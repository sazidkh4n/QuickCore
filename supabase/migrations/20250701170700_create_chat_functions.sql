-- Create a stored procedure to create conversations with default values
CREATE OR REPLACE FUNCTION create_conversation(
  p_user_id UUID,
  p_other_user_id UUID,
  p_other_user_name TEXT,
  p_last_message TEXT,
  p_last_message_time TIMESTAMP WITH TIME ZONE
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_conversation_id UUID;
BEGIN
  -- Insert the conversation with default values
  INSERT INTO conversations (
    user_id,
    other_user_id,
    other_user_name,
    other_user_avatar,
    last_message,
    last_message_time,
    unread_count,
    is_online
  ) VALUES (
    p_user_id,
    p_other_user_id,
    p_other_user_name,
    NULL, -- Default avatar
    p_last_message,
    p_last_message_time,
    CASE WHEN p_user_id = auth.uid() THEN 0 ELSE 1 END, -- Unread count
    false -- Is online
  )
  RETURNING id INTO v_conversation_id;
  
  RETURN v_conversation_id;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION create_conversation(UUID, UUID, TEXT, TEXT, TIMESTAMP WITH TIME ZONE) TO authenticated; 