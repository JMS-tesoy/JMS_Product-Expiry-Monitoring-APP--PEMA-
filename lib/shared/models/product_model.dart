import 'product_status.dart';

class ProductModel {
  final String id;
  final String name;
  final String batchNumber;
  final int quantity;
  final DateTime expiryDate;
  final String outletId;
  final String outletName;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.batchNumber,
    required this.quantity,
    required this.expiryDate,
    required this.outletId,
    required this.outletName,
    this.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    final rawExpiryDate = map['expiry_date'] ?? map['expiryDate'];

    return ProductModel(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      batchNumber: (map['batch_number'] ?? map['batchNumber'] ?? '').toString(),
      quantity: _readInt(map['quantity']),
      expiryDate: _readDateTime(rawExpiryDate),
      outletId: (map['outlet_id'] ?? map['outletId'] ?? '').toString(),
      outletName: (map['outlet_name'] ?? map['outletName'] ?? '').toString(),
      createdAt: _readNullableDateTime(map['created_at'] ?? map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'batch_number': batchNumber,
      'quantity': quantity,
      'expiry_date': expiryDate.toIso8601String(),
      'outlet_id': outletId,
      'outlet_name': outletName,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

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

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static DateTime? _readNullableDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
