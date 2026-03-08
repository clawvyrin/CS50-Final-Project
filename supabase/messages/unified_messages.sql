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

CREATE OR REPLACE VIEW message_view AS
SELECT
    m.id,
    m.conversation_id,

    -- Sender info
    jsonb_build_object(
        'id', p.id,
        'display_name', p.display_name,
        'avatar_url', p.avatar_url
    ) AS sender,

    m.type,

    -- Is the message from the current user
    (m.sender_id = auth.uid()) AS is_me,

    m.content,
    m.meta_data,
    m.created_at,

    -- Seen at for current user
    CASE
        WHEN m.created_at <= cp.last_seen_at THEN cp.last_seen_at
        ELSE NULL
    END AS seen_at

FROM messages m
JOIN profiles p
    ON p.id = m.sender_id

-- join the current user's conversation participant row to get last_seen_at
LEFT JOIN conversation_participants cp
    ON cp.conversation_id = m.conversation_id
   AND cp.user_id = auth.uid();

CREATE INDEX messages_conversation_created_idx
ON messages(conversation_id, created_at DESC);

CREATE INDEX messages_sender_idx
ON messages(sender_id);