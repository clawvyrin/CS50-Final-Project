create type weekday as enum ('mon','tue','wed','thu','fri','sat','sun');
create type public.task_status as enum ('todo', 'in_progress', 'done');

CREATE TABLE public.tasks (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    project_id uuid
        REFERENCES public.projects(id)
        ON DELETE CASCADE
        NOT NULL,

    title text NOT NULL,
    description text,

    status task_status DEFAULT 'todo',

    assigned_to uuid
        REFERENCES public.profiles(id),

    work_days weekday[] DEFAULT '{mon,tue,wed,thu,fri}',

    shift_start_time time DEFAULT '08:00:00',
    shift_end_time time DEFAULT '18:00:00',

    progression double precision DEFAULT 0
        CHECK (progression >= 0 AND progression <= 100),

    due_date timestamptz,
    estimated_start_date timestamptz,


    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
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

CREATE POLICY "Assignee can update limited fields"
ON public.tasks
FOR UPDATE
USING (auth.uid() = assigned_to)
WITH CHECK (
    check_task_immutability(id, title, project_id)
);