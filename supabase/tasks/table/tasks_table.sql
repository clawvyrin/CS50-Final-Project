create type weekday as enum ('mon','tue','wed','thu','fri','sat','sun');
create type public.task_status as enum ('todo', 'in_progress', 'done');

create table public.tasks (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade not null,
    title text not null,
    description text,
    status task_status default 'todo',
    assigned_to uuid references public.profiles(id),
    work_days weekday[] default '{mon,tue,wed,thu,fri}',
    shift_start_time time default '08:00:00',
    shift_end_time time default '18:00:00',
    due_date timestamptz default now()
);

create index idx_tasks_project_id on public.tasks(project_id);

alter table public.tasks enable row level security;

create policy "Project participants can view tasks"
on public.tasks for select
to authenticated
using ( is_project_member(project_id, auth.uid()) );

create policy "Only project owners can manage tasks of their projects"
on public.tasks for all
to authenticated
using ( is_project_owner(project_id, auth.uid()) )
with check ( is_project_owner(project_id, auth.uid()) );