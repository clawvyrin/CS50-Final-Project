CREATE OR REPLACE VIEW conversation_view AS
SELECT
    c.id,
    c.title,
    c.created_at,
    c.updated_at,

    -- TASK (nullable)
    CASE
        WHEN t.id IS NULL THEN NULL
        ELSE jsonb_build_object(
            'id', t.id,
            'title', t.title,
            'description', t.description,
            'project', jsonb_build_object(
                'id', pr.id,
                'name', pr.name,
                'description', pr.description
            )
        )
    END AS task,

    -- LAST MESSAGE
    lm.last_message,

    -- PARTICIPANTS
    COALESCE(pt.participants, '[]'::jsonb) AS participants

FROM conversations c

LEFT JOIN tasks t
    ON t.id = c.task_id

LEFT JOIN projects pr
    ON pr.id = t.project_id


-- last message with computed seen_at
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


-- participants list
LEFT JOIN LATERAL (
    SELECT jsonb_agg(
        jsonb_build_object(
            'conversation_id', p.conversation_id,
            'user', jsonb_build_object(
                'id', prf.id,
                'display_name', prf.display_name,
                'avatar_url', prf.avatar_url
            )
        )
    ) AS participants
    FROM conversation_participants p
    JOIN profiles prf
        ON prf.id = p.user_id
    WHERE p.conversation_id = c.id
) pt ON TRUE;


CREATE INDEX conversation_participants_conversation_idx
ON conversation_participants(conversation_id);

CREATE INDEX conversations_updated_idx
ON conversations(updated_at DESC);

CREATE INDEX conversation_participants_user_idx
ON conversation_participants(user_id, conversation_id);