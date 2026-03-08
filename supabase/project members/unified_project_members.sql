create type public.assignment_status as enum ('accepted', 'pending', 'denied', 'left', 'removed');

create table public.project_members (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade,
    user_id uuid references public.profiles(id) on delete cascade,
    role project_role default 'viewer', 
    status assignment_status default 'accepted',
    created_at timestamptz default now()
);

create index idx_project_members_user on public.project_members(user_id);
create index idx_project_members_project on public.project_members(project_id);
create index on project_members(project_id, user_id);

alter table public.project_members enable row level security;

create policy "Users can view members of projects they are part of"
on public.project_members for select
to authenticated
using (  is_project_member(project_id, auth.uid()) );

create policy "Only project owners can manage their own projects members"
on public.project_members for all
to authenticated
using ( is_project_owner(project_id, auth.uid()) )
with check ( is_project_owner(project_id, auth.uid()) );


CREATE OR REPLACE VIEW project_member_view AS
SELECT
    pm.id,
    pm.project_id,

    -- Nested user object
    jsonb_build_object(
        'id', u.id,
        'display_name', u.display_name,
        'avatar_url', u.avatar_url
    ) AS user,

    pm.job_description,
    pm.role,
    pm.status,
    pm.created_at

FROM project_members pm
JOIN profiles u
    ON u.id = pm.user_id;

CREATE INDEX project_members_project_idx
ON project_members(project_id);

CREATE INDEX project_members_user_idx
ON project_members(user_id);


create or replace function public.on_project_task_accepted()
returns trigger as $$
declare 
    conv_id uuid;
begin
    if new.status = 'accepted' then
        -- Insertion membre
        insert into public.project_members (project_id, user_id, role, status)
        values (
            (new.meta_data->>'project_id')::uuid,
            new.notified_id, 
            coalesce(new.meta_data->>'role', 'viewer'), 
            'accepted'
        ) 
        on conflict (project_id, user_id) do nothing;

        -- Insertion conversation (on utilise l'ID de la tâche comme ID de conv)
        insert into public.conversations (project_id, task_id, title)
        values (
            (new.meta_data->>'project_id')::uuid,
            (new.meta_data->>'task_id')::uuid,
            new.meta_data->>'task_title'
        ) 
        on conflict (task_id) do update set title = excluded.title
        returning id into conv_id;

        -- Participants
        if conv_id is not null then
            insert into public.conversation_participants (user_id, conversation_id)
            values 
                (new.notifier_id, conv_id),
                (new.notified_id, conv_id)
            on conflict (conversation_id, user_id) do nothing;
        end if;
    end if;
    return new;
end;
$$ language plpgsql security definer;

create trigger add_task_assignee_as_project_member
    after update of status on public.notifications
    for each row 
    when (
        NEW.type = 'task_assignment'
        and NEW.status = 'accepted'
        and OLD.status is distinct from 'accepted'
    )
    execute function public.on_project_task_accepted();