create table public.messages (
    id uuid primary key default gen_random_uuid(),
    conversation_id uuid references public.conversations(id) on delete cascade not null,
    sender_id uuid references public.profiles(id) on delete cascade not null,
    content text not null,
    meta_data jsonb default '{}'::jsonb,
    created_at timestamptz default now()
);

alter table public.messages enable row level security;

create policy "View messages in my conversations"
on public.messages for select
to authenticated
using (
    exists (
        select 1 from public.conversation_participants 
        where conversation_id = messages.conversation_id and user_id = auth.uid()
    )
);

create policy "Only senders can manage their messages"
on public.messages for insert, update, delete
to authenticated
with check (
    sender_id = auth.uid() AND
    exists (
        select 1 from public.conversation_participants 
        where conversation_id = messages.conversation_id and user_id = auth.uid()
    )
);