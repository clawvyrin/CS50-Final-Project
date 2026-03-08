CREATE OR REPLACE VIEW task_dependency_view AS
SELECT
    td.id,
    td.project_id,
    
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

    jsonb_build_object(
        'id', d.id,
        'title', d.title,
        'description', d.description,
        'project', jsonb_build_object(
            'id', p.id,
            'name', p.name,
            'description', p.description
        )
    ) AS dependency,
    
    td.created_at

FROM task_dependencies td
JOIN tasks t ON t.id = td.task_id
JOIN tasks d ON d.id = td.dependency_id
JOIN projects p ON p.id = td.project_id;


CREATE INDEX task_dependencies_task_idx
ON task_dependencies(task_id);

CREATE INDEX task_dependencies_dependency_idx
ON task_dependencies(dependency_id);

CREATE INDEX task_dependencies_project_idx
ON task_dependencies(project_id);