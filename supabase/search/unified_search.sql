------------ USER_SEARCH
create or replace function public.search_my_collaborators(p_query text)
returns table (
    id uuid,
    display_name text,
    avatar_url text,
    conversation_id uuid
) as $$
begin
    return query
    select 
        p.id, 
        p.display_name, 
        p.avatar_url,
        cm.conversation_id
    from public.profiles p
    join public.conversation_members cm on cm.user_id = p.id
    where cm.conversation_id in (
        select conv_m.conversation_id 
        from public.conversation_members conv_m
        join public.conversations c on conv_m.conversation_id = c.id
        where conv_m.user_id = auth.uid() 
        and c.type = 'dm'
    )
    and p.id != auth.uid()
    and p.display_name ilike '%' || p_query || '%';
end; $$ language plpgsql;


------------ PROJECT_SEARCH
create or replace function public.search_my_projects(p_query text)
returns setof public.projects as $$
begin
    return query
    select pr.* from public.projects pr
    where pr.id in (select project_id from public.project_members where user_id = auth.uid())
    and pr.name ilike '%' || p_query || '%';
end; $$ language plpgsql;

------------ TASK_SEARCH
create or replace function public.search_my_tasks(p_query text)
returns setof public.tasks as $$
begin
    return query
    select pr.* from public.projects pr
    where pr.id in (select project_id from public.project_members where user_id = auth.uid())
    and pr.name ilike '%' || p_query || '%';
end; $$ language plpgsql;