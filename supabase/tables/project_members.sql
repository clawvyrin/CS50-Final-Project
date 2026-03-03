create type assignement_status as enum ('accepted', 'pending', 'denied', 'left', 'removed');

create table public.project_members (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade,
    user_id uuid references public.profiles(id) on delete cascade,
    role text default 'viewer', 
    status assignment_status default 'accepted',
    created_at timestamptz default now()
);

alter table public.project_members enable row level security;

create policy "Users can view members of projects they are part of"
on public.project_members for select
to authenticated
using (
   exists (
    select 1 from public.projects 
    where id = tasks.project_id and (owner_id = auth.uid() OR exists (
      select 1 from public.project_members pm where pm.project_id = projects.id and pm.user_id = auth.uid()
    ))
  )
);

create policy "Only project owners can manage their own projects members"
on public.project_members for all
to authenticated
using ( auth.uid() = owner_id );