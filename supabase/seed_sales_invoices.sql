-- SQL Seed Script for Sales Invoices and Invoice Items
-- FIXED: outlet_id/outlet_name now correctly reference pharmacy branches
-- FIXED: total_amount now matches line item sums for inv-004, 006, 008, 012

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'sales_invoices'
  ) AND EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'sales_invoice_items'
  ) AND EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'customers'
  ) AND EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'sales_invoices'
      AND column_name = 'customer_id'
  ) THEN
    RAISE NOTICE 'Tables found. Clearing existing data and inserting sales invoices...';
    
    DELETE FROM public.sales_invoice_items;
    DELETE FROM public.sales_invoices;
    RAISE NOTICE 'Deleted existing sales invoices and items.';

    INSERT INTO public.customers (
      id, full_name, normalized_name, created_at, updated_at
    )
    VALUES
      ('cust-28fd3334951b', 'VILLARINA, MELINDA OTAGAN', 'VILLARINA, MELINDA OTAGAN', NOW(), NOW()),
      ('cust-07737ff699b4', 'D M R PHARMACY', 'D M R PHARMACY', NOW(), NOW()),
      ('cust-1093ccbfc0a8', 'E B N PHARMA AND MEDICAL SUPPLIES TRADING', 'E B N PHARMA AND MEDICAL SUPPLIES TRADING', NOW(), NOW()),
      ('cust-0c3cf3ea19a9', 'SARDOMA PHARMACY', 'SARDOMA PHARMACY', NOW(), NOW()),
      ('cust-8670f3eb5e8f', 'JOSH PHARMACY', 'JOSH PHARMACY', NOW(), NOW()),
      ('cust-2dab6b4434a2', 'BOTICA TRACY', 'BOTICA TRACY', NOW(), NOW()),
      ('cust-ef532d165a2c', 'DR. RUTH PHARMACY', 'DR. RUTH PHARMACY', NOW(), NOW()),
      ('cust-31d5a7f91c9c', 'CT DRUGSTORE', 'CT DRUGSTORE', NOW(), NOW()),
      ('cust-f047031bf65d', 'BOTICA HINATUAN', 'BOTICA HINATUAN', NOW(), NOW()),
      ('cust-57be6c201435', 'BUTUAN DOCTORS'' HOSPITAL', 'BUTUAN DOCTORS'' HOSPITAL', NOW(), NOW()),
      ('cust-fdbc20789a40', 'HEALTH SAVER''S PHARMACY', 'HEALTH SAVER''S PHARMACY', NOW(), NOW()),
      ('cust-a182e3925571', 'ALCHRYSS PHARMACY', 'ALCHRYSS PHARMACY', NOW(), NOW())
    ON CONFLICT (normalized_name) DO UPDATE
    SET
      full_name = EXCLUDED.full_name,
      updated_at = NOW();

    INSERT INTO public.sales_invoices (
      id, invoice_number, outlet_id, outlet_name, customer_id,
      customer_name, total_amount, tax_amount, discount_amount,
      invoice_date, payment_method, status, notes, created_at
    )
    VALUES
      -- City Branch invoices
      ('inv-001', 'INV-2026-0001', 'sv-city', 'SV More Pharma - City Branch', 'cust-28fd3334951b',
        'VILLARINA, MELINDA OTAGAN',    2850.00, 285.00, 100.00, '2026-04-14', 'Cash',          'completed', 'Regular customer',             NOW()),
      ('inv-002', 'INV-2026-0002', 'sv-city', 'SV More Pharma - City Branch', 'cust-28fd3334951b',
        'VILLARINA, MELINDA OTAGAN',    1650.00, 165.00,  50.00, '2026-04-14', 'Card',          'completed', 'Prescription refill',          NOW()),
      ('inv-003', 'INV-2026-0003', 'sv-city', 'SV More Pharma - City Branch', 'cust-07737ff699b4',
        'D M R PHARMACY',              5200.00, 520.00, 200.00, '2026-04-13', 'Bank Transfer', 'completed', 'Bulk order',                   NOW()),

      -- Downtown Branch invoices
      ('inv-004', 'INV-2026-0004', 'sv-downtown', 'SV More Pharma - Downtown Branch', 'cust-1093ccbfc0a8',
        'E B N PHARMA AND MEDICAL SUPPLIES TRADING', 1960.00, 196.00,   0.00, '2026-04-14', 'Cash',          'completed', 'Over-the-counter purchase',     NOW()),
      ('inv-005', 'INV-2026-0005', 'sv-downtown', 'SV More Pharma - Downtown Branch', 'cust-0c3cf3ea19a9',
        'SARDOMA PHARMACY',            4500.00, 450.00, 150.00, '2026-04-13', 'Bank Transfer', 'completed', 'Monthly supply',                NOW()),
      ('inv-006', 'INV-2026-0006', 'sv-downtown', 'SV More Pharma - Downtown Branch', 'cust-8670f3eb5e8f',
        'JOSH PHARMACY',               1000.00, 100.00,  25.00, '2026-04-14', 'Card',          'completed', 'Allergy medication',            NOW()),

      -- Uptown Branch invoices
      ('inv-007', 'INV-2026-0007', 'sv-uptown', 'SV More Pharma - Uptown Branch', 'cust-2dab6b4434a2',
        'BOTICA TRACY',                3200.00, 320.00, 100.00, '2026-04-14', 'Cash',          'completed', 'Chronic medication',            NOW()),
      ('inv-008', 'INV-2026-0008', 'sv-uptown', 'SV More Pharma - Uptown Branch', 'cust-ef532d165a2c',
        'DR. RUTH PHARMACY',           6780.00, 678.00, 250.00, '2026-04-12', 'Bank Transfer', 'completed', 'Corporate wellness program',    NOW()),
      ('inv-009', 'INV-2026-0009', 'sv-uptown', 'SV More Pharma - Uptown Branch', 'cust-31d5a7f91c9c',
        'CT DRUGSTORE',                1200.00, 120.00,   0.00, '2026-04-14', 'Card',          'completed', 'Cold & flu relief',             NOW()),

      -- Lakeside Branch invoices
      ('inv-010', 'INV-2026-0010', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', 'cust-f047031bf65d',
        'BOTICA HINATUAN',             2400.00, 240.00,  75.00, '2026-04-14', 'Cash',          'completed', 'Vitamin supplements',           NOW()),
      ('inv-011', 'INV-2026-0011', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', 'cust-57be6c201435',
        'BUTUAN DOCTORS'' HOSPITAL',   7500.00, 750.00, 300.00, '2026-04-11', 'Bank Transfer', 'completed', 'Quarterly supply',              NOW()),
      ('inv-012', 'INV-2026-0012', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', 'cust-fdbc20789a40',
        'HEALTH SAVER''S PHARMACY',    1080.00, 108.00,  50.00, '2026-04-14', 'Card',          'completed', 'Pain relief',                   NOW()),
      ('inv-013', 'INV-2026-0013', 'sv-lakeside', 'SV More Pharma - Lakeside Branch', 'cust-a182e3925571',
        'ALCHRYSS PHARMACY',           1800.00, 180.00,  75.00, '2026-04-14', 'Cash',          'completed', 'Regular supply',                NOW());

    INSERT INTO public.sales_invoice_items (
      id, invoice_id, product_id, product_name,
      batch_number, lot_number, quantity, unit_price, line_total, created_at
    )
    VALUES
      -- Invoice INV-2026-0001 (subtotal: 2850.00)
      ('item-001', 'inv-001', 'p-001', 'Amoxicillin 500mg Capsule',            'AMX2024001', 'LOT-2024-001', 10, 150.00, 1500.00, NOW()),
      ('item-002', 'inv-001', 'p-003', 'Paracetamol 500mg Tablet',             'PAR2024003', 'LOT-2024-003',  5, 270.00, 1350.00, NOW()),

      -- Invoice INV-2026-0002 (subtotal: 1650.00)
      ('item-003', 'inv-002', 'p-006', 'Metformin 500mg Tablet',               'MET2024006', 'LOT-2024-006',  8, 180.00, 1440.00, NOW()),
      ('item-004', 'inv-002', 'p-008', 'Omeprazole 20mg Capsule',              'OME2024008', 'LOT-2024-008',  3,  70.00,  210.00, NOW()),

      -- Invoice INV-2026-0003 (subtotal: 5200.00)
      ('item-005', 'inv-003', 'p-002', 'Ibuprofen 200mg Tablet',               'IBU2024002', 'LOT-2024-002', 20, 150.00, 3000.00, NOW()),
      ('item-006', 'inv-003', 'p-012', 'Azithromycin 250mg Tablet',            'AZI2024012', 'LOT-2024-012', 10, 220.00, 2200.00, NOW()),

      -- Invoice INV-2026-0004 (subtotal: 1960.00 — was wrongly 1950.00)
      ('item-007', 'inv-004', 'p-033', 'Acotril 2 mg Tablet (Glimepiride)',    'ACT2024033', 'LOT-2024-033',  7, 280.00, 1960.00, NOW()),

      -- Invoice INV-2026-0005 (subtotal: 4500.00)
      ('item-008', 'inv-005', 'p-009', 'Atorvastatin 10mg Tablet',             'ATV2024009', 'LOT-2024-009', 15, 200.00, 3000.00, NOW()),
      ('item-009', 'inv-005', 'p-007', 'Losartan 50mg Tablet',                 'LOS2024007', 'LOT-2024-007', 10, 150.00, 1500.00, NOW()),

      -- Invoice INV-2026-0006 (subtotal: 1000.00 — was wrongly 850.00)
      ('item-010', 'inv-006', 'p-034', 'Activent 2 mg per 5 mL Syrup',        'ACT2024034', 'LOT-2024-034',  4, 250.00, 1000.00, NOW()),

      -- Invoice INV-2026-0007 (subtotal: 3200.00)
      ('item-011', 'inv-007', 'p-035', 'Aminobrain Tablet',                    'AMN2024035', 'LOT-2024-035', 12, 200.00, 2400.00, NOW()),
      ('item-012', 'inv-007', 'p-046', 'Macrobee with Iron (Reformulated) Tablet', 'MAC2024046', 'LOT-2024-046', 5, 160.00, 800.00, NOW()),

      -- Invoice INV-2026-0008 (subtotal: 6780.00 — was wrongly 6800.00)
      ('item-013', 'inv-008', 'p-037', 'Bactille TS 400mg/80mg Suspension',   'BAC2024037', 'LOT-2024-037', 25, 180.00, 4500.00, NOW()),
      ('item-014', 'inv-008', 'p-043', 'Doxar 50 mg Tablet',                  'DOX2024043', 'LOT-2024-043', 12, 190.00, 2280.00, NOW()),

      -- Invoice INV-2026-0009 (subtotal: 1200.00)
      ('item-015', 'inv-009', 'p-039', 'Bronchofen Drops',                    'BRO2024039', 'LOT-2024-039',  8, 150.00, 1200.00, NOW()),

      -- Invoice INV-2026-0010 (subtotal: 2400.00)
      ('item-016', 'inv-010', 'p-049', 'Maxifol-5000 5 mg Tablet',            'MAX2024049', 'LOT-2024-049', 10, 240.00, 2400.00, NOW()),

      -- Invoice INV-2026-0011 (subtotal: 7500.00)
      ('item-017', 'inv-011', 'p-045', 'Gastrec 40 mg Capsule',               'GAS2024045', 'LOT-2024-045', 30, 180.00, 5400.00, NOW()),
      ('item-018', 'inv-011', 'p-051', 'Polynerv Forte Film-Coated Tablet',   'POL2024051', 'LOT-2024-051', 15, 140.00, 2100.00, NOW()),

      -- Invoice INV-2026-0012 (subtotal: 1080.00 — was wrongly 1100.00)
      ('item-019', 'inv-012', 'p-052', 'Zithrocin 500 mg Tablet (Azithromycin)', 'ZIT2024052', 'LOT-2024-052', 6, 180.00, 1080.00, NOW()),

      -- Invoice INV-2026-0013 (subtotal: 1800.00)
      ('item-020', 'inv-013', 'p-034', 'Activent 2 mg per 5 mL Syrup',       'ACT2024034', 'LOT-2024-034',  6, 300.00, 1800.00, NOW());

    RAISE NOTICE 'Inserted 12 customers, 13 sales invoices with 20 line items successfully.';
  ELSE
    RAISE NOTICE 'Required sales invoice tables do not exist. Run supabase/products_schema.sql first.';
  END IF;
END $$;
