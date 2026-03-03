create type milestone_status as enum ('onTrack', 'achieved', 'postponed');

-- TABLE MILESTONES
create table public.milestones (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references public.projects(id) on delete cascade not null,
  title text not null,
  original_due_date timestamptz not null,
  updated_due_date timestamptz,
  status milestone_status default 'onTrack'
);

alter table public.milestones enable row level security;

create policy "Users can manage milestones of their projects"
on public.milestones for all
to authenticated
using (
  exists (
    select 1 from public.projects 
    where id = milestones.project_id and owner_id = auth.uid()
  )
);