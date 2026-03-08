create table public.conversations (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade,
    task_id uuid references public.tasks(id) on delete cascade,
    title text not null,
    updated_at timestamptz,
    created_at timestamptz default now()
);


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


alter table public.conversations enable row level security;

create policy "Participants can view conversations"
on public.conversations for select
to authenticated
using ( is_conversation_participant(id, auth.uid()) );

CREATE OR REPLACE VIEW conversation_view AS
SELECT
    c.id,
    c.title,
    c.created_at,
    c.updated_at,

    -- TASK (nullable)
    CASE
        WHEN t.id IS NULL THEN NULL
        ELSE jsonb_build_object(
            'id', t.id,
            'title', t.title,
            'description', t.description,
            'project', jsonb_build_object(
                'id', pr.id,
                'name', pr.name,
                'description', pr.description
            )
        )
    END AS task,

    -- LAST MESSAGE
    lm.last_message,

    -- PARTICIPANTS
    COALESCE(pt.participants, '[]'::jsonb) AS participants

FROM conversations c

LEFT JOIN tasks t
    ON t.id = c.task_id

LEFT JOIN projects pr
    ON pr.id = t.project_id


-- last message with computed seen_at
LEFT JOIN LATERAL (
    SELECT jsonb_build_object(
        'content', m.content,
        'type', m.type,
        'sent_at', m.created_at,
        'seen_at',
            CASE
                WHEN cp.last_seen_at >= m.created_at
                THEN cp.last_seen_at
                ELSE NULL
            END
    ) AS last_message
    FROM messages m
    LEFT JOIN conversation_participants cp
        ON cp.conversation_id = m.conversation_id
        AND cp.user_id = auth.uid()
    WHERE m.conversation_id = c.id
    ORDER BY m.created_at DESC
    LIMIT 1
) lm ON TRUE


-- participants list
LEFT JOIN LATERAL (
    SELECT jsonb_agg(
        jsonb_build_object(
            'conversation_id', p.conversation_id,
            'user', jsonb_build_object(
                'id', prf.id,
                'display_name', prf.display_name,
                'avatar_url', prf.avatar_url
            )
        )
    ) AS participants
    FROM conversation_participants p
    JOIN profiles prf
        ON prf.id = p.user_id
    WHERE p.conversation_id = c.id
) pt ON TRUE;


CREATE INDEX conversation_participants_conversation_idx
ON conversation_participants(conversation_id);

CREATE INDEX conversations_updated_idx
ON conversations(updated_at DESC);

CREATE INDEX conversation_participants_user_idx
ON conversation_participants(user_id, conversation_id);


create index idx_conversations_project_id 
on public.conversations(project_id);