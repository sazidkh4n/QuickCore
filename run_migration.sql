-- Add message_type column to messages table for enhanced chat support
ALTER TABLE messages 
ADD COLUMN IF NOT EXISTS message_type INTEGER DEFAULT 0;

-- Add metadata column for storing additional message data
ALTER TABLE messages 
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}';

-- Update existing messages to have text type
UPDATE messages 
SET message_type = 0 
WHERE message_type IS NULL;

-- Make message_type NOT NULL after setting defaults
ALTER TABLE messages 
ALTER COLUMN message_type SET NOT NULL;

-- Add comment to document the message_type values
COMMENT ON COLUMN messages.message_type IS 'Message type: 0=text, 1=image, 2=video, 3=audio, 4=file'; 