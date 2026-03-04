create or replace function add_task_assignee_notification()
returns trigger as $$
begin
    insert into public.notifications (type, notifier_id, notified_id, meta_data)
    values (
        'task_assignment',
        auth.uid(),
        new.assigned_to,
        jsonb_build_object(
            'project_id', new.project_id,
            'task_id', new.id,
            'task_title', new.title
        )
    );
    return new;
end;
$$ language plpgsql security definer;

create trigger on_task_created
    after insert on public.tasks
    for each row execute function public.add_task_assignee_notification();