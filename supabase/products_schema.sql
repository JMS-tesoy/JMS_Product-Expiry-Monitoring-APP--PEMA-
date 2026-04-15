create table if not exists public.products (
  id text primary key,
  name text not null,
  batch_number text not null,
  lot_number text,
  quantity integer not null default 0,
  expiry_date timestamptz not null,
  outlet_id text not null,
  outlet_name text not null,
  created_at timestamptz not null default now()
);

alter table public.products enable row level security;

drop policy if exists "Allow anon read products" on public.products;
create policy "Allow anon read products"
on public.products
for select
to anon
using (true);

-- Customers Table
create table if not exists public.customers (
  id text primary key,
  full_name text not null,
  normalized_name text not null unique,
  phone_number text,
  email text,
  address text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.customers enable row level security;

drop policy if exists "Allow anon read customers" on public.customers;
create policy "Allow anon read customers"
on public.customers
for select
to anon
using (true);

-- Sales Invoices Table
create table if not exists public.sales_invoices (
  id text primary key,
  invoice_number text not null unique,
  outlet_id text not null,
  outlet_name text not null,
  customer_id text references public.customers(id) on delete set null,
  customer_name text,
  total_amount numeric(10, 2) not null default 0,
  tax_amount numeric(10, 2) default 0,
  discount_amount numeric(10, 2) default 0,
  invoice_date date not null,
  payment_method text,
  status text default 'completed',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table if exists public.sales_invoices
add column if not exists customer_id text references public.customers(id) on delete set null;

alter table public.sales_invoices enable row level security;

drop policy if exists "Allow anon read sales_invoices" on public.sales_invoices;
create policy "Allow anon read sales_invoices"
on public.sales_invoices
for select
to anon
using (true);

-- Backfill customer master records from existing invoice rows.
insert into public.customers (
  id,
  full_name,
  normalized_name,
  created_at,
  updated_at
)
select
  'cust-' || substring(
    md5(upper(regexp_replace(trim(customer_name), '\s+', ' ', 'g')))
    from 1 for 12
  ),
  regexp_replace(trim(customer_name), '\s+', ' ', 'g'),
  upper(regexp_replace(trim(customer_name), '\s+', ' ', 'g')),
  now(),
  now()
from public.sales_invoices
where customer_name is not null
  and trim(customer_name) <> ''
on conflict (normalized_name) do update
set
  full_name = excluded.full_name,
  updated_at = now();

update public.sales_invoices as sales_invoice
set customer_id = customer.id
from public.customers as customer
where sales_invoice.customer_id is null
  and sales_invoice.customer_name is not null
  and trim(sales_invoice.customer_name) <> ''
  and upper(
    regexp_replace(trim(sales_invoice.customer_name), '\s+', ' ', 'g')
  ) = customer.normalized_name;

-- Sales Invoice Items Table
create table if not exists public.sales_invoice_items (
  id text primary key,
  invoice_id text not null references public.sales_invoices(id) on delete cascade,
  product_id text not null references public.products(id),
  product_name text not null,
  batch_number text,
  lot_number text,
  quantity integer not null,
  unit_price numeric(10, 2) not null,
  line_total numeric(10, 2) not null,
  created_at timestamptz not null default now()
);

alter table public.sales_invoice_items enable row level security;

drop policy if exists "Allow anon read sales_invoice_items" on public.sales_invoice_items;
create policy "Allow anon read sales_invoice_items"
on public.sales_invoice_items
for select
to anon
using (true);
