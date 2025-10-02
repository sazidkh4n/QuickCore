-- Enhanced Chat System Migration
-- This creates the new enhanced chat tables and functions

-- Create enhanced_messages table
CREATE TABLE IF NOT EXISTS enhanced_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    message TEXT,
    message_type TEXT NOT NULL DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'video', 'audio', 'file', 'location', 'contact', 'sticker', 'gif')),
    media_attachment JSONB,
    reply_to_message_id UUID REFERENCES enhanced_messages(id) ON DELETE SET NULL,
    reactions JSONB DEFAULT '[]'::jsonb,
    status INTEGER NOT NULL DEFAULT 1 CHECK (status >= 0 AND status <= 4), -- 0: sending, 1: sent, 2: delivered, 3: read, 4: failed
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    is_edited BOOLEAN DEFAULT FALSE,
    is_forwarded BOOLEAN DEFAULT FALSE,
    forwarded_from_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Create indexes for enhanced_messages
CREATE INDEX IF NOT EXISTS idx_enhanced_messages_sender_receiver ON enhanced_messages(sender_id, receiver_id);
CREATE INDEX IF NOT EXISTS idx_enhanced_messages_receiver_sender ON enhanced_messages(receiver_id, sender_id);
CREATE INDEX IF NOT EXISTS idx_enhanced_messages_created_at ON enhanced_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_enhanced_messages_reply_to ON enhanced_messages(reply_to_message_id);
CREATE INDEX IF NOT EXISTS idx_enhanced_messages_status ON enhanced_messages(status);
CREATE INDEX IF NOT EXISTS idx_enhanced_messages_message_type ON enhanced_messages(message_type);

-- Create chat_presence table for real-time presence
CREATE TABLE IF NOT EXISTS chat_presence (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    is_online BOOLEAN NOT NULL DEFAULT FALSE,
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create typing_indicators table
CREATE TABLE IF NOT EXISTS typing_indicators (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    conversation_id TEXT NOT NULL, -- Can be user_id or group_id
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '10 seconds')
);

-- Create indexes for typing_indicators
CREATE INDEX IF NOT EXISTS idx_typing_indicators_conversation ON typing_indicators(conversation_id);
CREATE INDEX IF NOT EXISTS idx_typing_indicators_expires_at ON typing_indicators(expires_at);

-- Enable Row Level Security
ALTER TABLE enhanced_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_presence ENABLE ROW LEVEL SECURITY;
ALTER TABLE typing_indicators ENABLE ROW LEVEL SECURITY;

-- RLS Policies for enhanced_messages
CREATE POLICY "Users can view their own messages" ON enhanced_messages
    FOR SELECT USING (
        auth.uid() = sender_id OR auth.uid() = receiver_id
    );

CREATE POLICY "Users can insert their own messages" ON enhanced_messages
    FOR INSERT WITH CHECK (
        auth.uid() = sender_id
    );

CREATE POLICY "Users can update their own messages" ON enhanced_messages
    FOR UPDATE USING (
        auth.uid() = sender_id
    );

CREATE POLICY "Users can delete their own messages" ON enhanced_messages
    FOR DELETE USING (
        auth.uid() = sender_id
    );

-- RLS Policies for chat_presence
CREATE POLICY "Users can view all presence" ON chat_presence
    FOR SELECT USING (TRUE);

CREATE POLICY "Users can update their own presence" ON chat_presence
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own presence" ON chat_presence
    FOR UPDATE USING (auth.uid() = user_id);

-- RLS Policies for typing_indicators
CREATE POLICY "Users can view typing indicators" ON typing_indicators
    FOR SELECT USING (TRUE);

CREATE POLICY "Users can insert their own typing indicators" ON typing_indicators
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own typing indicators" ON typing_indicators
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own typing indicators" ON typing_indicators
    FOR DELETE USING (auth.uid() = user_id);

-- Function to update message status
CREATE OR REPLACE FUNCTION update_message_status()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for updating message timestamps
CREATE TRIGGER update_enhanced_messages_updated_at
    BEFORE UPDATE ON enhanced_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_message_status();

-- Function to clean up expired typing indicators
CREATE OR REPLACE FUNCTION cleanup_expired_typing_indicators()
RETURNS void AS $$
BEGIN
    DELETE FROM typing_indicators WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- Function to update user presence
CREATE OR REPLACE FUNCTION update_user_presence(
    p_user_id UUID,
    p_is_online BOOLEAN DEFAULT TRUE,
    p_status TEXT DEFAULT NULL
)
RETURNS void AS $$
BEGIN
    INSERT INTO chat_presence (user_id, is_online, status, last_seen, updated_at)
    VALUES (p_user_id, p_is_online, p_status, NOW(), NOW())
    ON CONFLICT (user_id)
    DO UPDATE SET
        is_online = p_is_online,
        status = COALESCE(p_status, chat_presence.status),
        last_seen = CASE WHEN p_is_online THEN NOW() ELSE chat_presence.last_seen END,
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to start typing indicator
CREATE OR REPLACE FUNCTION start_typing_indicator(
    p_user_id UUID,
    p_conversation_id TEXT
)
RETURNS void AS $$
BEGIN
    -- Remove existing typing indicator for this user in this conversation
    DELETE FROM typing_indicators 
    WHERE user_id = p_user_id AND conversation_id = p_conversation_id;
    
    -- Insert new typing indicator
    INSERT INTO typing_indicators (user_id, conversation_id, started_at, expires_at)
    VALUES (p_user_id, p_conversation_id, NOW(), NOW() + INTERVAL '10 seconds');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to stop typing indicator
