-- Rewrite SQL Data-Seed Script with Table Existence Check
-- Target Table: public.products
-- Columns: id, name, batch_number, quantity, expiry_date, outlet_id, outlet_name, created_at

DO $$
BEGIN
  -- Check if the public.products table exists
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'products'
  ) THEN
    -- Table exists, proceed with DELETE and INSERT
    RAISE NOTICE 'Table public.products found. Clearing existing data and inserting new products...';
    
    DELETE FROM public.products;
    RAISE NOTICE 'Deleted existing products.';

    INSERT INTO public.products (id, name, batch_number, quantity, expiry_date, outlet_id, outlet_name, created_at)
    VALUES
      -- Outlet 1: SV More Pharma - City Branch
      ('p-001', 'Amoxicillin 500mg Capsule', 'AMX2024001', 150, NOW() + INTERVAL '4 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-002', 'Ibuprofen 200mg Tablet', 'IBU2024002', 200, NOW() + INTERVAL '25 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-003', 'Paracetamol 500mg Tablet', 'PAR2024003', 300, NOW() + INTERVAL '180 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-004', 'Ciprofloxacin 250mg Tablet', 'CIP2024004', 120, NOW() + INTERVAL '3 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-005', 'Cetirizine 10mg Tablet', 'CET2024005', 250, NOW() + INTERVAL '6 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-006', 'Metformin 500mg Tablet', 'MET2024006', 400, NOW() + INTERVAL '12 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-007', 'Losartan 50mg Tablet', 'LOS2024007', 180, NOW() + INTERVAL '8 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-008', 'Omeprazole 20mg Capsule', 'OME2024008', 220, NOW() + INTERVAL '15 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-009', 'Atorvastatin 10mg Tablet', 'ATV2024009', 290, NOW() + INTERVAL '35 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-010', 'Levothyroxine 50mcg Tablet', 'LEV2024010', 160, NOW() + INTERVAL '20 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),

      -- Outlet 2: SV More Pharma - Downtown Branch
      ('p-011', 'Cough Syrup 100ml', 'CSY2024011', 80, NOW() + INTERVAL '2 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-012', 'Azithromycin 250mg Tablet', 'AZI2024012', 140, NOW() + INTERVAL '9 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-013', 'Diclofenac 50mg Tablet', 'DIC2024013', 320, NOW() + INTERVAL '28 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-014', 'Amlodipine 5mg Tablet', 'AML2024014', 270, NOW() + INTERVAL '45 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-015', 'Lisinopril 10mg Tablet', 'LIS2024015', 200, NOW() + INTERVAL '22 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-016', 'Ranitidine 150mg Tablet', 'RAN2024016', 180, NOW() + INTERVAL '5 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-017', 'Salbutamol Inhaler', 'SAL2024017', 95, NOW() + INTERVAL '60 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-018', 'Multivitamin Syrup 200ml', 'MUL2024018', 110, NOW() + INTERVAL '90 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),

      -- Outlet 3: SV More Pharma - Uptown Branch
      ('p-019', 'Doxycycline 100mg Capsule', 'DOX2024019', 130, NOW() + INTERVAL '11 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),
      ('p-020', 'Fluconazole 150mg Tablet', 'FLU2024020', 75, NOW() + INTERVAL '7 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),
      ('p-021', 'Metoprolol 25mg Tablet', 'MET2024021', 240, NOW() + INTERVAL '32 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),
      ('p-022', 'Spironolactone 25mg Tablet', 'SPI2024022', 160, NOW() + INTERVAL '18 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),
      ('p-023', 'Calcium + Vitamin D Tablet', 'CAL2024023', 350, NOW() + INTERVAL '120 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),
      ('p-024', 'Sertraline 50mg Tablet', 'SER2024024', 185, NOW() + INTERVAL '25 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),

      -- Outlet 4: SV More Pharma - Lakeside Branch
      ('p-025', 'Clotrimazole Cream 15g', 'CLO2024025', 220, NOW() + INTERVAL '1 day', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-026', 'Acyclovir 400mg Tablet', 'ACY2024026', 145, NOW() + INTERVAL '14 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-027', 'Tramadol 50mg Capsule', 'TRA2024027', 110, NOW() + INTERVAL '19 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-028', 'Fenofibrate 145mg Tablet', 'FEN2024028', 155, NOW() + INTERVAL '40 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-029', 'Chlorpheniramine 4mg Tablet', 'CHL2024029', 280, NOW() + INTERVAL '50 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-030', 'Naproxen 250mg Tablet', 'NAP2024030', 310, NOW() + INTERVAL '55 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-031', 'Prednisone 5mg Tablet', 'PRE2024031', 125, NOW() + INTERVAL '38 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-032', 'Furosemide 40mg Tablet', 'FUR2024032', 200, NOW() + INTERVAL '44 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW());

    RAISE NOTICE 'Inserted 32 products successfully.';
  ELSE
    -- Table does not exist, output notice without error
    RAISE NOTICE 'Table public.products does not exist in the database. Skipping data insertion.';
    RAISE NOTICE 'To create the table, run: supabase push --file supabase/products_schema.sql';
  END IF;
END $$;