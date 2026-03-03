create or replace function public.update_ressources()
returns trigger as $$
declare
    activity_record record;
    resourcecreate or replace function public.update_ressources()
returns trigger as $$
declare
    activity_item record;
    res_item record;
    factor int;
begin
    -- Détermination du facteur (Signature ou Annulation)
    IF (new.is_signed = true AND (old.is_signed = false OR old.is_signed IS NULL)) THEN
        factor := 1;
    ELSIF (new.is_signed = false AND old.is_signed = true) THEN
        factor := -1;
    ELSE
        return new;
    END IF;

    -- 1. Loop sur les activités envoyées dans le rapport
    for activity_item in 
        select * from jsonb_to_recordset(new.daily_activities) 
        as x(activity_id uuid, affected_resources jsonb) -- On récupère l'ID de l'activité catalogue
    loop
        
        -- 2. Loop sur les ressources impactées par cette activité précise
        if activity_item.affected_resources is not null then
            for res_item in 
                select * from jsonb_to_recordset(activity_item.affected_resources) 
                as r(id uuid, amount numeric) -- id ici est l'ID de la ressource
            loop
                
                -- A. Mise à jour du stock GLOBAL du projet
                update public.resources
                set consumed_amount = consumed_amount + (res_item.amount * factor)
                where id = res_item.id;

                -- B. Mise à jour de la consommation SPÉCIFIQUE à cette activité
                -- Cela permet de comparer "Prévu" vs "Réel" pour cette tâche précise
                update public.activity_resources
                set amount_impacted = amount_impacted + (res_item.amount * factor) -- ou crée une colonne consumed_amount
                where activity_id = activity_item.activity_id 
                and resource_id = res_item.id;

            end loop;
        end if;
    end loop;

    -- 3. Mise à jour de la main d'œuvre (Ressource 'human')
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