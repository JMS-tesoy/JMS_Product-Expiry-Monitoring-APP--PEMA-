import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../alerts/presentation/screens/alerts_screen.dart';
import '../../../delivery/presentation/screens/delivery_screen.dart';
import '../../../inventory/presentation/screens/inventory_screen.dart';
import '../../../outlets/presentation/screens/outlets_screen.dart';
import '../../../../shared/data/product_repository.dart';
import '../../../../shared/models/product_model.dart';
import '../../../../shared/models/product_status.dart';
import '../../../../shared/widgets/neumorphic_card.dart';
import '../../../../shared/widgets/product_thumbnail.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ProductRepository _productRepository = const ProductRepository();
  late final Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productRepository.fetchProducts();
  }

  void _openInventory({
    InventoryScreenFilter initialFilter = InventoryScreenFilter.all,
    int? expiringWithinDays,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InventoryScreen(
          initialFilter: initialFilter,
          expiringWithinDays: expiringWithinDays,
        ),
      ),
    );
  }

  void _openOutlets() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const OutletsScreen()));
  }

  void _openAlerts({
    AlertsScreenFilter initialFilter = AlertsScreenFilter.all,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AlertsScreen(initialFilter: initialFilter),
      ),
    );
  }

  void _openDelivery() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DeliveryScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          final products = snapshot.data ?? const <ProductModel>[];
          final metrics = _DashboardMetrics.fromProducts(products);

          return Column(
            children: [
              const SizedBox(height: 8),
              _UrgentBanner(metrics: metrics),
              const SizedBox(height: 16),
              _GridStats(
                metrics: metrics,
                onTapTotalItems: () => _openInventory(),
                onTapOutlets: _openOutlets,
                onTapUrgent: () => _openInventory(
                  initialFilter: InventoryScreenFilter.critical,
                ),
                onTapCritical: () =>
                    _openAlerts(initialFilter: AlertsScreenFilter.critical),
                onTapDelivery: _openDelivery,
                onTapThisWeek: () => _openInventory(expiringWithinDays: 7),
              ),
              const SizedBox(height: 10),
              _DashboardSectionHeader(
                thisWeekCount: metrics.thisWeekCount,
                onViewAll: () {
                  _openInventory();
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
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                        itemCount: metrics.expiringSoonProducts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _ExpiringItemCard(
                            product: metrics.expiringSoonProducts[index],
                          );
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

class _UrgentBanner extends StatelessWidget {
  final _DashboardMetrics metrics;

  const _UrgentBanner({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF261818), Color(0xFF1B1717)],
          ),
          border: Border.all(
            color: AppColors.statusCritical.withValues(alpha: 0.18),
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.statusCritical.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    LucideIcons.alertTriangle,
                    color: AppColors.statusCritical,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Action Required',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '${metrics.urgentCount} products need attention across '
                        '${metrics.urgentOutletCount} '
                        'outlet${metrics.urgentOutletCount == 1 ? '' : 's'}.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statusCritical.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.statusCritical.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(
                    '${metrics.urgentOutletCount} '
                    'OUTLET${metrics.urgentOutletCount == 1 ? '' : 'S'}',
                    style: TextStyle(
                      color: AppColors.statusCritical,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _BannerMetric(
                    icon: LucideIcons.alertTriangle,
                    accentColor: AppColors.statusCritical,
                    title: 'Critical Items',
                    value: '${metrics.criticalCount} critical',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _BannerMetric(
                    icon: LucideIcons.clock,
                    accentColor: AppColors.statusWarning,
                    title: 'Remaining Days',
                    value: metrics.remainingDaysLabel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerMetric extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String value;

  const _BannerMetric({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 15, color: accentColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridStats extends StatelessWidget {
  final _DashboardMetrics metrics;
  final VoidCallback onTapTotalItems;
  final VoidCallback onTapOutlets;
  final VoidCallback onTapUrgent;
  final VoidCallback onTapCritical;
  final VoidCallback onTapDelivery;
  final VoidCallback onTapThisWeek;

  const _GridStats({
    required this.metrics,
    required this.onTapTotalItems,
    required this.onTapOutlets,
    required this.onTapUrgent,
    required this.onTapCritical,
    required this.onTapDelivery,
    required this.onTapThisWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _StatCard(
                  title: 'Total Items',
                  value: _formatCount(metrics.totalQuantity),
                  icon: LucideIcons.package,
                  iconColor: AppColors.primaryTeal,
                  onTap: onTapTotalItems,
                ),
                const SizedBox(height: 10),
                _StatCard(
                  title: 'Critical',
                  value: metrics.criticalCount.toString(),
                  icon: LucideIcons.alertTriangle,
                  iconColor: AppColors.statusCritical,
                  onTap: onTapCritical,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                _StatCard(
                  title: 'Outlets',
                  value: metrics.outletCount.toString(),
                  icon: LucideIcons.store,
                  iconColor: AppColors.primaryTeal,
                  onTap: onTapOutlets,
                ),
                const SizedBox(height: 10),
                _StatCard(
                  title: 'Delivery',
                  value: '0',
                  icon: LucideIcons.truck,
                  iconColor: AppColors.primaryTeal,
                  onTap: onTapDelivery,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                _StatCard(
                  title: 'Urgent',
                  value: metrics.urgentCount.toString(),
                  icon: LucideIcons.zap,
                  iconColor: AppColors.statusWarning,
                  onTap: onTapUrgent,
                ),
                const SizedBox(height: 10),
                _StatCard(
                  title: 'This Week',
                  value: metrics.thisWeekCount.toString(),
                  icon: LucideIcons.clock,
                  iconColor: AppColors.statusWarning,
                  onTap: onTapThisWeek,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardElevated.withValues(alpha: 0.95),
              AppColors.cardDark,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 14, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSectionHeader extends StatelessWidget {
  final int thisWeekCount;
  final VoidCallback onViewAll;

  const _DashboardSectionHeader({
    required this.thisWeekCount,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expiring Soon',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  thisWeekCount == 0
                      ? 'No batches need attention this week'
                      : '$thisWeekCount batch${thisWeekCount == 1 ? '' : 'es'} need attention this week',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              foregroundColor: AppColors.primaryTeal,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('View All', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(width: 4),
                Icon(LucideIcons.arrowRight, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiringItemCard extends StatelessWidget {
  final ProductModel product;

  const _ExpiringItemCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final daysLeft = product.daysUntilExpiry;
    final statusColor = _statusColorFor(product.status);
    final statusLabel = product.status.displayName;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardElevated, AppColors.cardDark],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            offset: const Offset(0, 10),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductThumbnail(
            product: product,
            size: 76,
            borderRadius: 18,
            fallbackColor: statusColor,
            iconSize: 36,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      LucideIcons.store,
                      size: 11,
                      color: AppColors.textPrimary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        product.outletName,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _InfoPill(
                        label: 'Batch',
                        value: product.batchNumber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoPill(
                        label: 'Window',
                        value: _formatWindowText(daysLeft),
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
  }
}

class _DashboardMetrics {
  final int totalQuantity;
  final int outletCount;
  final int urgentCount;
  final int criticalCount;
  final int thisWeekCount;
  final int urgentOutletCount;
  final String remainingDaysLabel;
  final List<ProductModel> expiringSoonProducts;

  const _DashboardMetrics({
    required this.totalQuantity,
    required this.outletCount,
    required this.urgentCount,
    required this.criticalCount,
    required this.thisWeekCount,
    required this.urgentOutletCount,
    required this.remainingDaysLabel,
    required this.expiringSoonProducts,
  });

  factory _DashboardMetrics.fromProducts(List<ProductModel> products) {
    final sortedProducts = [...products]
      ..sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));

    final attentionProducts = sortedProducts
        .where((product) => product.status != ProductStatus.safe)
        .toList();
    final urgentProducts = sortedProducts
        .where(
          (product) =>
              product.status == ProductStatus.critical ||
              product.status == ProductStatus.expired,
        )
        .toList();
    final criticalProducts = sortedProducts
        .where((product) => product.status == ProductStatus.critical)
        .toList();
    final thisWeekProducts = sortedProducts
        .where((product) => product.daysUntilExpiry <= 7)
        .toList();

    return _DashboardMetrics(
      totalQuantity: products.fold<int>(
        0,
        (sum, product) => sum + product.quantity,
      ),
      outletCount: products.map((product) => product.outletId).toSet().length,
      urgentCount: urgentProducts.length,
      criticalCount: criticalProducts.length,
      thisWeekCount: thisWeekProducts.length,
      urgentOutletCount: urgentProducts
          .map((product) => product.outletId)
          .toSet()
          .length,
      remainingDaysLabel: _buildRemainingDaysLabel(attentionProducts),
      expiringSoonProducts: attentionProducts.take(5).toList(),
    );
  }
}

Color _statusColorFor(ProductStatus status) {
  switch (status) {
    case ProductStatus.safe:
      return AppColors.statusSafe;
    case ProductStatus.warning:
      return AppColors.statusWarning;
    case ProductStatus.critical:
    case ProductStatus.expired:
      return AppColors.statusCritical;
  }
}

String _buildRemainingDaysLabel(List<ProductModel> products) {
  final nextUpcoming =
      products.where((product) => product.daysUntilExpiry >= 0).toList()
        ..sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));

  if (nextUpcoming.isNotEmpty) {
    return _formatWindowText(nextUpcoming.first.daysUntilExpiry);
  }

  return products.isEmpty ? 'No risk' : 'Overdue';
}

String _formatWindowText(int daysLeft) {
  if (daysLeft < 0) {
    final overdueDays = daysLeft.abs();
    return '$overdueDays day${overdueDays == 1 ? '' : 's'} overdue';
  }
  if (daysLeft == 0) {
    return 'Today';
  }
  return '$daysLeft day${daysLeft == 1 ? '' : 's'}';
}

String _formatCount(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    final reverseIndex = digits.length - i;
    buffer.write(digits[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }

  return buffer.toString();
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoPill({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
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
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
