create table profiles (
    id uuid references auth.users on delete cascade primary key,
    email text unique not null,
    first_name text not null,
    last_name text not null,
    display_name text not null,
    biography text not null,
    avatar_url text default 'https://firebasestorage.googleapis.com/v0/b/spittin-908cd.firebasestorage.app/o/profilepic%2Fdefault_avatar.jpg?alt=media&token=a44a6dd7-aaf5-41cf-934d-a7fd60a43d3c',
    updated_at timestamp with time zone default timezone('utc'::text, now()),
    created_at timestamp with time zone default timezone('utc'::text, now())
);

alter table public.profiles enable row level security;

-- 1. Lecture : Tout le monde peut voir les profils (utile pour une app sociale/collab)
create policy "Public profiles are viewable by everyone" 
on public.profiles for select 
to authenticated
using ( true );

-- 2. Insertion : Seul l'utilisateur lui-même peut créer son profil
-- (Souvent géré par ton trigger, mais nécessaire pour la sécurité)
create policy "Users can insert their own profile" 
on public.profiles for insert 
to authenticated
with check ( auth.uid() = id );

-- 3. Mise à jour : Seul l'utilisateur peut modifier son propre profil
create policy "Users can update own profile" 
on public.profiles for update 
to authenticated
using ( auth.uid() = id );

-- 4. Supression : Seul l'utilisateur peut supprimer son propre profil
create policy "Users can delete own profile" 
on public.profiles for delete 
to authenticated
using ( auth.uid() = id );