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
end; $$;