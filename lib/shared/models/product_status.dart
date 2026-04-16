enum ProductStatus { safe, warning, critical, expired }

extension ProductStatusExtension on ProductStatus {
  String get displayName {
    switch (this) {
      case ProductStatus.safe:
        return 'Safe';
      case ProductStatus.warning:
        return 'Warning';
      case ProductStatus.critical:
        return 'Critical';
      case ProductStatus.expired:
        return 'Expired';
    }
  }
}
