-- 1. Table des profiles (lié à l'auth Supabase)
create table profiles (
    id uuid references auth.users on delete cascade primary key,
    email text unique not null,
    display_name text not null,
    avatar_url text,
    updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- 2. Table des projets
create table projects (
    id uuid default gen_random_uuid() primary key,
    name text not null,
    description text,
    created_at timestamp with time zone default timezone('utc'::text, now()),
    updated_at timestamp with time zone default timezone('utc'::text, now()),
    owner_id uuid references profiles(id) on delete cascade not null
);

-- 3. Table de collaboration (La pièce maitresse)
create table project_members (
    project_id uuid references projects(id) on delete cascade not null,
    user_id uuid references profiles(id) on delete cascade not null,
    role text check (role in ('admin', 'editor', 'viewer')) default 'viewer',
    primary key (project_id, user_id)
);

-- Table des tâches
create table tasks (
    id uuid default gen_random_uuid() primary key,
    project_id uuid references project(id) on delete cascade not null,
    title text not null,
    description text,
    status text check (status in ('todyo', 'in_progress','done')) default 'todo'
    assigned_to uuid references profiles(id) on delete set null,
    due_date timestamp with time zone,
    created_at timestamp with time zone default timezone('utc'::text, now())
);