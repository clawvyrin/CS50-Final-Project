CREATE OR REPLACE VIEW activity_view AS
SELECT
    a.id,
    a.task_id,
    a.user_id,
    
    -- User nested
    jsonb_build_object(
        'id', u.id,
        'display_name', u.display_name,
        'avatar_url', u.avatar_url
    ) AS user,
    
    a.description,
    a.created_at,

    -- Affected resources from resource_view
    COALESCE(
        (
            SELECT jsonb_agg(rv)
            FROM activity_resources ar
            JOIN resource_view rv
                ON rv.id = ar.resource_id
            WHERE ar.activity_id = a.id
        ),
        '[]'::jsonb
    ) AS affected_resources

FROM activities a
JOIN profiles u ON u.id = a.user_id;


CREATE INDEX activities_task_idx
ON activities(task_id);

CREATE INDEX activities_user_idx
ON activities(user_id);

CREATE INDEX activity_resources_activity_idx
ON activity_resources(activity_id);