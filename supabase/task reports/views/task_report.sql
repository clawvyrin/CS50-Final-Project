CREATE OR REPLACE VIEW daily_task_report_view AS
SELECT
    dtr.id,
    
    -- Task nested
    jsonb_build_object(
        'id', t.id,
        'title', t.title,
        'description', t.description,
        'project', jsonb_build_object(
            'id', p.id,
            'name', p.name,
            'description', p.description
        )
    ) AS task,

    -- Submitted by user
    jsonb_build_object(
        'id', u.id,
        'display_name', u.display_name,
        'avatar_url', u.avatar_url
    ) AS submitted_by,

    dtr.daily_summary,
    dtr.daily_activities,
    dtr.start_time,
    dtr.end_time,
    dtr.duration_minutes,
    dtr.is_signed,
    dtr.reported_at

FROM daily_tasks_reports dtr
JOIN tasks t ON t.id = dtr.task_id
JOIN projects p ON p.id = t.project_id
JOIN profiles u ON u.id = dtr.user_id;

CREATE INDEX daily_task_reports_task_idx
ON daily_task_reports(task_id);

CREATE INDEX daily_task_reports_user_idx
ON daily_task_reports(submitted_by_id);

CREATE INDEX daily_task_reports_reported_at_idx
ON daily_task_reports(reported_at);