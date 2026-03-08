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


CREATE OR REPLACE VIEW task_view AS
SELECT
    t.id,
    
    jsonb_build_object(
        'id', p.id,
        'name', p.name,
        'description', p.description
    ) AS project,

    t.conversation_id,
    t.title,
    t.description,
    t.status,

    -- Assignee
    jsonb_build_object(
        'id', a.id,
        'display_name', a.display_name,
        'avatar_url', a.avatar_url
    ) AS assignee,

    COALESCE(t.work_days, '{}') AS work_days,
    COALESCE(t.shift_start_time, '08:00:00') AS shift_start_time,
    COALESCE(t.shift_end_time, '18:00:00') AS shift_end_time,

    -- Affected resources
    COALESCE(
        (
            SELECT jsonb_agg(rv)
            FROM resource_view rv
            JOIN activity_resources ar ON ar.resource_id = rv.id
            JOIN activities act ON act.id = ar.activity_id
            WHERE act.task_id = t.id
        ),
        '[]'::jsonb
    ) AS affected_resources,

    -- Activities
    COALESCE(
        (
            SELECT jsonb_agg(av)
            FROM activity_view av
            WHERE av.task_id = t.id
        ),
        '[]'::jsonb
    ) AS activities,

    -- Reports
    COALESCE(
        (
            SELECT jsonb_agg(dtrv)
            FROM daily_task_report_view dtrv
            WHERE dtrv.task->>'id' = t.id
        ),
        '[]'::jsonb
    ) AS reports,

    -- Dependencies
    COALESCE(
        (
            SELECT jsonb_agg(td)
            FROM task_dependency_view td
            WHERE td.task->>'id' = t.id
        ),
        '[]'::jsonb
    ) AS dependencies,

    t.due_date,
    t.pending_reports_count

FROM tasks t
JOIN projects p ON p.id = t.project_id
JOIN profiles a ON a.id = t.assignee_id;


CREATE INDEX tasks_project_idx
ON tasks(project_id);

CREATE INDEX tasks_assignee_idx
ON tasks(assignee_id);

CREATE INDEX tasks_conversation_idx
ON tasks(conversation_id);


------------ CREATE_TASK
create or replace function public.create_task(
    p_project_id uuid,
    p_title text,
    p_description text,
    p_due_date timestamptz,
    p_assigned_to uuid default null,
    p_dependencies uuid[] default '{}'::uuid[]
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    new_task_id uuid;
    result jsonb;
begin

    if auth.uid() is null then
        raise exception 'Not authenticated';
    end if;

    if not exists (
        select 1
        from public.projects p
        where p.id = p_project_id
        and (
            p.owner_id = auth.uid()
            or exists (
                select 1
                from public.project_members pm
                where pm.project_id = p_project_id
                and pm.user_id = auth.uid()
            )
        )
    ) then
        raise exception 'Access denied';
    end if;

    insert into public.tasks (
        project_id,
        title,
        description,
        due_date,
        assigned_to,
        status
    )
    values (
        p_project_id,
        p_title,
        p_description,
        p_due_date,
        p_assigned_to,
        'to_do'
    )
    returning id into new_task_id;

    insert into public.add_task_dependencies (project_id, task_id, depends_on_task_id)
    select p_project_id, new_task_id, dep_id
    from unnest(p_dependencies) dep_id;

    select jsonb_build_object(
        'id', t.id,
        'project_id', t.project_id,
        'title', t.title,
        'description', t.description,
        'status', t.status,
        'assigned_to', t.assigned_to,
        'assignee_display_name', p.display_name,
        'assignee_avatar_url', p.avatar_url,
        'due_date', t.due_date,
        'work_days', t.work_days,
        'shift_start_time', t.shift_start_time,
        'shift_end_time', t.shift_end_time,
        'activities', '[]'::jsonb,
        'reports', '[]'::jsonb,
        'affected_resources', '[]'::jsonb,
        'dependencies', (
            select coalesce(jsonb_agg(d), '[]'::jsonb)
            from public.task_dependencies d
            where d.task_id = t.id
        )
    )
    into result
    from public.tasks t
    left join public.profiles p
        on p.id = t.assigned_to
    where t.id = new_task_id;

    return result;

end;
$$;

------------ GET_TASK_DETAILS
create or replace function public.get_task_details(p_task_id uuid)
returns jsonb
language plpgsql security definer
as $$
declare
    result jsonb;
begin
    select jsonb_build_object(
        'id', t.id,
        'project_id', t.project_id,
        'title', t.title,
        'description', t.description,
        'status', t.status,
        'assigned_to', t.assigned_to,
        'assignee_display_name', (select display_name from public.profiles where id = t.assigned_to),
        'assignee_avatar_url', (select avatar_url from public.profiles where id = t.assigned_to),
        'due_date', t.due_date,
        'shift_start_time', t.shift_start_time,
        'shift_end_time', t.shift_end_time,
        -- Agrégation des activités de la tâche
        'activities', (
            select coalesce(jsonb_agg(a), '[]'::jsonb) 
            from public.activities a where a.task_id = t.id
        ),
        -- Agrégation des ressources allouées à cette tâche
        'affected_resources', (
            select coalesce(jsonb_agg(r), '[]'::jsonb) 
            from public.resources r where r.task_id = t.id
        ),
        -- Agrégation des rapports journaliers
        'reports', (
            select coalesce(jsonb_agg(rep), '[]'::jsonb) 
            from public.daily_task_reports rep where rep.task_id = t.id
        ),
        -- Agrégation des dépendances
        'dependencies', (
            select coalesce(jsonb_agg(d), '[]'::jsonb) 
            from public.task_dependencies d where d.task_id = t.id
        )
    ) into result
    from public.tasks t
    where t.id = p_task_id;

    return result;
end; 
$$;


create or replace function add_task_assignee_notification()
returns trigger as $$
begin
    insert into public.notifications (type, notifier_id, notified_id, meta_data)
    values (
        'task_assignment',
        auth.uid(),
        new.assigned_to,
        jsonb_build_object(
            'project_id', new.project_id,
            'task_id', new.id,
            'task_title', new.title
        )
    );
    return new;
end;
$$ language plpgsql security definer;

create trigger on_task_created
    after insert on public.tasks
    for each row execute function public.add_task_assignee_notification();