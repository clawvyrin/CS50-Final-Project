create or replace function public.add_admin_as_project_member()
returns trigger as $$
begin
    insert into public.project_members (id, project_id, user_id, role, status)
    values (gen_random_uuid(), new.id, auth.uid(), 'admin', 'accepted');
    return new;
end;
$$ language plpgsql security definer;

create trigger on_project_created_add_admin
    after insert on public.projects
    for each row execute function public.add_admin_as_project_member();