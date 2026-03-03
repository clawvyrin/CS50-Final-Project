create table public.task_dependencies (
    project_id uuid references public.projects(id) on delete cascade not null,
    task_id  references public.tasks(id) on delete cascade not null,
    depends_on_task_id references public.tasks(id) on delete cascade not null,
    created_at timestamptz default now()
);

alter table public.task_dependencies enable row level security;

create policy "Users can view tasks dependencies of project they are part of"
on public.task_dependencies for select
to authenticated
using (
    exists (
    select 1 from public.projects 
    where project_id = projects.id and (owner_id = auth.uid() OR exists (
      select 1 from public.project_members pm where pm.project_id = projects.id and pm.user_id = auth.uid()
    ))
  )
);

create policy "Only project owners can manage tasks dependencies"
on public.task_dependencies for all
to authenticated
using (
    exists (
        select 1 from projects
        where projects.id = project_id
        and projects.owner_id = auth.uid()
    )
);