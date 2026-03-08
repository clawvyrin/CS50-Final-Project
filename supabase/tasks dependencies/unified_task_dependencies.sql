create table public.task_dependencies (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade not null,
    task_id uuid references public.tasks(id) on delete cascade not null,
    depends_on_task_id uuid references public.tasks(id) on delete cascade not null,
    created_at timestamptz default now()
);

alter table public.task_dependencies enable row level security;

create policy "Users can view tasks dependencies of project they are part of"
on public.task_dependencies for select
to authenticated
using ( is_project_member(project_id, auth.uid()) );

create policy "Only project owners can manage tasks dependencies"
on public.task_dependencies for all
to authenticated
using ( is_project_owner(project_id, auth.uid()) )
with check ( is_project_owner(project_id, auth.uid()) );

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