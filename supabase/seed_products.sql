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
      -- Outlet 1: Mangagoy - City Drug store
      ('p-002', 'Activent 2 mg per 5 mL Syrup', 'ACT2026002', 'LOT-2026-002', 95, NOW() + INTERVAL '25 days', 'sv-city', 'Mangagoy - City Drug store', NOW()),
      ('p-003', 'Aminobrain Tablet', 'AMI2026003', 'LOT-2026-003', 320, NOW() + INTERVAL '180 days', 'sv-city', 'Mangagoy - City Drug store', NOW()),
      ('p-004', 'Axepron 40 mg PFS for Injection (IV)', 'AXE2026004', 'LOT-2026-004', 45, NOW() + INTERVAL '3 days', 'sv-city', 'Mangagoy - City Drug store', NOW()),
      ('p-005', 'Bearse Tablet', 'BEA2026005', 'LOT-2026-005', 250, NOW() + INTERVAL '6 days', 'sv-city', 'Mangagoy - City Drug store', NOW()),
      ('p-006', 'Bronchofen Drops', 'BRD2026006', 'LOT-2026-006', 135, NOW() + INTERVAL '12 days', 'sv-city', 'Mangagoy - City Drug store', NOW()),
      ('p-007', 'Bronchofen Syrup', 'BRS2026007', 'LOT-2026-007', 88, NOW() + INTERVAL '8 days', 'sv-city', 'Mangagoy - City Drug store', NOW()),
      ('p-008', 'Co-phenylcaine Forte Flexinozzle', 'CPF2026008', 'LOT-2026-008', 65, NOW() + INTERVAL '15 days', 'sv-city', 'Mangagoy - City Drug store', NOW()),
      ('p-009', 'Co-phenylcaine Forte Spray', 'CPS2026009', 'LOT-2026-009', 72, NOW() + INTERVAL '35 days', 'sv-city', 'Mangagoy - City Drug store', NOW()),
      ('p-011', 'Fexuclue 40mg Tablet', 'FEX2026011', 'LOT-2026-011', 240, NOW() + INTERVAL '60 days', 'sv-city', 'Mangagoy - City Drug store', NOW()),
      ('p-012', 'FLO Baby Saline Nasal Spray', 'FLO2026012', 'LOT-2026-012', 110, NOW() + INTERVAL '90 days', 'sv-city', 'Mangagoy - City Drug store', NOW()),
      ('p-013', 'FLO CRS Refill Sachet', 'FCR2026013', 'LOT-2026-013', 170, NOW() + INTERVAL '45 days', 'sv-city', 'Mangagoy - City Drug store', NOW()),
      ('p-014', 'FLO CRS with Xylitol', 'FCX2026014', 'LOT-2026-014', 150, NOW() + INTERVAL '75 days', 'sv-city', 'Mangagoy - City Drug store', NOW()),

      -- Outlet 2: San Franz - Campo Bravo
      ('p-015', 'FLO Sinus Care Kit', 'FSK2026015', 'LOT-2026-015', 140, NOW() + INTERVAL '5 days', 'sv-downtown', 'San Franz - Campo Bravo', NOW()),
      ('p-016', 'FLO Sinus Care Refill Sachet', 'FSR2026016', 'LOT-2026-016', 190, NOW() + INTERVAL '10 days', 'sv-downtown', 'San Franz - Campo Bravo', NOW()),
      ('p-017', 'Gastrec 40 mg Capsule', 'GAS2026017', 'LOT-2026-017', 310, NOW() + INTERVAL '28 days', 'sv-downtown', 'San Franz - Campo Bravo', NOW()),
      ('p-018', 'Livervitan', 'LIV2026018', 'LOT-2026-018', 160, NOW() + INTERVAL '120 days', 'sv-downtown', 'San Franz - Campo Bravo', NOW()),
      ('p-020', 'Macrobee with Iron Forte Tablet', 'MIF2026020', 'LOT-2026-020', 260, NOW() + INTERVAL '45 days', 'sv-downtown', 'San Franz - Campo Bravo', NOW()),
      ('p-021', 'Macrobee with Lysine Syrup', 'MLS2026021', 'LOT-2026-021', 105, NOW() + INTERVAL '22 days', 'sv-downtown', 'San Franz - Campo Bravo', NOW()),
      ('p-022', 'Maxifol-5000 5 mg Tablet', 'MAX2026022', 'LOT-2026-022', 340, NOW() + INTERVAL '14 days', 'sv-downtown', 'San Franz - Campo Bravo', NOW()),
      ('p-023', 'Meganerv 1000 Tablet', 'MG12026023', 'LOT-2026-023', 185, NOW() + INTERVAL '32 days', 'sv-downtown', 'San Franz - Campo Bravo', NOW()),
      ('p-024', 'Meganerv 300 Capsule', 'MG32026024', 'LOT-2026-024', 150, NOW() + INTERVAL '18 days', 'sv-downtown', 'San Franz - Campo Bravo', NOW()),
      ('p-025', 'Meganerv E Capsule', 'MGE2026025', 'LOT-2026-025', 145, NOW() + INTERVAL '95 days', 'sv-downtown', 'San Franz - Campo Bravo', NOW()),
      ('p-026', 'Meganerv FA Tablet', 'MGF2026026', 'LOT-2026-026', 215, NOW() + INTERVAL '50 days', 'sv-downtown', 'San Franz - Campo Bravo', NOW()),
      ('p-027', 'Molvite OB Tablet', 'MOL2026027', 'LOT-2026-027', 230, NOW() + INTERVAL '110 days', 'sv-downtown', 'San Franz - Campo Bravo', NOW()),
      ('p-028', 'Muconase Nasal Spray 30mL', 'MU32026028', 'LOT-2026-028', 115, NOW() + INTERVAL '40 days', 'sv-downtown', 'San Franz - Campo Bravo', NOW()),

      -- Outlet 3: Bayugan - Bayugan Doctors
      ('p-029', 'Muconase Nasal Spray 60mL', 'MU62026029', 'LOT-2026-029', 90, NOW() + INTERVAL '2 days', 'sv-uptown', 'Bayugan - Bayugan Doctors', NOW()),
      ('p-032', 'Nutram Tablet', 'NUR2026032', 'LOT-2026-032', 240, NOW() + INTERVAL '55 days', 'sv-uptown', 'Bayugan - Bayugan Doctors', NOW()),
      ('p-033', 'NutriCap Tablet', 'NCP2026033', 'LOT-2026-033', 180, NOW() + INTERVAL '1 day', 'sv-uptown', 'Bayugan - Bayugan Doctors', NOW()),
      ('p-036', 'Orthroat Oral Spray 20mL', 'ORO2026036', 'LOT-2026-036', 85, NOW() + INTERVAL '42 days', 'sv-uptown', 'Bayugan - Bayugan Doctors', NOW()),
      ('p-037', 'Orthroat Plus Oral Spray 20mL', 'ORP2026037', 'LOT-2026-037', 78, NOW() + INTERVAL '70 days', 'sv-uptown', 'Bayugan - Bayugan Doctors', NOW()),
      ('p-038', 'Pantopron 40 mg Tablet', 'PAN2026038', 'LOT-2026-038', 275, NOW() + INTERVAL '24 days', 'sv-uptown', 'Bayugan - Bayugan Doctors', NOW()),
      ('p-039', 'Polynerv 1000 Tablet', 'PO12026039', 'LOT-2026-039', 225, NOW() + INTERVAL '38 days', 'sv-uptown', 'Bayugan - Bayugan Doctors', NOW()),
      ('p-041', 'Polynerv 500 Tablet', 'PO52026041', 'LOT-2026-041', 245, NOW() + INTERVAL '65 days', 'sv-uptown', 'Bayugan - Bayugan Doctors', NOW()),
      ('p-042', 'Polynerv E with Lecithin Tablet', 'PEL2026042', 'LOT-2026-042', 175, NOW() + INTERVAL '82 days', 'sv-uptown', 'Bayugan - Bayugan Doctors', NOW()),
      ('p-043', 'Polynerv Forte Tablet', 'PFT2026043', 'LOT-2026-043', 225, NOW() + INTERVAL '108 days', 'sv-uptown', 'Bayugan - Bayugan Doctors', NOW()),
      ('p-044', 'Polynerv Syrup', 'PYS2026044', 'LOT-2026-044', 98, NOW() + INTERVAL '100 days', 'sv-uptown', 'Bayugan - Bayugan Doctors', NOW()),

      -- Outlet 4: Hinatuan - La Casa Pharmacy
      ('p-047', 'Prolix 20 mg Tablet', 'PRT2026047', 'LOT-2026-047', 210, NOW() + INTERVAL '33 days', 'sv-lakeside', 'Hinatuan - La Casa Pharmacy', NOW()),
      ('p-048', 'Regeron Vita w/ CPE Drops (15mL)', 'RVD2026048', 'LOT-2026-048', 95, NOW() + INTERVAL '9 days', 'sv-lakeside', 'Hinatuan - La Casa Pharmacy', NOW()),
      ('p-050', 'Regeron-E Plus Capsule', 'REP2026050', 'LOT-2026-050', 165, NOW() + INTERVAL '75 days', 'sv-lakeside', 'Hinatuan - La Casa Pharmacy', NOW()),
      ('p-051', 'Rodazid 125mg/5ml Suspension', 'RDS2026051', 'LOT-2026-051', 120, NOW() + INTERVAL '13 days', 'sv-lakeside', 'Hinatuan - La Casa Pharmacy', NOW()),
      ('p-052', 'Rodazid 500 mg Tablet', 'RDT2026052', 'LOT-2026-052', 240, NOW() + INTERVAL '53 days', 'sv-lakeside', 'Hinatuan - La Casa Pharmacy', NOW()),
      ('p-053', 'Udcacid 300 mg Tablet', 'UDC2026053', 'LOT-2026-053', 205, NOW() + INTERVAL '85 days', 'sv-lakeside', 'Hinatuan - La Casa Pharmacy', NOW()),
      ('p-054', 'Venzadril Syrup', 'VEN2026054', 'LOT-2026-054', 130, NOW() + INTERVAL '27 days', 'sv-lakeside', 'Hinatuan - La Casa Pharmacy', NOW()),
      ('p-055', 'Zithrocin 500 mg Tablet', 'ZIT2026055', 'LOT-2026-055', 155, NOW() + INTERVAL '35 days', 'sv-lakeside', 'Hinatuan - La Casa Pharmacy', NOW());

    RAISE NOTICE 'Inserted 55 SV More products successfully.';
  ELSE
    -- Table does not exist, output notice without error
    RAISE NOTICE 'Table public.products does not exist in the database. Skipping data insertion.';
    RAISE NOTICE 'To create the table, run: supabase push --file supabase/products_schema.sql';
  END IF;
END $$;
