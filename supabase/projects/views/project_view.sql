CREATE OR REPLACE VIEW project_view AS
SELECT
    p.id,
    p.name,
    p.description,

    -- Owner
    jsonb_build_object(
        'id', o.id,
        'display_name', o.display_name,
        'avatar_url', o.avatar_url
    ) AS owner,

    p.status,
    p.background_picture_url,
    p.created_at,

    -- Tasks
    COALESCE(
        (
            SELECT jsonb_agg(tv)
            FROM task_view tv
            WHERE (tv.project->>'id')::uuid = p.id
        ),
        '[]'::jsonb
    ) AS tasks,

    -- Milestones
    COALESCE(
        (
            SELECT jsonb_agg(mv)
            FROM milestone_view mv
            WHERE (mv.project->>'id')::uuid = p.id
        ),
        '[]'::jsonb
    ) AS milestones,

    -- Timeline
    COALESCE(
        (
            SELECT jsonb_agg(tv)
            FROM timeline_event_view tv
            WHERE (tv.project->>'id')::uuid = p.id
        ),
        '[]'::jsonb
    ) AS timeline,

    -- Members
    COALESCE(
        (
            SELECT jsonb_agg(mv)
            FROM project_member_view mv
            WHERE mv.project_id = p.id
        ),
        '[]'::jsonb
    ) AS members,

    -- Resources
    COALESCE(
        (
            SELECT jsonb_agg(rv)
            FROM resource_view rv
            WHERE (rv.project->>'id')::uuid = p.id
        ),
        '[]'::jsonb
    ) AS resources,

    p.start_date,
    p.end_date,
    EXISTS (
        SELECT 1 FROM projects pr 
        WHERE pr.id = p.id AND pr.owner_id = auth.uid()
    ) AS is_owner
    

FROM projects p
JOIN profiles o ON o.id = p.owner_id;

CREATE INDEX projects_owner_idx
ON projects(owner_id);

CREATE INDEX tasks_project_idx
ON task_view(project->>'id');

CREATE INDEX milestones_project_idx
ON milestone_view(project->>'id');

CREATE INDEX timeline_project_idx
ON timeline_event_view(project->>'id');

CREATE INDEX members_project_idx
ON project_member_view(project->>'id');

CREATE INDEX resources_project_idx
ON resource_view(project->>'id');

CREATE INDEX activities_project_idx
ON activity_view(task->'project'->>'id');