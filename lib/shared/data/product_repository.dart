import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/supabase/supabase_bootstrap.dart';
import '../models/product_model.dart';

class ProductRepository {
  const ProductRepository();

  Future<List<ProductModel>> fetchProducts() async {
    if (!SupabaseBootstrap.isInitialized) {
      return const <ProductModel>[];
    }

    try {
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .order('expiry_date');

      final rows = response as List<dynamic>;
      final products = rows
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromMap)
          .toList();

      return products;
    } catch (_) {
      return const <ProductModel>[];
    }
  }
}
