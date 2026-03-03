create function public.on_project_task_accepted()
return trigger as $$
begin
    if new.status = 'accepted' then
        insert into public.project_members (id, project_id, task_id, user_id, role, status)
        values (
            new.metadata.project_id,
            new.metadata.task_id,
            new.notified_id, 
            new.metadata.role, 
            'accepted'
        )

        insert into public.conversations (id, project_id, task_id, title)
        values (
            new.metadata.task_id, 
            new.metadata.project_id,
            new.metadata.task_id,
            new.metadata.task_title
        )

        insert into public.conversation_participants (user_id, conversation_id)
        values ( new.notifier_id, new.metadata.task_id)

        insert into public.conversation_participants (user_id, conversation_id)
        values (new.notified_id, new.metadata.task_id)
    end if;
end;
$$ language plpgsql security definer;

create trigger add_task_assignee_as_project_member
    after update of status on public.notifications
    where type = 'task_assignement'
    for each row execute function public.on_project_task_accepted();