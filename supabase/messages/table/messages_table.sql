create table public.messages (
    id uuid primary key default gen_random_uuid(),
    conversation_id uuid references public.conversations(id) on delete cascade not null,
    sender_id uuid references public.profiles(id) on delete cascade not null,
    content text not null,
    type text,
    meta_data jsonb default '{}'::jsonb,
    created_at timestamptz default now()
);

alter table public.messages enable row level security;

create policy "View messages in my conversations"
on public.messages for select
to authenticated
using ( is_conversation_participant(conversation_id, auth.uid()) );

create policy "Only senders can send messages"
on public.messages for insert
to authenticated
with check (
    sender_id = auth.uid() AND
    is_conversation_participant(conversation_id, auth.uid())
);

create policy "Only senders can update their messages"
on public.messages for update
to authenticated
using (
    sender_id = auth.uid() AND
    is_conversation_participant(conversation_id, auth.uid())
);

create policy "Only senders can delete their messages"
on public.messages for delete
to authenticated
using (
    sender_id = auth.uid() AND
    is_conversation_participant(conversation_id, auth.uid())
);