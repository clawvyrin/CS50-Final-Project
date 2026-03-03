create table collaborators (
    requested_by uuid references public.profiles(id) on delete cascade not null,
    requested_to uuid references public.profiles(id) on delete cascade not null,
    status  request_status default 'pending',
    updated_at timestamp with time zone default timezone('utc'::text, now()),
    created_at timestamp with time zone default timezone('utc'::text, now()) 
);

alter table public.collaborators enable row level security;

create policy "Users can view their own collaborations"
on public.collaborators for select
to authenticated
using ( auth.uid() = requested_by OR auth.uid() = requested_to );

create policy "Users can send requests"
on public.collaborators for insert
to authenticated
with check ( auth.uid() = requested_by );

create policy "Users can update/delete their collaborations"
on public.collaborators for update, delete
to authenticated
using ( auth.uid() = requested_by OR auth.uid() = requested_to );