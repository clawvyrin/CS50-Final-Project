create or replace function public.send_task_log_message()
returns trigger as $$
declare 
    conv_id uuid;
begin
    select id into conv_id
    from public.conversations
    where task_id = new.task_id;

    insert into public.messages (conversation_id, sender_id, content, meta_data)
    values (
        conv_id,
        new.user_id,
        'A new daily report has been uploaded',
        jsonb_build_object('report_id', new.id)
    );
    return new;
end;
$$ language plpgsql security definer;

create trigger on_task_log_created
    after insert on public.daily_tasks_reports
    for each row execute function public.send_task_log_message();