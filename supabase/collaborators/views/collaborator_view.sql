drop view if exists user_search_view;
CREATE OR REPLACE VIEW user_search_view AS
SELECT
    p.id,
    p.display_name,
    p.avatar_url,
    MAX(CASE WHEN c.status = 'accepted' THEN true ELSE false END) AS is_collaborator,
    MAX(CASE WHEN c.status != 'accepted' AND c.requested_by = p.id THEN true ELSE false END) AS current_user_requested,
    MAX(CASE WHEN c.status != 'accepted' AND c.requested_to = p.id THEN true ELSE false END) AS other_user_requested
FROM profiles p
LEFT JOIN collaborators c
  ON c.requested_by = p.id OR c.requested_to = p.id
GROUP BY p.id, p.display_name, p.avatar_url;

CREATE OR REPLACE VIEW collaborator_view AS
SELECT
    jsonb_build_object(
        'requested_by', jsonb_build_object(
            'id', rb.id,
            'display_name', rb.display_name,
            'avatar_url', rb.avatar_url
        ),
        'requested_to', jsonb_build_object(
            'id', rt.id,
            'display_name', rt.display_name,
            'avatar_url', rt.avatar_url
        ),
        'status', c.status,
        'created_at', c.created_at,
        'updated_at', c.updated_at
    ) AS collaborator

FROM collaborators c

JOIN profiles rb
    ON rb.id = c.requested_by_id

JOIN profiles rt
    ON rt.id = c.requested_to_id;