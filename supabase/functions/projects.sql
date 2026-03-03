create function public.on_project_created()
return trigger as $$
begin
    insert into public.project_members (id, project_id, user_id, role, status)
    values (gen_random_uuid(), new.id, auth.uid(), 'admin', 'accepted');
end;
$$ language plpgsql security definer;

create trigger add_admin_as_project_member
    after insert on public.projects
    for each row execute function public.on_project_created();