-- Todo items, one row per task, owned by a user
create table public.todos (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) > 0),
  is_done boolean not null default false,
  created_at timestamptz not null default now(),
  user_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade
);

create index todos_user_id_idx on public.todos(user_id);

-- Only logged-in users may access the table
grant select, insert, update, delete on public.todos to authenticated;

alter table public.todos enable row level security;

-- Users can only see and change their own todos
create policy "users read own todos"
on public.todos for select to authenticated
using ((select auth.uid()) = user_id);

create policy "users insert own todos"
on public.todos for insert to authenticated
with check ((select auth.uid()) = user_id);

create policy "users update own todos"
on public.todos for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "users delete own todos"
on public.todos for delete to authenticated
using ((select auth.uid()) = user_id);