--------------------------------------------------
--                                              --
--                     ENUMS                    --
--                                              --
--------------------------------------------------


create type project_role as enum ('admin','editor','viewer');
create type weekday as enum ('mon','tue','wed','thu','fri','sat','sun');
create type public.project_status as enum ('hiatus', 'on_going', 'done');
create type public.task_status as enum ('todo', 'in_progress', 'done');
create type public.milestone_status as enum ('onTrack', 'achieved', 'postponed');
create type public.request_status as enum ('accepted', 'pending', 'denied');
create type public.assignment_status as enum ('accepted', 'pending', 'denied', 'left', 'removed');
create type notification_status as enum ('accepted','pending','denied','read', 'archived', 'clicked', 'dismissed');


---------------------------------------------------
--                                               --
--                    TABLES                     --
--                                               --
---------------------------------------------------


create table public.profiles (
    id uuid references auth.users on delete cascade primary key,
    email text unique not null,
    first_name text not null,
    last_name text not null,
    display_name text not null,
    biography text,
    avatar_url text default 'https://firebasestorage.googleapis.com/v0/b/spittin-908cd.firebasestorage.app/o/profilepic%2Fdefault_avatar.jpg?alt=media&token=a44a6dd7-aaf5-41cf-934d-a7fd60a43d3c',
    updated_at timestamptz default now(),
    created_at timestamptz default now()
);

create table collaborators (
    requested_by uuid references public.profiles(id) on delete cascade not null,
    requested_to uuid references public.profiles(id) on delete cascade not null,
    status request_status default 'pending',
    updated_at timestamp with time zone default timezone('utc'::text, now()),
    created_at timestamp with time zone default timezone('utc'::text, now()),
    primary key (requested_by, requested_to)
);

create table public.projects (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    description text,
    owner_id uuid references public.profiles(id) on delete cascade not null default auth.uid(),
    status project_status default 'on_going',
    background_picture_url text,
    created_at timestamptz default now()
);

create table public.tasks (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade not null,
    title text not null,
    description text,
    status task_status default 'todo',
    assigned_to uuid references public.profiles(id),
    work_days weekday[] default '{mon,tue,wed,thu,fri}',
    shift_start_time time default '08:00:00',
    shift_end_time time default '18:00:00',
    due_date timestamptz default now()
);

create table public.milestones (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade not null,
    title text not null,
    original_due_date timestamptz not null,
    updated_due_date timestamptz,
    status milestone_status default 'onTrack',
    created_at timestamptz default now()
);

create table public.project_members (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade,
    user_id uuid references public.profiles(id) on delete cascade,
    role project_role default 'viewer', 
    status assignment_status default 'accepted',
    created_at timestamptz default now()
);

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

create table public.resources (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade not null,
    name text not null,
    type text not null, 
    allocated_amount numeric default 0,
    consumed_amount numeric default 0,
    unit text,
    created_at timestamptz default now()
);

create table public.task_dependencies (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade not null,
    task_id uuid references public.tasks(id) on delete cascade not null,
    depends_on_task_id uuid references public.tasks(id) on delete cascade not null,
    created_at timestamptz default now()
);

create table public.activities (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade not null,
    task_id uuid references public.tasks(id) on delete cascade,
    user_id uuid references public.profiles(id) default auth.uid(),
    name text not null,
    description text,
    created_at timestamptz default now()
);

create table public.activity_resources (
    activity_id uuid references public.activities(id) on delete cascade,
    resource_id uuid references public.resources(id) on delete cascade,
    amount_impacted numeric, -- ex: -50 pour un budget, +2 pour des unités
    primary key (activity_id, resource_id)
);

create table public.conversations (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade,
    task_id uuid references public.tasks(id) on delete cascade,
    title text not null,
    created_at timestamptz default now()
);

create table public.conversation_participants (
    conversation_id uuid references public.conversations(id) on delete cascade not null,
    user_id uuid references public.profiles(id) on delete cascade not null,
    primary key (conversation_id, user_id)
);

create table public.messages (
    id uuid primary key default gen_random_uuid(),
    conversation_id uuid references public.conversations(id) on delete cascade not null,
    sender_id uuid references public.profiles(id) on delete cascade not null,
    content text not null,
    meta_data jsonb default '{}'::jsonb,
    created_at timestamptz default now()
);

create table public.timeline_events (
    id uuid primary key default gen_random_uuid(),
    project_id uuid references public.projects(id) on delete cascade not null,
    user_id uuid references public.profiles(id) not null default auth.uid(),
    action_type text not null,
    content text not null,
    metadata jsonb default '{}'::jsonb,
    created_at timestamptz default now()
);

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


---------------------------------------------------
--                                               --
--            CONSTRAINTS AND INDEXES            --
--                                               --
---------------------------------------------------

