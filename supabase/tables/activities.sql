create table public.activities (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade not null,
    task_id uuid references public.tasks(id) on delete cascade, -- optionnel si l'activité est globale au projet
    user_id uuid references public.profiles(id) default auth.uid(), -- Qui a fait l'activité ?
    name text not null,
    description text,
    is_template boolean default true,
    created_at timestamptz default now()
);

-- Table de liaison pour les ressources impactées
create table public.activity_resources (
    activity_id uuid references public.activities(id) on delete cascade,
    resource_id uuid references public.resources(id) on delete cascade,
    amount_impacted numeric, -- ex: -50 pour un budget, +2 pour des unités
    primary key (activity_id, resource_id)
);