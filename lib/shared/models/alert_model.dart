import 'product_status.dart';

class AlertModel {
  final String id;
  final String productId;
  final String productName;
  final String outletName;
  final DateTime expiryDate;
  final ProductStatus alertType;
  final DateTime createdAt;
  final bool isRead;

  AlertModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.outletName,
    required this.expiryDate,
    required this.alertType,
    required this.createdAt,
    this.isRead = false,
  });
}