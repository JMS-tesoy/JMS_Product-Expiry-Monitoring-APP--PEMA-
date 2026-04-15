# SV More Pharma - Product Database Seeding Guide

## Overview
This guide explains how to seed **32 pharmaceutical products** from SV More Pharma into your Supabase database. The products have been organized into 4 different outlet branches with realistic expiry dates and stock quantities.

## Product Inventory

### Total Products: 32
- **City Branch**: 10 products
- **Downtown Branch**: 8 products
- **Uptown Branch**: 6 products
- **Lakeside Branch**: 8 products

## Pharmaceutical Categories Included
- Antibiotics (Amoxicillin, Azithromycin, Ciprofloxacin, Doxycycline)
- Antihistamines & Allergy Medications (Cetirizine, Chlorpheniramine)
- Analgesics & Anti-Inflammatories (Ibuprofen, Paracetamol, Diclofenac, Naproxen)
- Cardiovascular Medications (Losartan, Amlodipine, Lisinopril, Metoprolol)
- Respiratory Medications (Salbutamol Inhaler)
- Gastrointestinal Medications (Omeprazole, Ranitidine)
- Antidiabetic Drugs (Metformin)
- Antifungal Medications (Fluconazole, Clotrimazole)
- Antivirals (Acyclovir)
- Pain Management (Tramadol)
- Steroids (Prednisone)
- Diuretics (Furosemide)
- Lipid Management (Atorvastatin, Fenofibrate)
- Hormonal (Levothyroxine)
- Antidepressants (Sertraline)
- Supplements (Calcium + Vitamin D, Multivitamin Syrup)
- Cough Syrup

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
2. You should see **32 rows** with various pharmaceutical products
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
- p-001: Amoxicillin (4 days)
- p-004: Ciprofloxacin (3 days)
- p-005: Cetirizine (6 days)
- p-011: Cough Syrup (2 days)
- p-016: Ranitidine (5 days)
- p-025: Clotrimazole Cream (1 day)
- p-019: Doxycycline (11 days)
- p-020: Fluconazole (7 days)

**Warning (8-30 days):**
- p-002: Ibuprofen (25 days)
- p-006: Metformin (12 days)
- p-007: Losartan (8 days)
- p-008: Omeprazole (15 days)
- p-010: Levothyroxine (20 days)
- p-012: Azithromycin (9 days)
- p-013: Diclofenac (28 days)
- p-015: Lisinopril (22 days)
- p-022: Spironolactone (18 days)
- p-024: Sertraline (25 days)
- p-026: Acyclovir (14 days)
- p-027: Tramadol (19 days)

**Safe (30+ days):**
- All remaining products with expiry dates > 30 days

## Data Clean-up (If needed)

If you need to reset and re-seed:

```sql
DELETE FROM public.sales_invoice_items;
DELETE FROM public.products;
```

Then run the seed script again.

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
