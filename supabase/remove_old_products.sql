-- Removes old generic demo products from an existing database.
-- This does not remove the real SV More products from product_images.dart.

DO $$
DECLARE
  old_product_names text[] := ARRAY[
    'Amoxicillin 500mg Capsule',
    'Ibuprofen 200mg Tablet',
    'Paracetamol 500mg Tablet',
    'Ciprofloxacin 250mg Tablet',
    'Cetirizine 10mg Tablet',
    'Metformin 500mg Tablet',
    'Losartan 50mg Tablet',
    'Omeprazole 20mg Capsule',
    'Atorvastatin 10mg Tablet',
    'Levothyroxine 50mcg Tablet',
    'Cough Syrup 100ml',
    'Azithromycin 250mg Tablet',
    'Diclofenac 50mg Tablet',
    'Amlodipine 5mg Tablet',
    'Lisinopril 10mg Tablet',
    'Ranitidine 150mg Tablet',
    'Salbutamol Inhaler',
    'Multivitamin Syrup 200ml',
    'Doxycycline 100mg Capsule',
    'Fluconazole 150mg Tablet',
    'Metoprolol 25mg Tablet',
    'Spironolactone 25mg Tablet',
    'Calcium + Vitamin D Tablet',
    'Sertraline 50mg Tablet',
    'Clotrimazole Cream 15g',
    'Acyclovir 400mg Tablet',
    'Tramadol 50mg Capsule',
    'Fenofibrate 145mg Tablet',
    'Chlorpheniramine 4mg Tablet',
    'Naproxen 250mg Tablet',
    'Prednisone 5mg Tablet',
    'Furosemide 40mg Tablet',
    'Bactille TS 400mg/80mg Suspension',
    'Acotril 2 mg Tablet (Glimepiride)',
    'Polynerv Forte Film-Coated Tablet',
    'Zithrocin 500 mg Tablet (Azithromycin)'
  ];
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'products'
  ) THEN
    IF EXISTS (
      SELECT 1
      FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_name = 'sales_invoice_items'
    ) THEN
      DELETE FROM public.sales_invoice_items
      WHERE product_name = ANY(old_product_names)
        OR product_id IN (
          SELECT id
          FROM public.products
          WHERE name = ANY(old_product_names)
        );
    END IF;

    DELETE FROM public.products
    WHERE name = ANY(old_product_names);

    RAISE NOTICE 'Old generic demo products removed.';
  ELSE
    RAISE NOTICE 'Table public.products does not exist. Skipping cleanup.';
  END IF;
END $$;
