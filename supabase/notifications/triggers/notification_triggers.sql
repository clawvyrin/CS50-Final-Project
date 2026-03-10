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



create extension if not exists pg_net;
create or replace function public.on_new_notification_push()
returns trigger
language plpgsql
security definer
as $$
begin
  perform net.http_post(
    url := 'https://<project_url>.supabase.co/functions/v1/smart-responder',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')
    ),
    body := jsonb_build_object(
      'record', row_to_json(new)
    )
  );

  return new;
end;
$$;

create trigger trigger_push_notification
after insert on public.notifications
for each row
execute function public.on_new_notification_push();