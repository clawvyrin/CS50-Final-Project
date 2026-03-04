create or replace function public.is_project_member(p_id uuid, u_id uuid)
returns boolean as $$
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
        and pm.status = any (array['accepted','left']::assignment_status[])
      )
    )
  );
end;
$$ language plpgsql security definer;

alter function public.is_project_member(uuid, uuid)
set search_path = public;
alter function public.is_project_member(uuid, uuid) stable;



create or replace function public.is_project_owner(p_id uuid, u_id uuid)
returns boolean as $$
begin
  return exists (
        select 1 from projects
        where projects.id = p_id
        and projects.owner_id = u_id
    );
end;
$$ language plpgsql security definer;

alter function public.is_project_owner(uuid, uuid)
set search_path = public;
alter function public.is_project_owner(uuid, uuid) stable;