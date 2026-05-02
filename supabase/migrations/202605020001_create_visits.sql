create extension if not exists pgcrypto;

create table if not exists public.visits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  visit_date date,
  store_name text,
  store_brand text,
  store_manager text,
  consultant_name text,
  visit_objective text,
  store_profile text,
  has_financing boolean,
  financing_name text,
  financing_limit numeric,
  financing_notes text,
  coverage_pct numeric,
  total_revenue numeric,
  average_variation numeric,
  revenue_data jsonb not null default '{}'::jsonb,
  kpi_data jsonb not null default '{}'::jsonb,
  platforms_data jsonb not null default '{}'::jsonb,
  facing_data jsonb not null default '{}'::jsonb,
  team_data jsonb not null default '{}'::jsonb,
  commercial_data jsonb not null default '{}'::jsonb,
  observations_data jsonb not null default '{}'::jsonb,
  action_plan jsonb not null default '[]'::jsonb,
  materials jsonb not null default '[]'::jsonb,
  report_text text
);

create index if not exists visits_user_created_at_idx
  on public.visits (user_id, created_at desc);

create index if not exists visits_user_visit_date_idx
  on public.visits (user_id, visit_date desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_visits_updated_at on public.visits;
create trigger set_visits_updated_at
  before update on public.visits
  for each row
  execute function public.set_updated_at();

alter table public.visits enable row level security;

drop policy if exists "Users can read own visits" on public.visits;
create policy "Users can read own visits"
  on public.visits
  for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own visits" on public.visits;
create policy "Users can insert own visits"
  on public.visits
  for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "Users can update own visits" on public.visits;
create policy "Users can update own visits"
  on public.visits
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users can delete own visits" on public.visits;
create policy "Users can delete own visits"
  on public.visits
  for delete
  to authenticated
  using (auth.uid() = user_id);
