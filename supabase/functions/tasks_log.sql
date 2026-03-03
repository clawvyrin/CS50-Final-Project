create function public.send_task_log_message()
returns trigger as $$
begin
    insert into public.messages (conversation_id, sender_id, content, metdata)
    values (
        new.task_id,
        auth.uid(),
        'A daily summary has been uploaded',
        jsonb_build_object(
            "id": new.id,
        )
    )
end;
$$ language plpgsql security definer;

create trigger on_task_log_created
    after insert on public.daily_tasks_reports
    for each row execute function public.send_task_log_message();
