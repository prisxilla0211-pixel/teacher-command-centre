-- Run once in Supabase SQL Editor.
-- This is a private, single-teacher application. No public record access.
create table if not exists public.app_access (
  user_id uuid primary key references auth.users(id) on delete cascade,
  approved_at timestamptz not null default now()
);
create table if not exists public.planner_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.app_access enable row level security;
alter table public.planner_data enable row level security;
revoke all on public.app_access from anon;
revoke all on public.planner_data from anon;
grant select on public.app_access to authenticated;
grant select, insert, update, delete on public.planner_data to authenticated;
drop policy if exists "Approved account can check its access" on public.app_access;
create policy "Approved account can check its access"
on public.app_access for select to authenticated
using (user_id = (select auth.uid()));
drop policy if exists "Approved account can read own planner" on public.planner_data;
create policy "Approved account can read own planner"
on public.planner_data for select to authenticated
using (user_id = (select auth.uid()) and exists
  (select 1 from public.app_access a where a.user_id = (select auth.uid())));
drop policy if exists "Approved account can insert own planner" on public.planner_data;
create policy "Approved account can insert own planner"
on public.planner_data for insert to authenticated
with check (user_id = (select auth.uid()) and exists
  (select 1 from public.app_access a where a.user_id = (select auth.uid())));
drop policy if exists "Approved account can update own planner" on public.planner_data;
create policy "Approved account can update own planner"
on public.planner_data for update to authenticated
using (user_id = (select auth.uid()) and exists
  (select 1 from public.app_access a where a.user_id = (select auth.uid())))
with check (user_id = (select auth.uid()) and exists
  (select 1 from public.app_access a where a.user_id = (select auth.uid())));
drop policy if exists "Approved account can delete own planner" on public.planner_data;
create policy "Approved account can delete own planner"
on public.planner_data for delete to authenticated
using (user_id = (select auth.uid()) and exists
  (select 1 from public.app_access a where a.user_id = (select auth.uid())));
-- AFTER your first Google login, the app displays your Supabase user ID.
-- In SQL Editor replace the UUID below with that ID and run this statement:
-- insert into public.app_access(user_id)
-- values ('00000000-0000-0000-0000-000000000000')
-- on conflict (user_id) do nothing;
