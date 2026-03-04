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