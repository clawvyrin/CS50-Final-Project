create type public.assignment_status as enum ('accepted', 'pending', 'denied', 'left', 'removed');

create table public.project_members (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade,
    user_id uuid references public.profiles(id) on delete cascade,
    role project_role default 'viewer', 
    status assignment_status default 'accepted',
    created_at timestamptz default now()
);

create index idx_project_members_user on public.project_members(user_id);
create index idx_project_members_project on public.project_members(project_id);
create index on project_members(project_id, user_id);

alter table public.project_members enable row level security;

create policy "Users can view members of projects they are part of"
on public.project_members for select
to authenticated
using (  is_project_member(project_id, auth.uid()) );

create policy "Only project owners can manage their own projects members"
on public.project_members for all
to authenticated
using ( is_project_owner(project_id, auth.uid()) )
with check ( is_project_owner(project_id, auth.uid()) );