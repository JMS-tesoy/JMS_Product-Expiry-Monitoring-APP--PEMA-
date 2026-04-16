import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/supabase/supabase_bootstrap.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/data/product_repository.dart';
import '../../../../shared/models/product_model.dart';
import '../../../../shared/models/product_status.dart';
import '../../../../shared/widgets/product_thumbnail.dart';

enum InventoryScreenFilter { all, critical, warning, safe }

enum _InventoryFilter { all, critical, warning, safe }

class InventoryScreen extends StatefulWidget {
  final String? initialOutletId;
  final String? initialOutletName;
  final String? initialOutletFilterName;
  final InventoryScreenFilter initialFilter;
  final int? expiringWithinDays;

  const InventoryScreen({
    super.key,
    this.initialOutletId,
    this.initialOutletName,
    this.initialOutletFilterName,
    this.initialFilter = InventoryScreenFilter.all,
    this.expiringWithinDays,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ProductRepository _productRepository = const ProductRepository();
  late final Future<List<ProductModel>> _productsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _InventoryFilter _selectedFilter = _InventoryFilter.all;

  @override
  void initState() {
    super.initState();
    _selectedFilter = _mapInitialFilter(widget.initialFilter);
    _productsFuture = _productRepository.fetchProducts();
  }

  _InventoryFilter _mapInitialFilter(InventoryScreenFilter filter) {
    switch (filter) {
      case InventoryScreenFilter.all:
        return _InventoryFilter.all;
      case InventoryScreenFilter.critical:
        return _InventoryFilter.critical;
      case InventoryScreenFilter.warning:
        return _InventoryFilter.warning;
      case InventoryScreenFilter.safe:
        return _InventoryFilter.safe;
    }
  }

  List<ProductModel> _applyFilters(List<ProductModel> products) {
    final query = _searchQuery.trim().toLowerCase();

    final searchResults = query.isEmpty
        ? products
        : products.where((product) {
            return product.name.toLowerCase().contains(query) ||
                product.batchNumber.toLowerCase().contains(query) ||
                product.outletName.toLowerCase().contains(query) ||
                product.outletId.toLowerCase().contains(query);
          }).toList();

    return searchResults.where((product) {
      switch (_selectedFilter) {
        case _InventoryFilter.all:
          return true;
        case _InventoryFilter.critical:
          return product.status == ProductStatus.critical ||
              product.status == ProductStatus.expired;
        case _InventoryFilter.warning:
          return product.status == ProductStatus.warning;
        case _InventoryFilter.safe:
          return product.status == ProductStatus.safe;
      }
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        final allProducts = snapshot.data ?? const <ProductModel>[];
        final normalizedOutletId = widget.initialOutletId?.trim().toLowerCase();
        final normalizedOutletFilterName = widget.initialOutletFilterName
            ?.trim()
            .toLowerCase();

        List<ProductModel> baseProducts;

        if (normalizedOutletId == null && normalizedOutletFilterName == null) {
          baseProducts = allProducts;
        } else {
          final outletIdMatches = normalizedOutletId == null
              ? const <ProductModel>[]
              : allProducts
                    .where(
                      (product) =>
                          product.outletId.trim().toLowerCase() ==
                          normalizedOutletId,
                    )
                    .toList();

          baseProducts = outletIdMatches.isNotEmpty
              ? outletIdMatches
              : normalizedOutletFilterName == null
              ? const <ProductModel>[]
              : allProducts
                    .where(
                      (product) =>
                          product.outletName.trim().toLowerCase() ==
                          normalizedOutletFilterName,
                    )
                    .toList();
        }

        if (widget.expiringWithinDays != null) {
          baseProducts = baseProducts.where((product) {
            return product.daysUntilExpiry <= widget.expiringWithinDays!;
          }).toList();
        }

        final products = _applyFilters(baseProducts);
        final urgentCount = products
            .where(
              (product) =>
                  product.status == ProductStatus.critical ||
                  product.status == ProductStatus.expired,
            )
            .length;
        final countLabel = widget.initialOutletName == null
            ? '${products.length} batches currently visible'
            : '${products.length} batches in ${widget.initialOutletName}';

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Text('Inventory'),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    countLabel,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              _SearchBar(
                controller: _searchController,
                query: _searchQuery,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),
              _FilterChips(
                selectedFilter: _selectedFilter,
                onFilterSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),
              _InventorySummary(
                urgentCount: urgentCount,
                onUrgentTap: urgentCount == 0
                    ? null
                    : () {
                        setState(() {
                          _selectedFilter = _InventoryFilter.critical;
                        });
                      },
              ),
              Expanded(
                child:
                    snapshot.connectionState == ConnectionState.waiting &&
                        products.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryTeal,
                        ),
                      )
                    : products.isEmpty
                    ? _InventoryEmptyState(
                        hasSearch: _searchQuery.isNotEmpty,
                        requiresSupabaseConnection:
                            !SupabaseBootstrap.isInitialized,
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
          ),
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

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
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
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
            suffixIcon: query.isEmpty
                ? Icon(
                    LucideIcons.search,
                    color: AppColors.textPrimary.withValues(alpha: 0.45),
                    size: 18,
                  )
                : IconButton(
                    onPressed: onClear,
                    icon: Icon(
                      LucideIcons.x,
                      color: AppColors.textPrimary.withValues(alpha: 0.5),
                      size: 18,
                    ),
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
  final _InventoryFilter selectedFilter;
  final ValueChanged<_InventoryFilter> onFilterSelected;

  const _FilterChips({
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip(
            'All',
            isSelected: selectedFilter == _InventoryFilter.all,
            onTap: () => onFilterSelected(_InventoryFilter.all),
          ),
          const SizedBox(width: 8),
          _buildChip(
            'Critical',
            isSelected: selectedFilter == _InventoryFilter.critical,
            icon: LucideIcons.alertTriangle,
            iconColor: AppColors.statusCritical,
            onTap: () => onFilterSelected(_InventoryFilter.critical),
          ),
          const SizedBox(width: 8),
          _buildChip(
            'Warning',
            isSelected: selectedFilter == _InventoryFilter.warning,
            icon: LucideIcons.clock,
            iconColor: AppColors.statusWarning,
            onTap: () => onFilterSelected(_InventoryFilter.warning),
          ),
          const SizedBox(width: 8),
          _buildChip(
            'Safe',
            isSelected: selectedFilter == _InventoryFilter.safe,
            icon: LucideIcons.checkCircle2,
            iconColor: AppColors.statusSafe,
            onTap: () => onFilterSelected(_InventoryFilter.safe),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    String label, {
    bool isSelected = false,
    IconData? icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryTeal
              : AppColors.cardDark.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryTeal
                : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: isSelected
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
      ),
    );
  }
}

class _InventoryEmptyState extends StatelessWidget {
  final bool hasSearch;
  final bool requiresSupabaseConnection;

  const _InventoryEmptyState({
    this.hasSearch = false,
    this.requiresSupabaseConnection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: const Icon(
                LucideIcons.package,
                color: AppColors.textSecondary,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch
                  ? 'No matching inventory'
                  : requiresSupabaseConnection
                  ? 'Supabase is not connected'
                  : 'No inventory data found',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasSearch
                  ? 'Try a different product name, batch, or outlet.'
                  : requiresSupabaseConnection
                  ? 'Add SUPABASE_URL and SUPABASE_ANON_KEY to .env, then fully restart the app.'
                  : 'No products were returned from the database.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InventorySummary extends StatelessWidget {
  final int urgentCount;
  final VoidCallback? onUrgentTap;

  const _InventorySummary({
    required this.urgentCount,
    this.onUrgentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onUrgentTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.statusCritical.withValues(
                  alpha: onUrgentTap == null ? 0.08 : 0.12,
                ),
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
          ),
        ),
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

  String _getInvoiceNumber() {
    final value = product.batchNumber.trim();
    if (value.length <= 5) return value;
    return value.substring(value.length - 5);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isExpired = product.daysUntilExpiry < 0;
    final invoiceNumber = _getInvoiceNumber();

    return Container(
      padding: const EdgeInsets.all(2),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final thumbnailWidth = constraints.maxWidth / 3;

          return SizedBox(
            height: 84,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: thumbnailWidth,
                  child: ProductThumbnailPanel(
                    product: product,
                    fallbackColor: statusColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.store,
                            size: 11,
                            color: AppColors.textPrimary.withValues(
                              alpha: 0.55,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              product.outletName,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDataCell(
                              'Invoice',
                              invoiceNumber,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildDataCell(
                              'Qty',
                              product.quantity.toString(),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildDataCell(
                              'Status',
                              isExpired
                                  ? 'Expired'
                                  : '${product.daysUntilExpiry} Days',
                              valueColor: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataCell(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: AppColors.textPrimary.withValues(alpha: 0.42),
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              color:
                  valueColor ?? AppColors.textPrimary.withValues(alpha: 0.92),
              fontSize: 10,
              fontWeight: valueColor != null
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontFamily: label == 'Invoice' ? 'monospace' : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
