create table public.conversations (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade,
    task_id uuid references public.tasks(id) on delete cascade,
    title text not null,
    updated_at timestamptz,
    created_at timestamptz default now()
);

create index idx_conversations_project_id on public.conversations(project_id);

alter table public.conversations enable row level security;

create policy "Participants can view conversations"
on public.conversations for select
to authenticated
using ( is_conversation_participant(id, auth.uid()) );