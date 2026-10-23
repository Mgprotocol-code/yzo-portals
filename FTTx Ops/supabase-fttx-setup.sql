-- FTTx Ops Portal: run once in Supabase → SQL Editor → New query → Run

-- 1. Table for uploaded days
create table if not exists public.fttx_days (
  id          text primary key,           -- e.g. 2026-10-21_0
  date        date not null,
  part        int  not null default 0,
  parts       int  not null default 1,
  file        text default '',
  uploaded_at timestamptz default now(),
  rows        jsonb not null
);
create index if not exists fttx_days_date_idx on public.fttx_days (date);

alter table public.fttx_days enable row level security;

-- Everyone can view
create policy "Anyone can view FTTx days"
  on public.fttx_days for select using (true);

-- Only the upload account and the owner can add, change or delete days
create policy "Uploaders can add FTTx days"
  on public.fttx_days for insert to authenticated
  with check ((auth.jwt() ->> 'email') in ('mgprotocol+fttx@gmail.com', 'mgprotocol@gmail.com'));
create policy "Uploaders can change FTTx days"
  on public.fttx_days for update to authenticated
  using ((auth.jwt() ->> 'email') in ('mgprotocol+fttx@gmail.com', 'mgprotocol@gmail.com'))
  with check ((auth.jwt() ->> 'email') in ('mgprotocol+fttx@gmail.com', 'mgprotocol@gmail.com'));
create policy "Uploaders can delete FTTx days"
  on public.fttx_days for delete to authenticated
  using ((auth.jwt() ->> 'email') in ('mgprotocol+fttx@gmail.com', 'mgprotocol@gmail.com'));

grant usage on schema public to anon, authenticated;
grant select on public.fttx_days to anon, authenticated;
grant insert, update, delete on public.fttx_days to authenticated;

-- 2. Main page: only the owner account can edit the portal list
drop policy if exists "Signed-in users can add portals"    on public.portals;
drop policy if exists "Signed-in users can edit portals"   on public.portals;
drop policy if exists "Signed-in users can delete portals" on public.portals;
create policy "Owner can add portals" on public.portals for insert to authenticated
  with check ((auth.jwt() ->> 'email') = 'mgprotocol@gmail.com');
create policy "Owner can edit portals" on public.portals for update to authenticated
  using ((auth.jwt() ->> 'email') = 'mgprotocol@gmail.com')
  with check ((auth.jwt() ->> 'email') = 'mgprotocol@gmail.com');
create policy "Owner can delete portals" on public.portals for delete to authenticated
  using ((auth.jwt() ->> 'email') = 'mgprotocol@gmail.com');
