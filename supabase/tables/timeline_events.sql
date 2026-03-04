create table public.timeline_events (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade not null,
    user_id uuid references public.profiles(id) not null default auth.uid(),
    action_type text not null,
    content text not null,
    metadata jsonb default '{}'::jsonb,
    created_at timestamptz default now()
);