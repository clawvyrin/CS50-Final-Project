create table conversations (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade not null,
    task_id uuid references public.tasks(id) on delete cascade not null,
    title text references public.tasks(title) on delete cascade not null,
    created_at timestamptz default now()
);


alter table public.conversations enable row level security;

create policy "Participants can view conversations"
on public.conversations for select
to authenticated
using (
    exists (
        select 1 from public.conversation_participants 
        where conversation_id = conversations.id and user_id = auth.uid()
    )
);