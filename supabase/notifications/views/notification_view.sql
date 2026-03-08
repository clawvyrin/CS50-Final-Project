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