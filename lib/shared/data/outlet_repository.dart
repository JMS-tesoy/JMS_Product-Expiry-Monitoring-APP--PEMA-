import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/supabase/supabase_bootstrap.dart';
import '../models/outlet_model.dart';
import '../models/product_status.dart';
import 'product_repository.dart';

class OutletRepository {
  const OutletRepository({
    ProductRepository productRepository = const ProductRepository(),
  }) : _productRepository = productRepository;

  final ProductRepository _productRepository;

  Future<List<OutletModel>> fetchOutlets() async {
    final products = await _productRepository.fetchProducts();
    final aggregates = <String, _OutletAggregate>{};

    for (final product in products) {
      final aggregate = aggregates.putIfAbsent(
        product.outletId,
        () => _OutletAggregate(
          outletId: product.outletId,
          outletName: product.outletName,
        ),
      );

      aggregate.batchCount += 1;
      aggregate.totalQuantity += product.quantity;

      if (product.status == ProductStatus.critical ||
          product.status == ProductStatus.expired) {
        aggregate.criticalCount += 1;
      }
    }

    if (SupabaseBootstrap.isInitialized) {
      try {
        final response = await Supabase.instance.client
            .from('sales_invoices')
            .select('id, outlet_id, outlet_name, customer_id');

        final rows = response as List<dynamic>;

        for (final row in rows.whereType<Map<String, dynamic>>()) {
          final outletId = (row['outlet_id'] ?? '').toString();
          final outletName = (row['outlet_name'] ?? '').toString();

          if (outletId.isEmpty || outletName.isEmpty) continue;

          final aggregate = aggregates.putIfAbsent(
            outletId,
            () => _OutletAggregate(outletId: outletId, outletName: outletName),
          );

          aggregate.invoiceCount += 1;

          final customerId = row['customer_id']?.toString();
          if (customerId != null && customerId.isNotEmpty) {
            aggregate.customerIds.add(customerId);
          }
        }
      } catch (_) {
        // Keep outlet summaries based on products even if invoices fail.
      }
    }

    final outlets = aggregates.values
        .map(
          (aggregate) => OutletModel(
            id: aggregate.outletId,
            name: aggregate.outletName,
            code: aggregate.outletId,
            inventoryOutletId: aggregate.outletId,
            inventoryOutletName: aggregate.outletName,
            totalQuantity: aggregate.totalQuantity,
            invoiceCount: aggregate.invoiceCount,
            customerCount: aggregate.customerIds.length,
            totalProducts: aggregate.batchCount,
            criticalProductsCount: aggregate.criticalCount,
          ),
        )
        .toList();

    outlets.sort((a, b) {
      final criticalCompare = b.criticalProductsCount.compareTo(
        a.criticalProductsCount,
      );
      if (criticalCompare != 0) return criticalCompare;

      return a.name.compareTo(b.name);
    });

    return outlets;
  }
}

class _OutletAggregate {
  _OutletAggregate({required this.outletId, required this.outletName});

  final String outletId;
  final String outletName;
  int batchCount = 0;
  int totalQuantity = 0;
  int criticalCount = 0;
  int invoiceCount = 0;
  final Set<String> customerIds = <String>{};
}
