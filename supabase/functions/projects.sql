create or replace function public.is_project_member(p_id uuid, u_id uuid)
returns boolean
security definer stable
set search_path = public
as $$
begin
  return exists (
    select 1 
    from public.projects p
    where p.id = p_id 
    and (
      p.owner_id = u_id 
      or exists (
        select 1 
        from public.project_members pm 
        where pm.project_id = p_id 
        and pm.user_id = u_id 
        and pm.status = 'accepted'
      )
    )
  );
end;
$$;

alter function public.is_project_member(uuid, uuid) stable;


create or replace function public.is_project_owner(p_id uuid, u_id uuid)
returns boolean
security definer stable
set search_path = public
as $$
begin
  return exists (
        select 1 from projects
        where projects.id = p_id
        and projects.owner_id = u_id
    );
end;
$$;

alter function public.is_project_owner(uuid, uuid) stable;


create or replace function public.get_user_projects(
    anchor timestamptz, 
    n_projects int
)
returns setof public.projects
language plpgsql
security definer
stable
set search_path = public
as $$
begin
    return query
    select *
    from public.projects
    where owner_id = auth.uid()
      and created_at < anchor
    order by 
        (status = 'on_going') desc,
        created_at desc
    limit n_projects;
end;
$$;



create or replace function public.create_project(
    p_name text, 
    p_desc text, 
    p_start timestamptz, 
    p_end timestamptz
)
returns public.projects
language plpgsql
security definer
set search_path = public
as $$
declare
    new_proj public.projects;
begin
    insert into public.projects (
        name,
        description,
        start_date,
        end_date,
        owner_id
    )
    values (
        p_name,
        p_desc,
        p_start,
        p_end,
        auth.uid()
    )
    returning * into new_proj;

    return new_proj;
end;
$$;

create or replace function public.edit_project(updated_project public.projects)
returns public.projects 
language plpgsql 
security definer
set search_path = public
as $$
declare
  result public.projects
begin
  update public.projects
  set 
    name = updated_project.name,
    description = updated_project.description,
    status = updated_project.status,
    start_date = updated_project.start_date,
    end_date = updated_project.end_date,
    updated_at = now()
  where id = updated_project.id
    and owner_id = auth.uid()
  returning * into result;

  return result;
end;
$$;


create or replace function public.delete_project(p_id uuid)
returns void 
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.projects
  where id = p_id
    and owner_id = auth.uid();
end;
$$;

create or replace function public.get_project_details(p_id uuid)
returns jsonb
language plpgsql
security definer
stable
set search_path = public
as $$
declare
    result jsonb;
begin

    select jsonb_build_object(
        'id', p.id,
        'name', p.name,
        'description', p.description,
        'owner_id', p.owner_id,
        'owner_display_name', owner.display_name,
        'owner_avatar_url', owner.avatar_url,
        'status', p.status,
        'start_date', p.start_date,
        'end_date', p.end_date,

        'tasks', (
            select coalesce(jsonb_agg(task_data), '[]')
            from (
                select 
                    t.*,
                    assignee.display_name as assignee_display_name,
                    assignee.avatar_url as assignee_avatar_url,

                    (
                        select coalesce(jsonb_agg(act), '[]')
                        from public.activities act
                        where act.task_id = t.id
                    ) as activities,

                    (
                        select coalesce(jsonb_agg(rep), '[]')
                        from public.daily_task_reports rep
                        where rep.task_id = t.id
                    ) as reports,

                    (
                        select coalesce(jsonb_agg(dep), '[]')
                        from public.task_dependencies dep
                        where dep.task_id = t.id
                    ) as dependencies

                from public.tasks t
                left join public.profiles assignee
                    on assignee.id = t.assigned_to
                where t.project_id = p.id
            ) task_data
        ),

        'milestones', (
            select coalesce(jsonb_agg(m), '[]')
            from public.milestones m
            where m.project_id = p.id
        ),

        'resources', (
            select coalesce(jsonb_agg(r), '[]')
            from public.resources r
            where r.project_id = p.id
        ),

        'members', (
            select coalesce(jsonb_agg(mem), '[]')
            from public.project_members mem
            where mem.project_id = p.id
        )

    )
    into result
    from public.projects p
    left join public.profiles owner
        on owner.id = p.owner_id
    where p.id = p_id
    and (
        p.owner_id = auth.uid()
        or exists (
            select 1
            from public.project_members pm
            where pm.project_id = p.id
            and pm.user_id = auth.uid()
        )
    )
    limit 1;

    return coalesce(result, '{}'::jsonb);

end;
$$;