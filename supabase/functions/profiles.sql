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


-- La fonction qui synchronise l'email
create or replace function public.handle_auth_email_update()
returns trigger as $$
begin
  update public.profiles
  set email = new.email
  where id = new.id;
  return new;
end;
$$ language plpgsql security definer;

-- Le trigger qui surveille les mises à jour dans la table interne de Supabase
create trigger on_auth_email_updated
  after update of email on auth.users
  for each row execute function public.handle_auth_email_update();


-- La fonction qui définit la date actuelle
create or replace function public.handle_update_timestamp()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

-- Le trigger qui s'active AVANT chaque update sur la table profiles
create trigger on_profile_updated
    before update on public.profiles
    for each row execute function public.handle_update_timestamp();

