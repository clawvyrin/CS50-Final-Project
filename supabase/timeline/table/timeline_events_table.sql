create table public.timeline_events (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade not null,
    user_id uuid references public.profiles(id) not null default auth.uid(),
    action_type text not null,
    content text not null,
    metadata jsonb default '{}'::jsonb,
    created_at timestamptz default now()
);

-- Active la RLS si ce n'est pas déjà fait
ALTER TABLE public.timeline_events ENABLE ROW LEVEL SECURITY;

-- Autorise l'insertion pour les utilisateurs authentifiés
CREATE POLICY "Users can insert their own timeline events"
ON public.timeline_events
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);