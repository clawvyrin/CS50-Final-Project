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
    p_desc text
)
returns public.projects 
language plpgsql 
security definer
set search_path = public
as $$
declare
    new_project public.projects;
begin
    insert into public.projects (name, description, owner_id)
    values (p_name, p_desc, auth.uid())
    returning * into new_project;

    return new_project;
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