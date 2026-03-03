create type project_status as enum ('hiatus', 'on_going', 'done');

-- TABLE PROJECTS
create table public.projects (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  owner_id uuid references public.profiles(id) on delete cascade not null default auth.uid(),
  status project_status default 'on_going',
  background_picture_url text,
  created_at timestamptz default now()
);

alter table public.projects enable row level security;

create policy "Users can view projects they are part of"
on public.projects for select
to authenticated
using (
  auth.uid() = owner_id 
  OR exists (
    select 1 from public.project_members 
    where project_id = projects.id and user_id = auth.uid()
  )
);

create policy "Owners manage projects"
on public.projects for all
to authenticated
using ( auth.uid() = owner_id );

-- PROJECT MEMBERS
create policy "Members can see each other"
on public.project_members for select
to authenticated
using (
  exists (
    select 1 from public.projects 
    where id = project_id and (owner_id = auth.uid() OR exists (
      select 1 from public.project_members pm where pm.project_id = projects.id and pm.user_id = auth.uid()
    ))
  )
);