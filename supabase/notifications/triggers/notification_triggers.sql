create or replace function public.handle_notification_status_change()
returns trigger as $$
begin
  if new.meta_data->>'status' = 'accepted' then
    
    if new.type = 'collaboration_request' then
      insert into public.collaborators (requested_by, requested_to, status)
      values (
        new.notifier_id,
        new.notified_id,
        'accepted'
      ) on conflict do nothing;

    elsif new.type = 'project_collaboration_request' then
      insert into public.project_members (project_id, user_id, role)
      values (
        (new.meta_data->>'project_id')::uuid,
        new.notifier_id,
        'viewer'
      ) on conflict do nothing;

    end if;

  end if;

  return new;
end;
$$ language plpgsql;

create trigger on_notification_status_update
after update of meta_data on public.notifications
for each row
when (old.meta_data->>'status' is distinct from new.meta_data->>'status')
execute function public.handle_notification_status_change();