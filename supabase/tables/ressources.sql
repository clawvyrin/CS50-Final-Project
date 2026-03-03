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


alter table public.resources enable row level security;

create policy "Manage project resources"
on public.resources for all
using (
  exists (
    select 1 from public.projects 
    where id = project_id and owner_id = auth.uid()
  )
);