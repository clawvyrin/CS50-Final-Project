create or replace function public.submit_daily_report(
    p_task_id uuid,
    p_daily_summary text,
    p_start_time timestamptz,
    p_end_time timestamptz,
    p_activities jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
    new_report_id uuid;
    act_item jsonb;
    res_item jsonb;
    new_act_id uuid;
begin

    if auth.uid() is null then
        raise exception 'Not authenticated';
    end if;

    if p_end_time <= p_start_time then
        raise exception 'Invalid time range';
    end if;

    insert into public.daily_task_reports (
        task_id,
        user_id,
        daily_summary,
        start_time,
        end_time,
        is_signed,
        reported_at
    )
    values (
        p_task_id,
        auth.uid(),
        p_daily_summary,
        p_start_time,
        p_end_time,
        false,
        now()
    )
    returning id into new_report_id;

    for act_item in select * from jsonb_array_elements(p_activities)
    loop

        insert into public.activities (
            project_id,
            task_id,
            description,
            created_at
        )
        select project_id, p_task_id, act_item->>'description', now()
        from public.tasks
        where id = p_task_id
        returning id into new_act_id;

        if act_item ? 'resources' then

            for res_item in select * from jsonb_array_elements(act_item->'resources')
            loop

                insert into public.activity_resources (
                    activity_id,
                    resource_id,
                    amount_impacted
                )
                values (
                    new_act_id,
                    (res_item->>'id')::uuid,
                    (res_item->>'amount')::int
                );

            end loop;

        end if;

    end loop;

    return new_report_id;

end;
$$;