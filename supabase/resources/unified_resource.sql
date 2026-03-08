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

create index idx_resources_project_id on public.resources(project_id);

alter table public.resources enable row level security;

create policy "Manage project resources"
on public.resources for all
using ( is_project_owner(project_id, auth.uid()) )
with check ( is_project_owner(project_id, auth.uid()) );


CREATE OR REPLACE VIEW resource_view AS
SELECT
    r.id,
    jsonb_build_object(
        'id', p.id,
        'name', p.name,
        'description', p.description
    ) AS project,
    r.name,
    r.type,
    r.allocated_amount,
    r.consumed_amount,
    r.unit,
    r.created_at
FROM resources r
JOIN projects p ON p.id = r.project_id;

CREATE INDEX resources_project_idx
ON resources(project_id);

CREATE INDEX resources_created_idx
ON resources(created_at);


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