import '../models/alert_model.dart';
import '../models/product_status.dart';
import 'product_repository.dart';

class AlertRepository {
  const AlertRepository({
    ProductRepository productRepository = const ProductRepository(),
  }) : _productRepository = productRepository;

  final ProductRepository _productRepository;

  Future<List<AlertModel>> fetchAlerts() async {
    final products = await _productRepository.fetchProducts();

    final alerts = products
        .where(
          (product) =>
              product.status == ProductStatus.warning ||
              product.status == ProductStatus.critical ||
              product.status == ProductStatus.expired,
        )
        .map(
          (product) => AlertModel(
            id: product.id,
            productId: product.id,
            productName: product.name,
            outletName: product.outletName,
            expiryDate: product.expiryDate,
            alertType: product.status,
            createdAt: product.createdAt ?? DateTime.now(),
          ),
        )
        .toList();

    alerts.sort((a, b) {
      final severity = _severityRank(
        a.alertType,
      ).compareTo(_severityRank(b.alertType));
      if (severity != 0) return severity;

      return a.expiryDate.compareTo(b.expiryDate);
    });

    return alerts;
  }

  int _severityRank(ProductStatus status) {
    switch (status) {
      case ProductStatus.expired:
        return 0;
      case ProductStatus.critical:
        return 1;
      case ProductStatus.warning:
        return 2;
      case ProductStatus.safe:
        return 3;
    }
  }
}
