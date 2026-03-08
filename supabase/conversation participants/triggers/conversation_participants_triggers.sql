ALTER TABLE conversation_participants 
ADD COLUMN last_message_at TIMESTAMPTZ DEFAULT NOW();

CREATE OR REPLACE FUNCTION sync_participants_on_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE conversation_participants
  SET last_message_at = NEW.created_at
  WHERE conversation_id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_sync_msg_to_participants
AFTER INSERT ON messages
FOR EACH ROW EXECUTE FUNCTION sync_participants_on_message();