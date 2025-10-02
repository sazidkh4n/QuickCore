create or replace function public.become_tutor(user_id_to_update uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.profiles
  set role = 'tutor'
  where id = user_id_to_update;
end;
$$;

grant execute on function public.become_tutor(uuid) to authenticated; 