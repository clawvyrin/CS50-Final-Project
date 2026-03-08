create or replace function public.delete_my_account()
returns void as $$
begin
    delete from auth.users where id = auth.uid();
end;
$$ language plpgsql security definer;

alter function public.delete_my_account()
set search_path = public;