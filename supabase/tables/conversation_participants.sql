create table conversation_participants (
    user_id references public.profiles(id) on delete cascade not null,
    conversation_id references public.conversations(id) on delete cascade not null,
    created_at timestamptz default now()
);

alter table public.conversation_participants enable row level security;

create policy "View fellow participants"
on public.conversation_participants for select
to authenticated
using (
    exists (
        select 1 from public.conversation_participants cp
        where cp.conversation_id = conversation_participants.conversation_id 
        and cp.user_id = auth.uid()
    )
);