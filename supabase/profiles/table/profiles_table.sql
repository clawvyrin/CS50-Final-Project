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