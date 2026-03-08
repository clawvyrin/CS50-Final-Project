create table public.daily_tasks_reports (
    id uuid primary key default gen_random_uuid(),
    task_id uuid references public.tasks(id) on delete cascade not null,
    user_id uuid references public.profiles(id) on delete cascade not null,
    daily_summary text,
    daily_activities jsonb default '{}'::jsonb,
    start_time timestamptz default now(),
    end_time timestamptz default now(),
    duration_minutes int generated always as (
        (extract(epoch from (end_time - start_time))/60)::int
    ) stored,
    is_signed boolean default false,
    reported_at date default current_date
);

create index idx_daily_reports_user_id on public.daily_tasks_reports(user_id);
create index idx_reports_activities_gin on public.daily_tasks_reports using gin (daily_activities);

alter table public.daily_tasks_reports enable row level security;

create policy "Assignees can manage their logs"
on public.daily_tasks_reports for all
to authenticated
using (
    exists (
        select 1 from public.tasks
        where tasks.id = task_id
        and tasks.assigned_to = auth.uid()
    )
);


CREATE OR REPLACE VIEW daily_task_report_view AS
SELECT
    dtr.id,
    
    -- Task nested
    jsonb_build_object(
        'id', t.id,
        'title', t.title,
        'description', t.description,
        'project', jsonb_build_object(
            'id', p.id,
            'name', p.name,
            'description', p.description
        )
    ) AS task,

    -- Submitted by user
    jsonb_build_object(
        'id', u.id,
        'display_name', u.display_name,
        'avatar_url', u.avatar_url
    ) AS submitted_by,

    dtr.daily_summary,
    dtr.daily_activities,
    dtr.start_time,
    dtr.end_time,
    dtr.duration_minutes,
    dtr.is_signed,
    dtr.reported_at

FROM daily_task_reports dtr
JOIN tasks t ON t.id = dtr.task_id
JOIN projects p ON p.id = t.project_id
JOIN profiles u ON u.id = dtr.submitted_by_id;

CREATE INDEX daily_task_reports_task_idx
ON daily_task_reports(task_id);

CREATE INDEX daily_task_reports_user_idx
ON daily_task_reports(submitted_by_id);

CREATE INDEX daily_task_reports_reported_at_idx
ON daily_task_reports(reported_at);


------------ SUBMIT_DAILY_REPORT_LOG
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

------------ CERTIFY_DAILY_REPORT
create or replace function public.certify_daily_report(p_report_id uuid)
returns void
language plpgsql security definer
as $$
declare
    v_project_id uuid;
begin
    select t.project_id into v_project_id
    from public.daily_task_reports r
    join public.tasks t on r.task_id = t.id
    where r.id = p_report_id;

    if not exists (
        select 1 from public.project_members
        where project_id = v_project_id 
        and user_id = auth.uid() 
        and role in ('admin', 'owner')
    ) then
        raise exception 'Seul un administrateur peut certifier ce rapport.';
    end if;

    update public.daily_task_reports
    set 
        is_signed = true,
        signed_at = now(),
        signed_by = auth.uid()
    where id = p_report_id;
end; $$;


create or replace function public.send_task_log_message()
returns trigger as $$
declare 
    conv_id uuid;
begin
    select id into conv_id
    from public.conversations
    where task_id = new.task_id;

    insert into public.messages (conversation_id, sender_id, content, meta_data)
    values (
        conv_id,
        new.user_id,
        'A new daily report has been uploaded',
        jsonb_build_object('report_id', new.id)
    );
    return new;
end;
$$ language plpgsql security definer;

create trigger on_task_log_created
    after insert on public.daily_tasks_reports
    for each row execute function public.send_task_log_message();