create index on project_members(project_id, user_id);
create index on projects(id, owner_id);
create index idx_profiles_full_name on public.profiles(display_name);
create index idx_tasks_project_id on public.tasks(project_id);
create index idx_messages_conversation_date on public.messages(conversation_id, created_at desc);
create index idx_project_members_user on public.project_members(user_id);
create index idx_project_members_project on public.project_members(project_id);
create index idx_milestones_project_id on public.milestones(project_id);
create index idx_activities_project_id on public.activities(project_id);
create index idx_resources_project_id on public.resources(project_id);
create index idx_conversations_project_id on public.conversations(project_id);
create index idx_timeline_project_id on public.timeline_events(project_id);
create index idx_daily_reports_user_id on public.daily_tasks_reports(user_id);
create index idx_notifications_notified_id on public.notifications(notified_id);
create index idx_timeline_project_created on public.timeline_events(project_id, created_at desc);
create index idx_reports_date on public.daily_tasks_reports(reported_at desc);
create index idx_notifications_metadata_gin on public.notifications using gin (meta_data);
create index idx_reports_activities_gin on public.daily_tasks_reports using gin (daily_activities);
create unique index unique_task_conversationon on public.conversations(task_id) where task_id is not null;

alter table public.project_members 
add constraint unique_user_project unique (project_id, user_id);

alter table public.task_dependencies 
add constraint unique_task_dependency unique (task_id, depends_on_task_id);

alter table public.resources 
add constraint unique_resource_name_per_project unique (project_id, name);

-----------------------------------------------------
--                                                 --
--                     FUNCTIONS                   --
--                                                 --
-----------------------------------------------------

create or replace function public.is_project_member(p_id uuid, u_id uuid)
returns boolean as $$
begin
  return exists (
    select 1 
    from public.projects p
    where p.id = p_id 
    and (
      p.owner_id = u_id 
      or exists (
        select 1 
        from public.project_members pm 
        where pm.project_id = p_id 
        and pm.user_id = u_id 
        and pm.status = any (array['accepted','left']::assignment_status[])
      )
    )
  );
end;
$$ language plpgsql security definer;

alter function public.is_project_member(uuid, uuid)
set search_path = public;
alter function public.is_project_member(uuid, uuid) stable;


create or replace function public.is_conversation_participant(c_id uuid, u_id uuid)
returns boolean as $$
begin
  return exists (
        select 1 from public.conversation_participants cp
        where cp.conversation_id = c_id
        and cp.user_id = u_id
    );
end;
$$ language plpgsql security definer;

alter function public.is_conversation_participant(uuid, uuid)
set search_path = public;
alter function public.is_conversation_participant(uuid, uuid) stable;


create or replace function public.is_project_owner(p_id uuid, u_id uuid)
returns boolean as $$
begin
  return exists (
        select 1 from projects
        where projects.id = p_id
        and projects.owner_id = u_id
    );
end;
$$ language plpgsql security definer;

alter function public.is_project_owner(uuid, uuid)
set search_path = public;
alter function public.is_project_owner(uuid, uuid) stable;

---------------------------------------------------
--                                               --
--                ROW LEVEL SECURITY             --
--                                               --
---------------------------------------------------


------------------   PROFILES    ------------------

alter table public.profiles enable row level security;

create policy "Public profiles are viewable by everyone" 
on public.profiles for select 
to authenticated
using ( true );

create policy "Users can insert their own profile" 
on public.profiles for insert 
to authenticated
with check ( auth.uid() = id );

create policy "Users can update own profile" 
on public.profiles for update 
to authenticated
using ( auth.uid() = id );

create policy "Users can delete own profile" 
on public.profiles for delete 
to authenticated
using ( auth.uid() = id );

------------------   COLLABORATORS   ------------------

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

------------------   PROJECTS   ------------------

alter table public.projects enable row level security;

create policy "Users can view projects they are part of"
on public.projects for select
to authenticated
using (  is_project_member(id, auth.uid()) );

create policy "Owners manage projects"
on public.projects for all
to authenticated
using ( auth.uid() = owner_id );

------------------   TASKS   ------------------

alter table public.tasks enable row level security;

create policy "Project participants can view tasks"
on public.tasks for select
to authenticated
using ( is_project_member(project_id, auth.uid()) );

create policy "Only project owners can manage tasks of their projects"
on public.tasks for all
to authenticated
using ( is_project_owner(project_id, auth.uid()) )
with check ( is_project_owner(project_id, auth.uid()) );

------------------   MILESTONES   ------------------

alter table public.milestones enable row level security;

create policy "Project owners can manage milestones of their projects"
on public.milestones for all
to authenticated
using ( is_project_owner(project_id, auth.uid()) )
with check ( is_project_owner(project_id, auth.uid()) );

