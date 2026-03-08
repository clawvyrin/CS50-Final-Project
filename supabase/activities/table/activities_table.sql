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


create index idx_activities_project_id on public.activities(project_id);