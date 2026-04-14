import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/data/product_repository.dart';
import '../../../../shared/models/product_model.dart';
import '../../../../shared/models/product_status.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ProductRepository _productRepository = const ProductRepository();
  late final Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productRepository.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.moreVertical),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          final products = snapshot.data ?? const <ProductModel>[];
          final urgentCount = products
              .where(
                (product) =>
                    product.status == ProductStatus.critical ||
                    product.status == ProductStatus.expired,
              )
              .length;

          return Column(
            children: [
              const _SearchBar(),
              const _FilterChips(),
              _InventorySummary(
                totalCount: products.length,
                urgentCount: urgentCount,
              ),
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting &&
                        products.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryTeal,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: products.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _ProductCard(product: products[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              offset: const Offset(0, 10),
              blurRadius: 24,
            ),
          ],
        ),
        child: TextField(
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Search products, batch, outlet...',
            hintStyle: TextStyle(
              color: AppColors.textPrimary.withValues(alpha: 0.4),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 56,
              minHeight: 52,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.search,
                  color: AppColors.primaryTeal,
                  size: 18,
                ),
              ),
            ),
            suffixIcon: Icon(
              LucideIcons.slidersHorizontal,
              color: AppColors.textPrimary.withValues(alpha: 0.45),
              size: 18,
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip('All', isSelected: true),
          const SizedBox(width: 8),
          _buildChip('Critical', icon: LucideIcons.alertTriangle, iconColor: AppColors.statusCritical),
          const SizedBox(width: 8),
          _buildChip('Warning', icon: LucideIcons.clock, iconColor: AppColors.statusWarning),
          const SizedBox(width: 8),
          _buildChip('Safe', icon: LucideIcons.checkCircle2, iconColor: AppColors.statusSafe),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {bool isSelected = false, IconData? icon, Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.primaryTeal
                : AppColors.cardDark.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color:
              isSelected
                  ? AppColors.primaryTeal
                  : Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: AppColors.primaryTeal.withValues(alpha: 0.22),
                    offset: const Offset(0, 6),
                    blurRadius: 18,
                  ),
                ]
                : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.black : iconColor,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InventorySummary extends StatelessWidget {
  final int totalCount;
  final int urgentCount;

  const _InventorySummary({
    required this.totalCount,
    required this.urgentCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inventory Overview',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalCount batches currently visible',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.statusCritical.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.statusCritical.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.alertTriangle,
                  size: 14,
                  color: AppColors.statusCritical,
                ),
                const SizedBox(width: 6),
                Text(
                  '$urgentCount urgent',
                  style: const TextStyle(
                    color: AppColors.statusCritical,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  Color _getStatusColor() {
    switch (product.status) {
      case ProductStatus.safe:
        return AppColors.statusSafe;
      case ProductStatus.warning:
        return AppColors.statusWarning;
      case ProductStatus.critical:
      case ProductStatus.expired:
        return AppColors.statusCritical;
    }
  }

  IconData _getStatusIcon() {
    switch (product.status) {
      case ProductStatus.safe:
        return LucideIcons.checkCircle2;
      case ProductStatus.warning:
        return LucideIcons.clock;
      case ProductStatus.critical:
      case ProductStatus.expired:
        return LucideIcons.alertTriangle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isExpired = product.daysUntilExpiry < 0;
    final statusText =
        isExpired ? 'Expired' : '${product.daysUntilExpiry} days left';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardElevated, AppColors.cardDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            offset: const Offset(0, 10),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  LucideIcons.package,
                  size: 18,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.store,
                          size: 12,
                          color: AppColors.textPrimary.withValues(alpha: 0.55),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            product.outletName,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(),
                      size: 12,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildDataCell('Batch', product.batchNumber)),
              const SizedBox(width: 8),
              Expanded(child: _buildDataCell('Qty', '${product.quantity} units')),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDataCell(
                  'Status',
                  isExpired ? 'Expired' : '${product.daysUntilExpiry} Days',
                  valueColor: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: AppColors.textPrimary.withValues(alpha: 0.42),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary.withValues(alpha: 0.92),
              fontSize: 12,
              fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
              fontFamily: label == 'Batch' ? 'monospace' : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
