create table public.timeline_events (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade not null,
    user_id uuid references public.profiles(id) not null default auth.uid(),
    action_type text not null,
    content text not null,
    metadata jsonb default '{}'::jsonb,
    created_at timestamptz default now()
);

CREATE OR REPLACE VIEW timeline_event_view AS
SELECT
    te.id,

    -- Nested project object
    jsonb_build_object(
        'id', p.id,
        'name', p.name,
        'description', p.description
    ) AS project,

    -- Nested user object
    jsonb_build_object(
        'id', u.id,
        'display_name', u.display_name,
        'avatar_url', u.avatar_url
    ) AS user,

    te.action_type,
    te.content,
    te.meta_data,
    te.created_at

FROM timeline_events te
JOIN projects p
    ON p.id = te.project_id
JOIN profiles u
    ON u.id = te.user_id;

CREATE INDEX timeline_events_project_idx
ON timeline_events(project_id);

CREATE INDEX timeline_events_user_idx
ON timeline_events(user_id);

CREATE INDEX timeline_events_created_idx
ON timeline_events(created_at DESC);


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