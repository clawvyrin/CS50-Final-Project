create type request_status as enum ('accepted', 'pending', 'denied');

create table notifications (
    id uuid primary key default gen_random_uuid()
    type text not null,
    notifier_id uuid references public.profiles(id) on delete cascade not null,
    notified_id uuid references public.profiles(id) on delete cascade not null,
    status request_status default 'pending',
    meta_data jsonb default '{}'::jsonb,
    seen_at timestamp with time zone default timezone('utc'::text, now()),
    created_at timestamp with time zone default timezone('utc'::text, now())
);

alter table public.notifications enable row level security;

create policy "Users can manage notifications they receive"
on public.notifications for select, update, delete
to authenticated
using (
    auth.uid() = notified_id
);