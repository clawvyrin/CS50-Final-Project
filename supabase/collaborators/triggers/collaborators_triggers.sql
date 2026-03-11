create or replace function public.on_collaborator_request()
returns trigger
language plpgsql
as $$
begin
    insert into public.notifications (type, notifier_id, notified_id)
    values (
        'collaboration_request',
        new.requested_by,
        new.requested_to
    );

    return new;
end;
$$;

create trigger on_collaborator_request
after insert on public.collaborators
for each row
execute function public.on_collaborator_request();