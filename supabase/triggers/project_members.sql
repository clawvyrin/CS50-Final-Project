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