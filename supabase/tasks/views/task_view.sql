CREATE OR REPLACE VIEW task_view AS
SELECT
    t.id,
    
    jsonb_build_object(
        'id', p.id,
        'name', p.name,
        'description', p.description
    ) AS project,

    (
        SELECT c.id
        FROM conversations c
        WHERE c.task_id = t.id
        AND c.project_id = t.project_id
        LIMIT 1
    ) AS conversation_id,
    t.title,
    t.description,
    t.status,

    -- Assignee
    jsonb_build_object(
        'id', a.id,
        'display_name', a.display_name,
        'avatar_url', a.avatar_url
    ) AS assignee,

    COALESCE(t.work_days, '{}') AS work_days,
    COALESCE(t.shift_start_time, '08:00:00') AS shift_start_time,
    COALESCE(t.shift_end_time, '18:00:00') AS shift_end_time,

    -- Affected resources
    COALESCE(
        (
            SELECT jsonb_agg(rv)
            FROM resource_view rv
            JOIN activity_resources ar ON ar.resource_id = rv.id
            JOIN activities act ON act.id = ar.activity_id
            WHERE act.task_id = t.id
        ),
        '[]'::jsonb
    ) AS affected_resources,

    -- Activities
    COALESCE(
        (
            SELECT jsonb_agg(av)
            FROM activity_view av
            WHERE av.task_id = t.id
        ),
        '[]'::jsonb
    ) AS activities,

    -- Reports
    COALESCE(
        (
            SELECT jsonb_agg(dtrv)
            FROM daily_task_report_view dtrv
            WHERE (dtrv.task->>'id')::uuid = t.id
        ),
        '[]'::jsonb
    ) AS reports,

    -- Dependencies
    COALESCE(
        (
            SELECT jsonb_agg(td)
            FROM task_dependency_view td
            WHERE (td.task->>'id')::uuid = t.id
        ),
        '[]'::jsonb
    ) AS dependencies,

    t.due_date

FROM tasks t
JOIN projects p ON p.id = t.project_id
JOIN profiles a ON a.id = t.assigned_to;


CREATE INDEX tasks_project_idx
ON tasks(project_id);

CREATE INDEX tasks_assignee_idx
ON tasks(assigned_to);

CREATE INDEX tasks_conversation_idx
ON tasks(conversation_id);