import 'product_status.dart';

class ProductModel {
  final String id;
  final String name;
  final String batchNumber;
  final int quantity;
  final DateTime expiryDate;
  final String outletId;
  final String outletName;

  ProductModel({
    required this.id,
    required this.name,
    required this.batchNumber,
    required this.quantity,
    required this.expiryDate,
    required this.outletId,
    required this.outletName,
  });

  /// Calculates the exact number of days until the product expires.
  int get daysUntilExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  /// Automatically determines the status based on days left.
  ProductStatus get status {
    final days = daysUntilExpiry;
    if (days < 0) return ProductStatus.expired;
    if (days <= 7) return ProductStatus.critical;
    if (days <= 30) return ProductStatus.warning;
    return ProductStatus.safe;
  }
}