------------------   PROJECT MEMBERS   ------------------

alter table public.project_members enable row level security;

create policy "Users can view members of projects they are part of"
on public.project_members for select
to authenticated
using (  is_project_member(project_id, auth.uid()) );

create policy "Only project owners can manage their own projects members"
on public.project_members for all
to authenticated
using ( is_project_owner(project_id, auth.uid()) )
with check ( is_project_owner(project_id, auth.uid()) );

------------------   DAILY TASK REPORTS   ------------------

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

------------------   RESSOURCES   ------------------

alter table public.resources enable row level security;

create policy "Manage project resources"
on public.resources for all
using ( is_project_owner(project_id, auth.uid()) )
with check ( is_project_owner(project_id, auth.uid()) );

------------------   RESSOURCES   ------------------

alter table public.task_dependencies enable row level security;

create policy "Users can view tasks dependencies of project they are part of"
on public.task_dependencies for select
to authenticated
using ( is_project_member(project_id, auth.uid()) );

create policy "Only project owners can manage tasks dependencies"
on public.task_dependencies for all
to authenticated
using ( is_project_owner(project_id, auth.uid()) )
with check ( is_project_owner(project_id, auth.uid()) );

------------------   CONVERSATIONS   ------------------

alter table public.conversations enable row level security;

create policy "Participants can view conversations"
on public.conversations for select
to authenticated
using ( is_conversation_participant(id, auth.uid()) );

------------------   CONVERSATIONS PARTICIPANTS   ------------------

alter table public.conversation_participants enable row level security;

create policy "View fellow participants"
on public.conversation_participants for select
to authenticated
using ( is_conversation_participant(conversation_id, auth.uid()) );

------------------   MESSAGES   ------------------

alter table public.messages enable row level security;

create policy "View messages in my conversations"
on public.messages for select
to authenticated
using ( is_conversation_participant(conversation_id, auth.uid()) );

create policy "Only senders can send messages"
on public.messages for insert
to authenticated
with check (
    sender_id = auth.uid() AND
    is_conversation_participant(conversation_id, auth.uid())
);

create policy "Only senders can update their messages"
on public.messages for update
to authenticated
using (
    sender_id = auth.uid() AND
    is_conversation_participant(conversation_id, auth.uid())
);

create policy "Only senders can delete their messages"
on public.messages for delete
to authenticated
using (
    sender_id = auth.uid() AND
    is_conversation_participant(conversation_id, auth.uid())
);

------------------   NOTIFICATIONS   ------------------

alter table public.notifications enable row level security;

create policy "Users can manage notifications they receive"
on public.notifications for all
to authenticated
using ( auth.uid() = notified_id )
with check ( auth.uid() = notified_id );


-----------------------------------------------------
--                                                 --
--                      TRIGGERS                   --
--                                                 --
-----------------------------------------------------

------------------   PROFILES   ------------------

create or replace function public.handle_user_data()
returns trigger as $$
begin
    IF (TG_OP = 'INSERT') then
        insert into public.profiles (id, email, first_name, last_name, display_name, biography)
        values (
            new.id, 
            new.email, 
            new.raw_user_meta_data->>'first_name', 
            new.raw_user_meta_data->>'last_name',
            new.raw_user_meta_data->>'display_name', 
            new.raw_user_meta_data->>'biography'
        );
    ELSIF (TG_OP = 'UPDATE') then
        update public.profiles
        set first_name = new.raw_user_meta_data->>'first_name',
            last_name = new.raw_user_meta_data->>'last_name',
            display_name = new.raw_user_meta_data->>'display_name',
            biography = new.raw_user_meta_data->>'biography',
            avatar_url = new.raw_user_meta_data->>'avatar_url',
            updated_at = now()
        where id = new.id;
    end if;
    return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_changed
    after insert or update on auth.users
    for each row execute function public.handle_user_data();


create or replace function public.handle_auth_email_update()
returns trigger as $$
begin
  update public.profiles
  set email = new.email
  where id = new.id;
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_email_updated
  after update of email on auth.users
  for each row execute function public.handle_auth_email_update();


create or replace function public.handle_update_timestamp()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

create trigger on_profile_updated
    before update on public.profiles
    for each row execute function public.handle_update_timestamp();

------------------   PROJECT MEMBERS   ------------------

create or replace function public.on_project_task_accepted()
returns trigger as $$
declare 
    conv_id uuid;
