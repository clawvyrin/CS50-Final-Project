CREATE OR REPLACE VIEW conversation_details_view AS
SELECT 
    c.id,
    c.title,
    c.created_at,
    c.updated_at,
    (SELECT jsonb_build_object(
        'id', t.id,
        'title', t.title
    ) FROM tasks t WHERE t.id = c.task_id) as task,
    (SELECT jsonb_build_object(
        'content', m.content,
        'type', m.type,
        'sent_at', m.created_at,
        'seen_at', m.seen_at
    ) FROM messages m 
      WHERE m.conversation_id = c.id 
      ORDER BY m.created_at DESC LIMIT 1) as last_message,
    -- Liste des participants
    (SELECT jsonb_agg(jsonb_build_object(
        'user_id', p.user_id,
        'role', p.role
    )) FROM conversation_participants p WHERE p.conversation_id = c.id) as participants
FROM conversations c;