CREATE OR REPLACE FUNCTION stop_typing_indicator(
    p_user_id UUID,
    p_conversation_id TEXT
)
RETURNS void AS $$
BEGIN
    DELETE FROM typing_indicators 
    WHERE user_id = p_user_id AND conversation_id = p_conversation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get conversation messages with pagination
CREATE OR REPLACE FUNCTION get_conversation_messages(
    p_other_user_id UUID,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    sender_id UUID,
    receiver_id UUID,
    message TEXT,
    message_type TEXT,
    media_attachment JSONB,
    reply_to_message_id UUID,
    reactions JSONB,
    status INTEGER,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE,
    is_edited BOOLEAN,
    is_forwarded BOOLEAN,
    forwarded_from_user_id UUID,
    metadata JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        em.id,
        em.sender_id,
        em.receiver_id,
        em.message,
        em.message_type,
        em.media_attachment,
        em.reply_to_message_id,
        em.reactions,
        em.status,
        em.created_at,
        em.updated_at,
        em.deleted_at,
        em.is_edited,
        em.is_forwarded,
        em.forwarded_from_user_id,
        em.metadata
    FROM enhanced_messages em
    WHERE 
        (em.sender_id = auth.uid() AND em.receiver_id = p_other_user_id)
        OR (em.sender_id = p_other_user_id AND em.receiver_id = auth.uid())
        AND em.deleted_at IS NULL
    ORDER BY em.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to search messages
CREATE OR REPLACE FUNCTION search_messages(
    p_query TEXT,
    p_other_user_id UUID DEFAULT NULL,
    p_message_type TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
    id UUID,
    sender_id UUID,
    receiver_id UUID,
    message TEXT,
    message_type TEXT,
    media_attachment JSONB,
    reply_to_message_id UUID,
    reactions JSONB,
    status INTEGER,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE,
    is_edited BOOLEAN,
    is_forwarded BOOLEAN,
    forwarded_from_user_id UUID,
    metadata JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        em.id,
        em.sender_id,
        em.receiver_id,
        em.message,
        em.message_type,
        em.media_attachment,
        em.reply_to_message_id,
        em.reactions,
        em.status,
        em.created_at,
        em.updated_at,
        em.deleted_at,
        em.is_edited,
        em.is_forwarded,
        em.forwarded_from_user_id,
        em.metadata
    FROM enhanced_messages em
    WHERE 
        (em.sender_id = auth.uid() OR em.receiver_id = auth.uid())
        AND em.deleted_at IS NULL
        AND (p_other_user_id IS NULL OR 
             (em.sender_id = p_other_user_id OR em.receiver_id = p_other_user_id))
        AND (p_message_type IS NULL OR em.message_type = p_message_type)
        AND (em.message ILIKE '%' || p_query || '%')
    ORDER BY em.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to mark messages as read
CREATE OR REPLACE FUNCTION mark_messages_as_read(
    p_other_user_id UUID
)
RETURNS void AS $$
BEGIN
    UPDATE enhanced_messages
    SET status = 3, updated_at = NOW() -- 3 = read
    WHERE receiver_id = auth.uid() 
        AND sender_id = p_other_user_id 
        AND status < 3;
        
    -- Update conversation unread count
    UPDATE conversations
    SET unread_count = 0
    WHERE user_id = auth.uid() AND other_user_id = p_other_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a scheduled job to clean up expired typing indicators (if pg_cron is available)
-- SELECT cron.schedule('cleanup-typing-indicators', '*/30 * * * * *', 'SELECT cleanup_expired_typing_indicators();');

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON enhanced_messages TO authenticated;
GRANT ALL ON chat_presence TO authenticated;
GRANT ALL ON typing_indicators TO authenticated;
GRANT EXECUTE ON FUNCTION update_user_presence TO authenticated;
GRANT EXECUTE ON FUNCTION start_typing_indicator TO authenticated;
GRANT EXECUTE ON FUNCTION stop_typing_indicator TO authenticated;
GRANT EXECUTE ON FUNCTION get_conversation_messages TO authenticated;
GRANT EXECUTE ON FUNCTION search_messages TO authenticated;
GRANT EXECUTE ON FUNCTION mark_messages_as_read TO authenticated;
GRANT EXECUTE ON FUNCTION cleanup_expired_typing_indicators TO authenticated;