import '../models/product_model.dart';

List<ProductModel> buildMockProducts() {
  final now = DateTime.now();

  return [
    ProductModel(
      id: '1',
      name: 'Amoxicillin 500mg',
      batchNumber: 'AMX-2023-1',
      quantity: 50,
      expiryDate: now.add(const Duration(days: 4)),
      outletId: 'o1',
      outletName: 'City Pharmacy',
    ),
    ProductModel(
      id: '2',
      name: 'Ibuprofen 200mg',
      batchNumber: 'IBU-2023-2',
      quantity: 120,
      expiryDate: now.add(const Duration(days: 25)),
      outletId: 'o2',
      outletName: 'Downtown Clinic',
    ),
    ProductModel(
      id: '3',
      name: 'Paracetamol 500mg',
      batchNumber: 'PAR-2023-3',
      quantity: 300,
      expiryDate: now.add(const Duration(days: 180)),
      outletId: 'o1',
      outletName: 'City Pharmacy',
    ),
    ProductModel(
      id: '4',
      name: 'Ciprofloxacin 250mg',
      batchNumber: 'CIP-2023-4',
      quantity: 40,
      expiryDate: now.subtract(const Duration(days: 2)),
      outletId: 'o3',
      outletName: 'Uptown Meds',
    ),
    ProductModel(
      id: '5',
      name: 'Cetirizine 10mg',
      batchNumber: 'CET-2023-5',
      quantity: 85,
      expiryDate: now.add(const Duration(days: 6)),
      outletId: 'o1',
      outletName: 'City Pharmacy',
    ),
    ProductModel(
      id: '6',
      name: 'Metformin 500mg',
      batchNumber: 'MET-2023-6',
      quantity: 220,
      expiryDate: now.add(const Duration(days: 12)),
      outletId: 'o2',
      outletName: 'Downtown Clinic',
    ),
    ProductModel(
      id: '7',
      name: 'Losartan 50mg',
      batchNumber: 'LOS-2023-7',
      quantity: 160,
      expiryDate: now.add(const Duration(days: 3)),
      outletId: 'o4',
      outletName: 'Lakeside Pharmacy',
    ),
    ProductModel(
      id: '8',
      name: 'Omeprazole 20mg',
      batchNumber: 'OME-2023-8',
      quantity: 273,
      expiryDate: now.add(const Duration(days: 8)),
      outletId: 'o3',
      outletName: 'Uptown Meds',
    ),
  ];
}
