create type notification_status as enum ('accepted','pending','denied','read', 'archived', 'clicked', 'dismissed');

create table public.notifications (
    id uuid primary key default gen_random_uuid(),
    type text not null,
    notifier_id uuid references public.profiles(id) on delete cascade not null,
    notified_id uuid references public.profiles(id) on delete cascade not null,
    status notification_status default 'pending',
    meta_data jsonb default '{}'::jsonb,
    seen_at timestamp with time zone default timezone('utc'::text, now()),
    created_at timestamp with time zone default timezone('utc'::text, now())
);

create index idx_notifications_notified_id on public.notifications(notified_id);
create index idx_notifications_metadata_gin on public.notifications using gin (meta_data);

alter table public.notifications enable row level security;

create policy "Users can manage notifications they receive"
on public.notifications for all
to authenticated
using ( auth.uid() = notified_id )
with check ( auth.uid() = notified_id );