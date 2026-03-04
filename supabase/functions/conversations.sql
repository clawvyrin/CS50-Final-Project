create or replace function public.is_conversation_participant(c_id uuid, u_id uuid)
returns boolean as $$
begin
  return exists (
        select 1 from public.conversation_participants cp
        where cp.conversation_id = c_id
        and cp.user_id = u_id
    );
end;
$$ language plpgsql security definer;

alter function public.is_conversation_participant(uuid, uuid)
set search_path = public;
alter function public.is_conversation_participant(uuid, uuid) stable;