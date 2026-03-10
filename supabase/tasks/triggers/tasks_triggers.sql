CREATE OR REPLACE FUNCTION add_task_assignee_notification()
RETURNS trigger AS $$
DECLARE
    v_conversation_id uuid;
BEGIN

    -- create notification
    INSERT INTO public.notifications (type, notifier_id, notified_id, meta_data)
    VALUES (
        'task_assignment',
        auth.uid(),
        NEW.assigned_to,
        jsonb_build_object(
            'project_id', NEW.project_id,
            'task_id', NEW.id,
            'task_title', NEW.title
        )
    );

    -- create conversation and capture its id
    INSERT INTO public.conversations (title, project_id, task_id)
    VALUES (
        NEW.title,
        NEW.project_id,
        NEW.id
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

create trigger on_task_created
    after insert on public.tasks
    for each row execute function public.add_task_assignee_notification();