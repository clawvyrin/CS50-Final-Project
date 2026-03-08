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