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

CREATE OR REPLACE VIEW notification_details_view AS
SELECT
    n.id,
    n.type,

    jsonb_build_object(
        'id', p.id,
        'display_name', p.display_name,
        'avatar_url', p.avatar_url
    ) AS notitifer,

    n.notified_id,
    n.status,
    n.meta_data,
    n.seen_at,
    n.created_at

FROM notifications n
LEFT JOIN profiles p
    ON p.id = n.notifier_id;


CREATE INDEX notifications_notified_id_idx 
ON notifications(notified_id);

CREATE INDEX notifications_created_at_idx 
ON notifications(created_at DESC);

CREATE INDEX notifications_unseen_idx 
ON notifications(notified_id, seen_at) 
WHERE seen_at IS NULL;