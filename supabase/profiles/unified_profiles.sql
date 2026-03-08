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


create index idx_profiles_full_name on public.profiles(display_name);

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

create or replace function public.delete_my_account()
returns void as $$
begin
    delete from auth.users where id = auth.uid();
end;
$$ language plpgsql security definer;

alter function public.delete_my_account()
set search_path = public;

create or replace function public.delete_my_account()
returns void as $$
begin
    delete from auth.users where id = auth.uid();
end;
$$ language plpgsql security definer;

alter function public.delete_my_account()
set search_path = public;

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