create table public.resources (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade not null,
    name text not null,
    type text not null, 
    allocated_amount numeric default 0,
    consumed_amount numeric default 0,
    unit text,
    created_at timestamptz default now()
);

create index idx_resources_project_id on public.resources(project_id);

alter table public.resources enable row level security;

create policy "Manage project resources"
on public.resources for all
using ( is_project_owner(project_id, auth.uid()) )
with check ( is_project_owner(project_id, auth.uid()) );