begin
    if new.status = 'accepted' then
        -- Insertion membre
        insert into public.project_members (project_id, user_id, role, status)
        values (
            (new.meta_data->>'project_id')::uuid,
            new.notified_id, 
            coalesce(new.meta_data->>'role', 'viewer'), 
            'accepted'
        ) 
        on conflict (project_id, user_id) do nothing;

        -- Insertion conversation (on utilise l'ID de la tâche comme ID de conv)
        insert into public.conversations (project_id, task_id, title)
        values (
            (new.meta_data->>'project_id')::uuid,
            (new.meta_data->>'task_id')::uuid,
            new.meta_data->>'task_title'
        ) 
        on conflict (task_id) do update set title = excluded.title
        returning id into conv_id;

        -- Participants
        if conv_id is not null then
            insert into public.conversation_participants (user_id, conversation_id)
            values 
                (new.notifier_id, conv_id),
                (new.notified_id, conv_id)
            on conflict (conversation_id, user_id) do nothing;
        end if;
    end if;
    return new;
end;
$$ language plpgsql security definer;

create trigger add_task_assignee_as_project_member
    after update of status on public.notifications
    for each row 
    when (
        NEW.type = 'task_assignment'
        and NEW.status = 'accepted'
        and OLD.status is distinct from 'accepted'
    )
    execute function public.on_project_task_accepted();

------------------   PROJECTS   ------------------

create or replace function public.add_admin_as_project_member()
returns trigger as $$
begin
    insert into public.project_members (id, project_id, user_id, role, status)
    values (gen_random_uuid(), new.id, auth.uid(), 'admin', 'accepted');
    return new;
end;
$$ language plpgsql security definer;

create trigger on_project_created_add_admin
    after insert on public.projects
    for each row execute function public.add_admin_as_project_member();
    
------------------   RESSOURCES   ------------------

create or replace function public.update_ressources()
returns trigger as $$
declare
    activity_record record;
    resource_record record;
    factor int; -- 1 pour ajouter, -1 pour soustraire
begin
    -- On détermine si on ajoute ou on retire
    IF (new.is_signed = true AND (old.is_signed = false OR old.is_signed IS NULL)) THEN
        factor := 1;
    ELSIF (new.is_signed = false AND old.is_signed = true) THEN
        factor := -1;
    ELSE
        -- Si rien ne change sur la signature, on ne fait rien pour éviter les doublons
        return new;
    END IF;

    -- 1. Loop sur les activités
    for activity_record in 
        select * from jsonb_to_recordset(new.daily_activities) 
        as x(affected_resources jsonb)
    loop
        -- 2. Loop sur les ressources de chaque activité
        if activity_record.affected_resources is not null then
            for resource_record in 
                select * from jsonb_to_recordset(activity_record.affected_resources) 
                as r(id uuid, consumed_amount numeric)
            loop
                -- 3. Mise à jour (Ajout si factor=1, Soustraction si factor=-1)
                update public.resources
                set consumed_amount = consumed_amount + (resource_record.consumed_amount * factor)
                where id = resource_record.id;
            end loop;
        end if;
    end loop;

    -- 4. Mise à jour de la ressource "Temps / Main d'oeuvre"
    update public.resources
    set consumed_amount = consumed_amount + (new.duration_minutes * factor)
    where project_id = (select project_id from public.tasks where id = new.task_id)
    and type = 'human';

    return new;
end;
$$ language plpgsql security definer;

create trigger on_task_log_signed
    after update of is_signed on public.daily_tasks_reports
    for each row execute function public.update_ressources();

------------------   TASKS   ------------------

create or replace function add_task_assignee_notification()
returns trigger as $$
begin
    insert into public.notifications (type, notifier_id, notified_id, meta_data)
    values (
        'task_assignment',
        auth.uid(),
        new.assigned_to,
        jsonb_build_object(
            'project_id', new.project_id,
            'task_id', new.id,
            'task_title', new.title
        )
    );
    return new;
end;
$$ language plpgsql security definer;

create trigger on_task_created
    after insert on public.tasks
    for each row execute function public.add_task_assignee_notification();

------------------   DAILY TASKS REPORTS   ------------------

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

------------------   TIMELINE EVENTS   ------------------

create or replace function log_new_project()
returns trigger as $$
begin
  insert into public.timeline_events (project_id, user_id, action_type, content)
  values (new.id, auth.uid(), 'project_created', 'Project "' || new.name || '" created');
  return new;
end;
$$ language plpgsql;

create trigger on_project_created_log_event
  after insert on public.projects
  for each row execute function log_new_project();

create or replace function log_milestone_update()
returns trigger as $$
begin
    if (old.status is distinct from new.status) then
        insert into public.timeline_events (project_id, user_id, action_type, content, metadata)
        values (
            old.project_id, 
            auth.uid(), 
            'milestone_updated', 
            'Milestone "' || old.title || '" changed to ' || new.status,
            jsonb_build_object(
                'old_status', old.status,
                'new_status', new.status,
                'milestone_id', old.id
            )
        );
    end if;
    return new;
end;
$$ language plpgsql;

create trigger on_milestone_updated
  after update of status on public.milestones
  for each row execute function log_milestone_update();