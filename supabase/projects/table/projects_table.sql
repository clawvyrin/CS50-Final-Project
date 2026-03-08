create type public.project_status as enum ('hiatus', 'on_going', 'done');

-- TABLE PROJECTS
create table public.projects (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    description text,
    owner_id uuid references public.profiles(id) on delete cascade not null default auth.uid(),
    status project_status default 'on_going',
    background_picture_url text,
    start_date date,
    end_date date,
    updated_at timestamptz default now(),
    created_at timestamptz default now()
);

create index on projects(id, owner_id);

alter table public.projects enable row level security;

create policy "Users can view projects they are part of"
on public.projects for select
to authenticated
using (  is_project_member(id, auth.uid()) );

create policy "Owners manage projects"
on public.projects for all
to authenticated
using ( auth.uid() = owner_id );