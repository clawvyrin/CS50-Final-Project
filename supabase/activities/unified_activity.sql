create table public.activities (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade not null,
    task_id uuid references public.tasks(id) on delete cascade,
    user_id uuid references public.profiles(id) default auth.uid(),
    name text not null,
    description text,
    created_at timestamptz default now()
);

create table public.activity_resources (
    activity_id uuid references public.activities(id) on delete cascade,
    resource_id uuid references public.resources(id) on delete cascade,
    amount_impacted numeric,
    primary key (activity_id, resource_id)
);

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

create index idx_activities_project_id 
on public.activities(project_id);