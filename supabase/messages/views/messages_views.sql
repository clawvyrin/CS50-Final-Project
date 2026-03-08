CREATE OR REPLACE VIEW message_view AS
SELECT
    m.id,
    m.conversation_id,

    -- Sender info
    jsonb_build_object(
        'id', p.id,
        'display_name', p.display_name,
        'avatar_url', p.avatar_url
    ) AS sender,

    m.type,

    -- Is the message from the current user
    (m.sender_id = auth.uid()) AS is_me,

    m.content,
    m.meta_data,
    m.created_at,

    -- Seen at for current user
    CASE
        WHEN m.created_at <= cp.last_seen_at THEN cp.last_seen_at
        ELSE NULL
    END AS seen_at

FROM messages m
JOIN profiles p
    ON p.id = m.sender_id

-- join the current user's conversation participant row to get last_seen_at
LEFT JOIN conversation_participants cp
    ON cp.conversation_id = m.conversation_id
   AND cp.user_id = auth.uid();

CREATE INDEX messages_conversation_created_idx
ON messages(conversation_id, created_at DESC);

CREATE INDEX messages_sender_idx
ON messages(sender_id);