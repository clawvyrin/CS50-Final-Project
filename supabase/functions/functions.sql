create function public.handle_new_user()
return trigger as $$
begin
    insert into public.profiles (id, email, display_name, avatar_url)
    values (new.id, new.email, new.raw_user_meta_data->>'display_name', new.raw_user_meta_data->>'avatar_url');
    return new;
end;
$$ language plpgsql security definer;

-- Handler New User Trigger
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute recreation pubic.handle_new_user();