-- Rewrite SQL Data-Seed Script with Table Existence Check
-- Target Table: public.products
-- Columns: id, name, batch_number, lot_number, quantity, expiry_date, outlet_id, outlet_name, created_at

DO $$
BEGIN
  -- Check if the public.products table exists
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'products'
  ) THEN
    -- Table exists, clear dependent invoice items first to avoid FK violations.
    RAISE NOTICE 'Table public.products found. Clearing existing data and inserting new products...';

    IF EXISTS (
      SELECT 1
      FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_name = 'sales_invoice_items'
    ) THEN
      DELETE FROM public.sales_invoice_items;
      RAISE NOTICE 'Deleted existing sales invoice items.';
    END IF;

    DELETE FROM public.products;
    RAISE NOTICE 'Deleted existing products.';

    INSERT INTO public.products (id, name, batch_number, lot_number, quantity, expiry_date, outlet_id, outlet_name, created_at)
    VALUES
      -- Outlet 1: SV More Pharma - City Branch
      ('p-001', 'Amoxicillin 500mg Capsule', 'AMX2024001', 'LOT-2024-001', 150, NOW() + INTERVAL '4 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-002', 'Ibuprofen 200mg Tablet', 'IBU2024002', 'LOT-2024-002', 200, NOW() + INTERVAL '25 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-003', 'Paracetamol 500mg Tablet', 'PAR2024003', 'LOT-2024-003', 300, NOW() + INTERVAL '180 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-004', 'Ciprofloxacin 250mg Tablet', 'CIP2024004', 'LOT-2024-004', 120, NOW() + INTERVAL '3 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-005', 'Cetirizine 10mg Tablet', 'CET2024005', 'LOT-2024-005', 250, NOW() + INTERVAL '6 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-006', 'Metformin 500mg Tablet', 'MET2024006', 'LOT-2024-006', 400, NOW() + INTERVAL '12 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-007', 'Losartan 50mg Tablet', 'LOS2024007', 'LOT-2024-007', 180, NOW() + INTERVAL '8 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-008', 'Omeprazole 20mg Capsule', 'OME2024008', 'LOT-2024-008', 220, NOW() + INTERVAL '15 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-009', 'Atorvastatin 10mg Tablet', 'ATV2024009', 'LOT-2024-009', 290, NOW() + INTERVAL '35 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-010', 'Levothyroxine 50mcg Tablet', 'LEV2024010', 'LOT-2024-010', 160, NOW() + INTERVAL '20 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),

      -- Outlet 2: SV More Pharma - Downtown Branch
      ('p-011', 'Cough Syrup 100ml', 'CSY2024011', 'LOT-2024-011', 80, NOW() + INTERVAL '2 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-012', 'Azithromycin 250mg Tablet', 'AZI2024012', 'LOT-2024-012', 140, NOW() + INTERVAL '9 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-013', 'Diclofenac 50mg Tablet', 'DIC2024013', 'LOT-2024-013', 320, NOW() + INTERVAL '28 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-014', 'Amlodipine 5mg Tablet', 'AML2024014', 'LOT-2024-014', 270, NOW() + INTERVAL '45 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-015', 'Lisinopril 10mg Tablet', 'LIS2024015', 'LOT-2024-015', 200, NOW() + INTERVAL '22 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-016', 'Ranitidine 150mg Tablet', 'RAN2024016', 'LOT-2024-016', 180, NOW() + INTERVAL '5 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-017', 'Salbutamol Inhaler', 'SAL2024017', 'LOT-2024-017', 95, NOW() + INTERVAL '60 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-018', 'Multivitamin Syrup 200ml', 'MUL2024018', 'LOT-2024-018', 110, NOW() + INTERVAL '90 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),

      -- Outlet 3: SV More Pharma - Uptown Branch
      ('p-019', 'Doxycycline 100mg Capsule', 'DOX2024019', 'LOT-2024-019', 130, NOW() + INTERVAL '11 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),
      ('p-020', 'Fluconazole 150mg Tablet', 'FLU2024020', 'LOT-2024-020', 75, NOW() + INTERVAL '7 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),
      ('p-021', 'Metoprolol 25mg Tablet', 'MET2024021', 'LOT-2024-021', 240, NOW() + INTERVAL '32 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),
      ('p-022', 'Spironolactone 25mg Tablet', 'SPI2024022', 'LOT-2024-022', 160, NOW() + INTERVAL '18 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),
      ('p-023', 'Calcium + Vitamin D Tablet', 'CAL2024023', 'LOT-2024-023', 350, NOW() + INTERVAL '120 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),
      ('p-024', 'Sertraline 50mg Tablet', 'SER2024024', 'LOT-2024-024', 185, NOW() + INTERVAL '25 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),

      -- Outlet 4: SV More Pharma - Lakeside Branch
      ('p-025', 'Clotrimazole Cream 15g', 'CLO2024025', 'LOT-2024-025', 220, NOW() + INTERVAL '1 day', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-026', 'Acyclovir 400mg Tablet', 'ACY2024026', 'LOT-2024-026', 145, NOW() + INTERVAL '14 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-027', 'Tramadol 50mg Capsule', 'TRA2024027', 'LOT-2024-027', 110, NOW() + INTERVAL '19 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-028', 'Fenofibrate 145mg Tablet', 'FEN2024028', 'LOT-2024-028', 155, NOW() + INTERVAL '40 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-029', 'Chlorpheniramine 4mg Tablet', 'CHL2024029', 'LOT-2024-029', 280, NOW() + INTERVAL '50 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-030', 'Naproxen 250mg Tablet', 'NAP2024030', 'LOT-2024-030', 310, NOW() + INTERVAL '55 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-031', 'Prednisone 5mg Tablet', 'PRE2024031', 'LOT-2024-031', 125, NOW() + INTERVAL '38 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-032', 'Furosemide 40mg Tablet', 'FUR2024032', 'LOT-2024-032', 200, NOW() + INTERVAL '44 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),

      -- New Products: SV More Premium Line
      ('p-033', 'Acotril 2 mg Tablet (Glimepiride)', 'ACT2024033', 'LOT-2024-033', 280, NOW() + INTERVAL '60 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-034', 'Activent 2 mg per 5 mL Syrup', 'ACT2024034', 'LOT-2024-034', 95, NOW() + INTERVAL '90 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-035', 'Aminobrain Tablet', 'AMN2024035', 'LOT-2024-035', 320, NOW() + INTERVAL '75 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-036', 'Axepron 40 mg PFS for Injection (IV)', 'AXP2024036', 'LOT-2024-036', 45, NOW() + INTERVAL '30 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-037', 'Bactille TS 400mg/80mg Suspension', 'BAC2024037', 'LOT-2024-037', 110, NOW() + INTERVAL '45 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),
      ('p-038', 'Bearse Tablet', 'BEA2024038', 'LOT-2024-038', 250, NOW() + INTERVAL '85 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),
      ('p-039', 'Bronchofen Drops', 'BRO2024039', 'LOT-2024-039', 135, NOW() + INTERVAL '100 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-040', 'Bronchofen Syrup', 'BRO2024040', 'LOT-2024-040', 88, NOW() + INTERVAL '95 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-041', 'Co-phenylcaine Forte Flexinozzle', 'CPF2024041', 'LOT-2024-041', 65, NOW() + INTERVAL '55 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-042', 'Co-phenylcaine Forte Spray', 'CPS2024042', 'LOT-2024-042', 72, NOW() + INTERVAL '50 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-043', 'Doxar 50 mg Tablet', 'DOX2024043', 'LOT-2024-043', 195, NOW() + INTERVAL '70 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-044', 'Fexuclue 40mg Tablet', 'FEX2024044', 'LOT-2024-044', 240, NOW() + INTERVAL '65 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-045', 'Gastrec 40 mg Capsule', 'GAS2024045', 'LOT-2024-045', 310, NOW() + INTERVAL '80 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),
      ('p-046', 'Macrobee with Iron (Reformulated) Tablet', 'MAC2024046', 'LOT-2024-046', 270, NOW() + INTERVAL '120 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),
      ('p-047', 'Macrobee with Iron Forte Tablet', 'MAC2024047', 'LOT-2024-047', 260, NOW() + INTERVAL '115 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-048', 'Macrobee with Lysine Syrup', 'MAC2024048', 'LOT-2024-048', 105, NOW() + INTERVAL '110 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW()),
      ('p-049', 'Maxifol-5000 5 mg Tablet', 'MAX2024049', 'LOT-2024-049', 340, NOW() + INTERVAL '130 days', 'sv-city', 'SV More Pharma - City Branch', NOW()),
      ('p-050', 'Meganerv 1000 Tablet', 'MEG2024050', 'LOT-2024-050', 185, NOW() + INTERVAL '105 days', 'sv-downtown', 'SV More Pharma - Downtown Branch', NOW()),
      ('p-051', 'Polynerv Forte Film-Coated Tablet', 'POL2024051', 'LOT-2024-051', 225, NOW() + INTERVAL '108 days', 'sv-uptown', 'SV More Pharma - Uptown Branch', NOW()),
      ('p-052', 'Zithrocin 500 mg Tablet (Azithromycin)', 'ZIT2024052', 'LOT-2024-052', 155, NOW() + INTERVAL '35 days', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', NOW());

    RAISE NOTICE 'Inserted 52 products successfully.';
  ELSE
    -- Table does not exist, output notice without error
    RAISE NOTICE 'Table public.products does not exist in the database. Skipping data insertion.';
    RAISE NOTICE 'To create the table, run: supabase push --file supabase/products_schema.sql';
  END IF;
END $$;
