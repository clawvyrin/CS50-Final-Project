CREATE OR REPLACE VIEW timeline_event_view AS
SELECT
    te.id,

    -- Nested project object
    jsonb_build_object(
        'id', p.id,
        'name', p.name,
        'description', p.description,
        'status', p.status
    ) AS project,

    -- Nested user object
    jsonb_build_object(
        'id', u.id,
        'display_name', u.display_name,
        'avatar_url', u.avatar_url
    ) AS user,

    te.action_type,
    te.content,
    te.metadata,
    te.created_at

FROM timeline_events te
JOIN projects p
    ON p.id = te.project_id
JOIN profiles u
    ON u.id = te.user_id;

CREATE INDEX timeline_events_project_idx
ON timeline_events(project_id);

CREATE INDEX timeline_events_user_idx
ON timeline_events(user_id);

CREATE INDEX timeline_events_created_idx
ON timeline_events(created_at DESC);