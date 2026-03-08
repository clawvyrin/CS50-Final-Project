CREATE OR REPLACE VIEW project_member_view AS
SELECT
    pm.id,
    pm.project_id,

    -- Nested user object
    jsonb_build_object(
        'id', u.id,
        'display_name', u.display_name,
        'avatar_url', u.avatar_url
    ) AS user,

    pm.job_description,
    pm.role,
    pm.status,
    pm.created_at

FROM project_members pm
JOIN profiles u
    ON u.id = pm.user_id;

CREATE INDEX project_members_project_idx
ON project_members(project_id);

CREATE INDEX project_members_user_idx
ON project_members(user_id);