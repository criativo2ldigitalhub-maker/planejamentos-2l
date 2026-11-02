-- Rode este script inteiro no Supabase: SQL Editor > New query > Run

create table if not exists clients (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  calendar_name text default '',
  plan text default 'Personalizado',
  videos int default 0,
  arts int default 0,
  traffic boolean default false,
  social boolean default true,
  created_at timestamptz default now()
);

create table if not exists plans (
  client_id uuid not null references clients(id) on delete cascade,
  month text not null,                 -- formato 2026-11
  arts jsonb default '[]'::jsonb,
  recordings jsonb default '[]'::jsonb,
  notes text default '',
  sent boolean default false,
  updated_at timestamptz default now(),
  primary key (client_id, month)
);

create table if not exists settings (
  id int primary key default 1,
  data jsonb default '{}'::jsonb
);

-- Só quem faz login (a equipe) lê e grava
alter table clients  enable row level security;
alter table plans    enable row level security;
alter table settings enable row level security;

drop policy if exists "equipe" on clients;
drop policy if exists "equipe" on plans;
drop policy if exists "equipe" on settings;
create policy "equipe" on clients  for all to authenticated using (true) with check (true);
create policy "equipe" on plans    for all to authenticated using (true) with check (true);
create policy "equipe" on settings for all to authenticated using (true) with check (true);

-- Pasta das artes (as imagens abrem por link, para o arquivo do cliente funcionar)
insert into storage.buckets (id, name, public)
values ('artes', 'artes', true)
on conflict (id) do nothing;

drop policy if exists "equipe le artes" on storage.objects;
drop policy if exists "equipe envia artes" on storage.objects;
drop policy if exists "equipe apaga artes" on storage.objects;
create policy "equipe le artes"    on storage.objects for select to authenticated using (bucket_id = 'artes');
create policy "equipe envia artes" on storage.objects for insert to authenticated with check (bucket_id = 'artes');
create policy "equipe apaga artes" on storage.objects for delete to authenticated using (bucket_id = 'artes');
