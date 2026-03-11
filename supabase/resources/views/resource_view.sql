CREATE OR REPLACE VIEW resource_view AS
SELECT
    r.id,
    jsonb_build_object(
        'id', p.id,
        'name', p.name,
        'description', p.description,
        'status', p.status
    ) AS project,
    r.name,
    r.type,
    r.allocated_amount,
    r.consumed_amount,
    r.unit,
    r.created_at
FROM resources r
JOIN projects p ON p.id = r.project_id;

CREATE INDEX resources_project_idx
ON resources(project_id);

CREATE INDEX resources_created_idx
ON resources(created_at);