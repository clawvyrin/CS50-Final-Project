-- RECHERCHE COLLABORATEURS
create or replace function public.search_my_collaborators(p_query text)
returns setof public.profiles as $$
begin
    return query
    select p.* from public.profiles p
    where p.id in (
        select distinct pm2.user_id 
        from public.project_members pm1
        join public.project_members pm2 on pm1.project_id = pm2.project_id
        where pm1.user_id = auth.uid() and pm2.user_id != auth.uid()
    )
    and p.display_name ilike '%' || p_query || '%';
end; $$ language plpgsql;

-- RECHERCHE PROJETS
create or replace function public.search_my_projects(p_query text)
returns setof public.projects as $$
begin
    return query
    select pr.* from public.projects pr
    where pr.id in (select project_id from public.project_members where user_id = auth.uid())
    and pr.name ilike '%' || p_query || '%';
end; $$ language plpgsql;