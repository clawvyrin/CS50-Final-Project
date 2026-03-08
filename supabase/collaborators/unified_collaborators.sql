create table collaborators (
    requested_by uuid references public.profiles(id) on delete cascade not null,
    requested_to uuid references public.profiles(id) on delete cascade not null,
    status request_status default 'pending',
    updated_at timestamp with time zone default timezone('utc'::text, now()),
    created_at timestamp with time zone default timezone('utc'::text, now()),
    primary key (requested_by, requested_to)
);

CREATE OR REPLACE VIEW collaborator_view AS
SELECT
    jsonb_build_object(
        'requested_by', jsonb_build_object(
            'id', rb.id,
            'display_name', rb.display_name,
            'avatar_url', rb.avatar_url
        ),
        'requested_to', jsonb_build_object(
            'id', rt.id,
            'display_name', rt.display_name,
            'avatar_url', rt.avatar_url
        ),
        'status', c.status,
        'created_at', c.created_at,
        'updated_at', c.updated_at
    ) AS collaborator

FROM collaborators c

JOIN profiles rb
    ON rb.id = c.requested_by_id

JOIN profiles rt
    ON rt.id = c.requested_to_id;

alter table public.collaborators enable row level security;

create policy "Users can view their own collaborations"
on public.collaborators for select
to authenticated
using ( auth.uid() = requested_by OR auth.uid() = requested_to );

create policy "Users can send requests"
on public.collaborators for insert
to authenticated
with check ( auth.uid() = requested_by );

create policy "Users can update their collaborations"
on public.collaborators for update
to authenticated
using ( auth.uid() = requested_by OR auth.uid() = requested_to );

create policy "Users can delete their collaborations"
on public.collaborators for delete
to authenticated
using ( auth.uid() = requested_by OR auth.uid() = requested_to );