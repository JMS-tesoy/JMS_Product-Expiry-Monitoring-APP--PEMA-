-- Rename existing outlet display names without changing stable outlet IDs.
-- Keep outlet_id values as:
--   sv-city, sv-downtown, sv-uptown, sv-lakeside
-- Update only outlet_name in existing records.

update public.products
set outlet_name = case outlet_id
  when 'sv-city' then 'Mangagoy - City Drug store'
  when 'sv-downtown' then 'San Franz - Campo Bravo'
  when 'sv-uptown' then 'Bayugan - Bayugan Doctors'
  when 'sv-lakeside' then 'Hinatuan - La Casa Pharmacy'
  else outlet_name
end
where outlet_id in ('sv-city', 'sv-downtown', 'sv-uptown', 'sv-lakeside');

update public.sales_invoices
set outlet_name = case outlet_id
  when 'sv-city' then 'Mangagoy - City Drug store'
  when 'sv-downtown' then 'San Franz - Campo Bravo'
  when 'sv-uptown' then 'Bayugan - Bayugan Doctors'
  when 'sv-lakeside' then 'Hinatuan - La Casa Pharmacy'
  else outlet_name
end
where outlet_id in ('sv-city', 'sv-downtown', 'sv-uptown', 'sv-lakeside');

select outlet_id, outlet_name, count(*) as total_products
from public.products
group by outlet_id, outlet_name
order by outlet_id;

select outlet_id, outlet_name, count(*) as total_invoices
from public.sales_invoices
group by outlet_id, outlet_name
order by outlet_id;
