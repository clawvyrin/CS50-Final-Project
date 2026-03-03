create table public.daily_tasks_reports (
    id uuid primary key default gen_random_uuid(),
    task_id uuid references public.tasks(id) on delete cascade not null,
    user_id uuid references public.profiles(id) on delete cascade not null,
    daily_summary text,
    daily_activities jsonb default '{}'::jsonb,
    start_time timestamptz default now(),
    end_time timestamptz default now(),
    duration_minutes int generated always as (
        (extract(epoch from (end_time - start_time))/60)::int
    ) stored,
    is_signed boolean default false,
    reported_at date default current_date
);

alter table public.tasks enable row level security;

create policy "Assignees can manage their logs"
on public.daily_tasks_reports for all
to authenticated
using (
    exists (
        select 1 from public.tasks
        where tasks.id = task_id
        and tasks.assigned_to = auth.uid()
    )
);