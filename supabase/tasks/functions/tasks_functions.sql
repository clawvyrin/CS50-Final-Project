------------ CREATE_TASK
create or replace function public.create_task_with_details(
    project_id uuid,
    title text,
    description text,
    start_date timestamptz,
    due_date timestamptz,
    assigned_to uuid,
    dependencies jsonb,
    selected_activities jsonb
)
returns public.task_view
language plpgsql
security definer
set search_path = public
as $$
declare
    new_task_id uuid;

    dependency_record jsonb;
    activity_record jsonb;
    resource_record jsonb;

    new_activity_id uuid;
    new_resource_id uuid;

begin

--------------------------------------------------
-- 1️⃣ Create Task
--------------------------------------------------

insert into tasks (
    project_id,
    title,
    description,
    start_date,
    due_date,
    assigned_to
)
values (
    project_id,
    title,
    description,
    start_date,
    due_date,
    assigned_to
)
returning id into new_task_id;

--------------------------------------------------
-- 2️⃣ Insert Dependencies
--------------------------------------------------

for dependency_record in
    select * from jsonb_array_elements(dependencies)
loop

    insert into task_dependencies (
        task_id,
        dependency_task_id
    )
    values (
        new_task_id,
        (dependency_record ->> 'id')::uuid
    );

end loop;

--------------------------------------------------
-- 3️⃣ Create Activities
--------------------------------------------------

for activity_record in
    select * from jsonb_array_elements(selected_activities)
loop

    insert into activities (
        task_id,
        description
    )
    values (
        new_task_id,
        activity_record ->> 'description'
    )
    returning id into new_activity_id;

--------------------------------------------------
-- 4️⃣ Create Resources for this Activity
--------------------------------------------------

    for resource_record in
        select * from jsonb_array_elements(activity_record -> 'resources')
    loop

        insert into resources (
            project_id,
            name,
            type,
            amount
        )
        values (
            project_id,
            resource_record ->> 'name',
            resource_record ->> 'type',
            (resource_record ->> 'amount')::numeric
        )
        returning id into new_resource_id;

        insert into activity_resources (
            activity_id,
            resource_id
        )
        values (
            new_activity_id,
            new_resource_id
        );

    end loop;

end loop;

return (
        select t
        from task_view t
        where t.id = new_task_id
        limit 1
    );

end;
$$;


CREATE OR REPLACE FUNCTION check_task_immutability(
    task_id UUID, 
    new_title TEXT, 
    new_project_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    old_title TEXT;
    old_project_id UUID;
BEGIN
    SELECT title, project_id
    INTO old_title, old_project_id
    FROM public.tasks
    WHERE id = task_id;

    -- If task not found, return false
    IF old_title IS NULL OR old_project_id IS NULL THEN
        RETURN FALSE;
    END IF;

    RETURN (new_title = old_title AND new_project_id = old_project_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;