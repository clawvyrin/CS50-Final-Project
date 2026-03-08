CREATE OR REPLACE VIEW conversation_view AS
SELECT
    c.id,
    c.title,
    c.created_at,

    -- task from task_view
    tv AS task,

    -- last message
    lm.last_message,

    -- participants
    COALESCE(pt.participants, '[]'::jsonb) AS participants,

    (SELECT m.created_at 
        FROM messages m 
        WHERE m.conversation_id = c.id 
        ORDER BY m.created_at DESC 
        LIMIT 1
    ) as last_message_at

FROM conversations c

LEFT JOIN task_view tv
    ON tv.id = c.task_id


-- LAST MESSAGE
LEFT JOIN LATERAL (
    SELECT jsonb_build_object(
        'content', m.content,
        'type', m.type,
        'sent_at', m.created_at,
        'seen_at',
            CASE
                WHEN cp.last_seen_at >= m.created_at
                THEN cp.last_seen_at
                ELSE NULL
            END
    ) AS last_message
    FROM messages m
    LEFT JOIN conversation_participants cp
        ON cp.conversation_id = m.conversation_id
        AND cp.user_id = auth.uid()
    WHERE m.conversation_id = c.id
    ORDER BY m.created_at DESC
    LIMIT 1
) lm ON TRUE


-- PARTICIPANTS using the new view
LEFT JOIN LATERAL (
    SELECT jsonb_agg(cp)
    FROM conversation_participant_view cp
    WHERE cp.conversation_id = c.id
) pt(participants) ON TRUE;


CREATE INDEX conversation_participants_conversation_idx
ON conversation_participants(conversation_id);

CREATE INDEX conversations_updated_idx
ON conversations(updated_at DESC);

CREATE INDEX conversation_participants_user_idx
ON conversation_participants(user_id, conversation_id);