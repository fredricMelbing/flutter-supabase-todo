-- One profile per user, with username and admin flag
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Read-only from the app; nobody can make themselves admin
grant select on public.profiles to authenticated;

-- Create a profile automatically when a user signs up
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, username)
  values (new.id, split_part(new.email, '@', 1));
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- Helper used by RLS policies: is the current user an admin?
create function public.is_admin()
returns boolean
language sql stable
security definer set search_path = ''
as $$
  select coalesce(
    (select is_admin from public.profiles where id = (select auth.uid())),
    false
  );
$$;

create policy "users read own profile"
on public.profiles for select to authenticated
using ((select auth.uid()) = id);

create policy "admins read all profiles"
on public.profiles for select to authenticated
using ((select public.is_admin()));

create policy "admins read all todos"
on public.todos for select to authenticated
using ((select public.is_admin()));