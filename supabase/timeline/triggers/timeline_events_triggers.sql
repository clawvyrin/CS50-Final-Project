create or replace function log_new_project()
returns trigger as $$
begin
  insert into public.timeline_events (project_id, user_id, action_type, content)
  values (new.id, auth.uid(), 'project_created', 'Project "' || new.name || '" created');
  return new;
end;
$$ language plpgsql;

create trigger on_project_created_log_event
  after insert on public.projects
  for each row execute function log_new_project();

create or replace function log_milestone_update()
returns trigger as $$
begin
    if (old.status is distinct from new.status) then
        insert into public.timeline_events (project_id, user_id, action_type, content, metadata)
        values (
            old.project_id, 
            auth.uid(), 
            'milestone_updated', 
            'Milestone "' || old.title || '" changed to ' || new.status,
            jsonb_build_object(
                'old_status', old.status,
                'new_status', new.status,
                'milestone_id', old.id
            )
        );
    end if;
    return new;
end;
$$ language plpgsql;

create trigger on_milestone_updated
  after update of status on public.milestones
  for each row execute function log_milestone_update();