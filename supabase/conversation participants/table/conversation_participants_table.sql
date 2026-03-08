create table public.conversation_participants (
    conversation_id uuid references public.conversations(id) on delete cascade not null,
    user_id uuid references public.profiles(id) on delete cascade not null,
    last_message_at timestamptz,
    last_seen_at timestamptz,
    primary key (conversation_id, user_id)
);

alter table public.conversation_participants enable row level security;

create policy "View fellow participants"
on public.conversation_participants for select
to authenticated
using ( is_conversation_participant(conversation_id, auth.uid()) );