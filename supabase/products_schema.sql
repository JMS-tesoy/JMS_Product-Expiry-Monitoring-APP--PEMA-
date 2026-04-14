create table if not exists public.products (
  id text primary key,
  name text not null,
  batch_number text not null,
  quantity integer not null default 0,
  expiry_date timestamptz not null,
  outlet_id text not null,
  outlet_name text not null,
  created_at timestamptz not null default now()
);

alter table public.products enable row level security;

create policy "Allow anon read products"
on public.products
for select
to anon
using (true);
