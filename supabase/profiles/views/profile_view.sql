CREATE OR REPLACE VIEW profiles_with_relation AS
SELECT
    p.id,
    p.email,
    p.first_name,
    p.last_name,
    p.display_name,
    p.biography,
    p.avatar_url,
    p.created_at,
    p.updated_at,

    -- collaborator status
    COALESCE(c.status = 'accepted', false) AS is_collaborator,

    -- current user sent the request
    COALESCE(c.status = 'pending' AND c.requested_by = auth.uid(), false) AS current_user_requested,

    -- current user received the request
    COALESCE(c.status = 'pending' AND c.requested_to = auth.uid(), false) AS other_user_requested,

    -- identify current user
    (p.id = auth.uid()) AS is_current_user,

    conv.conversation_id

FROM profiles p

LEFT JOIN collaborators c
ON (
    (c.requested_by = auth.uid() AND c.requested_to = p.id)
    OR
    (c.requested_by = p.id AND c.requested_to = auth.uid())
)

-- find conversation shared between both users
LEFT JOIN LATERAL (
    SELECT cp1.conversation_id
    FROM conversation_participants cp1
    JOIN conversation_participants cp2
        ON cp1.conversation_id = cp2.conversation_id
    WHERE cp1.user_id = auth.uid()
      AND cp2.user_id = p.id
    LIMIT 1
) conv ON TRUE;