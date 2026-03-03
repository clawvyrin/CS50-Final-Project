create type task_status as enum ('todo', 'in_progress', 'done');

-- TABLE TASKS
create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references public.projects(id) on delete cascade not null,
  title text not null,
  description text,
  status task_status default 'todo',
  assigned_to uuid references public.profiles(id),
  work_days text[] default '{Monday, Tuesday, Wednesday, Thursday, Friday}',
  shift_start_time time default '08:00:00';
  shift_end_time time default '18:00:00';
  due_date timestamp with time zone default timezone('utc'::text, now())
);

alter table public.tasks enable row level security;

create policy "Project participants can view tasks"
on public.tasks for select
to authenticated
using (
  exists (
    select 1 from public.projects 
    where id = tasks.project_id and (owner_id = auth.uid() OR exists (
      select 1 from public.project_members pm where pm.project_id = projects.id and pm.user_id = auth.uid()
    ))
  )
);

create policy "Only project owners can manage tasks of their projects"
on public.tasks for insert, delete, update
to authenticated
using (
  exists (
    select 1 from public.projects 
    where id = tasks.project_id and owner_id = auth.uid()
  )
);
