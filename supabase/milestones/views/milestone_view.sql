CREATE OR REPLACE VIEW milestone_view AS
SELECT
    m.id,
    
    -- Project nested object
    jsonb_build_object(
        'id', p.id,
        'name', p.name,
        'description', p.description
    ) AS project,
    
    m.title,
    m.original_due_date,
    m.updated_due_date,
    m.status,
    m.created_at

FROM milestones m
JOIN projects p
    ON p.id = m.project_id;

CREATE INDEX milestones_project_idx
ON milestones(project_id);

CREATE INDEX milestones_due_date_idx
ON milestones(original_due_date);