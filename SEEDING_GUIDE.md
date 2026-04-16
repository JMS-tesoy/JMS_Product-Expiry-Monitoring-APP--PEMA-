# SV More Pharma - Product Database Seeding Guide

## Overview
This guide explains how to seed **55 real SV More products** into your Supabase database. The products have been organized into 4 different outlet branches with realistic expiry dates and stock quantities.

## Product Inventory

### Total Products: 55
- **City Branch**: 14 products
- **Downtown Branch**: 14 products
- **Uptown Branch**: 16 products
- **Lakeside Branch**: 11 products

## Product Lines Included
- SV More tablet and capsule products
- SV More syrups, drops, sprays, and suspensions
- FLO nasal and sinus care products
- Polynerv, Meganerv, Macrobee, NutriCee, Regeron, and Rodazid products
- Product names match `lib/shared/data/product_images.dart`

## How to Execute

### Option 1: Using Supabase SQL Editor (Recommended)

1. Go to **Supabase Dashboard** → Select your project
2. Navigate to **SQL Editor** → Click **New Query**
3. Open the file: `supabase/seed_products.sql`
4. Copy the entire SQL content
5. Paste into the SQL Editor
6. Click **Run** button
7. Verify successfully executed (no error message)

### Option 2: Using Supabase CLI

```bash
# Navigate to your project root
cd pharma_expiry

# Run the seed script
supabase db push --file supabase/seed_products.sql
```

### Option 3: Using psql (PostgreSQL Client)

```bash
# Get your Supabase connection string from Project Settings
# Format: postgresql://user:password@host:port/database

psql "your_connection_string" -f supabase/seed_products.sql
```

## Verification

After running the seed script, verify the data was inserted:

### In Supabase Dashboard:
1. Go to **Database** → **Tables** → **products**
2. You should see **55 rows** with real SV More products
3. Check that expiry dates are calculated from today onwards
4. Verify outlet names are from SV More Pharma branches

### In the Flutter App:
1. Run the app: `flutter run`
2. Navigate to the Dashboard
3. You should see:
   - **Total Items**: Sum of all quantities across all products
   - **Critical**: Products expiring within 7 days
   - **Outlets**: 4 SV More Pharma branches
   - **This Week**: Products expiring within 7 days
   - **Expiring Soon List**: Products sorted by expiry date

## Product Expiry Status Distribution

**Critical (0-7 days):**
- p-001: Acotril 2 mg Tablet (4 days)
- p-004: Axepron 40 mg PFS for Injection (IV) (3 days)
- p-005: Bearse Tablet (6 days)
- p-015: FLO Sinus Care Kit (5 days)
- p-019: Macrobee with Iron (Reformulated) Tablet (7 days)
- p-029: Muconase Nasal Spray 60mL (2 days)
- p-033: NutriCap Tablet (1 day)
- p-045: Pro-C 500 Capsule (6 days)

**Warning (8-30 days):**
- p-002: Activent 2 mg per 5 mL Syrup (25 days)
- p-006: Bronchofen Drops (12 days)
- p-007: Bronchofen Syrup (8 days)
- p-008: Co-phenylcaine Forte Flexinozzle (15 days)
- p-010: Doxar 50 mg Tablet (20 days)
- p-016: FLO Sinus Care Refill Sachet (10 days)
- p-017: Gastrec 40 mg Capsule (28 days)
- p-021: Macrobee with Lysine Syrup (22 days)
- p-022: Maxifol-5000 5 mg Tablet (14 days)
- p-024: Meganerv 300 Capsule (18 days)
- p-031: Nidcor 500 mg Tablet (30 days)
- p-034: Nutricee 500mg Chewable Tablet (14 days)
- p-035: NutriCee Plus Zinc Syrup (19 days)
- p-038: Pantopron 40 mg Tablet (24 days)
- p-046: Prolix 10 mg per 5 ml Suspension (16 days)
- p-048: Regeron Vita w/ CPE Drops (15mL) (9 days)
- p-051: Rodazid 125mg/5ml Suspension (13 days)
- p-054: Venzadril Syrup (27 days)

**Safe (30+ days):**
- All remaining products with expiry dates > 30 days

## Data Clean-up (If needed)

If you need to reset and re-seed:

```sql
DELETE FROM public.sales_invoice_items;
DELETE FROM public.products;
```

Then run the seed script again.

If you only need to remove the old generic demo products from an existing database, open `supabase/remove_old_products.sql`, copy its SQL, and run it in the Supabase SQL Editor.

## Notes

- All timestamps are in UTC and use `NOW()` for dynamic relative dates
- Batch numbers follow the pattern: `[PRODUCT_CODE][4-DIGIT_YEAR][3-DIGIT_SEQUENCE]`
- Product IDs are prefixed with `p-` for easy identification
- Outlet IDs follow the pattern: `sv-[branch_name]`
- Quantities range from 75 to 400 units per product
- This ensures realistic stock levels across all outlets

## Troubleshooting

**Issue**: "Invalid table or permission denied"
- **Solution**: Ensure RLS policies allow INSERT operations or disable RLS temporarily

**Issue**: Foreign key or duplicate product errors while re-seeding
- **Solution**: Run `DELETE FROM public.sales_invoice_items;` first, then `DELETE FROM public.products;`

**Issue**: Connection timeout
- **Solution**: Check your internet connection and Supabase project status

## Future Considerations

- Consider implementing inventory levels and reorder points
- Add product categories field for better organization
- Implement barcode scanning for quick product lookup
- Add supplier information and cost data
- Track product movement history (stock in/out)
