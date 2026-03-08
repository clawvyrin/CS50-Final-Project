CREATE OR REPLACE VIEW conversation_participant_view AS
SELECT
    p.conversation_id,

    jsonb_build_object(
        'id', prf.id,
        'display_name', prf.display_name,
        'avatar_url', prf.avatar_url
    ) AS user,

    p.last_seen_at

FROM conversation_participants p
JOIN profiles prf
    ON prf.id = p.user_id;