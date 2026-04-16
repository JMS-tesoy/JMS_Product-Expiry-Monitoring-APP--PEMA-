import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/data/product_repository.dart';
import '../../../../shared/models/product_model.dart';
import '../../../../shared/models/product_status.dart';
import '../../../../shared/widgets/product_thumbnail.dart';

enum _CalendarRange { day, week, month, year }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ProductRepository _productRepository = const ProductRepository();
  late final Future<List<ProductModel>> _productsFuture;
  _CalendarRange _selectedRange = _CalendarRange.week;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productRepository.fetchProducts();
  }

  List<ProductModel> _applyRange(List<ProductModel> products) {
    final limit = _rangeLimitDays(_selectedRange);
    final filtered = products.where((product) {
      final daysLeft = product.daysUntilExpiry;
      return daysLeft >= 0 && daysLeft <= limit;
    }).toList();

    filtered.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return filtered;
  }

  int _rangeLimitDays(_CalendarRange range) {
    switch (range) {
      case _CalendarRange.day:
        return 0;
      case _CalendarRange.week:
        return 7;
      case _CalendarRange.month:
        return 30;
      case _CalendarRange.year:
        return 365;
    }
  }

  String _rangeTitle(_CalendarRange range) {
    switch (range) {
      case _CalendarRange.day:
        return 'Today';
      case _CalendarRange.week:
        return 'Next 7 days';
      case _CalendarRange.month:
        return 'Next 30 days';
      case _CalendarRange.year:
        return 'Next 365 days';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          final products = snapshot.data ?? const <ProductModel>[];
          final visibleProducts = _applyRange(products);

          return Column(
            children: [
              const SizedBox(height: 12),
              _CalendarRangeChips(
                selectedRange: _selectedRange,
                onRangeSelected: (range) {
                  setState(() {
                    _selectedRange = range;
                  });
                },
              ),
              const SizedBox(height: 12),
              _CalendarSummaryCard(
                title: _rangeTitle(_selectedRange),
                count: visibleProducts.length,
              ),
              const SizedBox(height: 8),
              Expanded(
                child:
                    snapshot.connectionState == ConnectionState.waiting &&
                        products.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryTeal,
                        ),
                      )
                    : visibleProducts.isEmpty
                    ? _CalendarEmptyState(title: _rangeTitle(_selectedRange))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: visibleProducts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return _CalendarProductCard(
                            product: visibleProducts[index],
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

class _CalendarRangeChips extends StatelessWidget {
  final _CalendarRange selectedRange;
  final ValueChanged<_CalendarRange> onRangeSelected;

  const _CalendarRangeChips({
    required this.selectedRange,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip(
            'Day',
            isSelected: selectedRange == _CalendarRange.day,
            onTap: () => onRangeSelected(_CalendarRange.day),
          ),
          const SizedBox(width: 8),
          _buildChip(
            'Week',
            isSelected: selectedRange == _CalendarRange.week,
            onTap: () => onRangeSelected(_CalendarRange.week),
          ),
          const SizedBox(width: 8),
          _buildChip(
            'Month',
            isSelected: selectedRange == _CalendarRange.month,
            onTap: () => onRangeSelected(_CalendarRange.month),
          ),
          const SizedBox(width: 8),
          _buildChip(
            'Year',
            isSelected: selectedRange == _CalendarRange.year,
            onTap: () => onRangeSelected(_CalendarRange.year),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    String label, {
    required bool isSelected,
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
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CalendarSummaryCard extends StatelessWidget {
  final String title;
  final int count;

  const _CalendarSummaryCard({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.cardElevated, AppColors.cardDark],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.statusWarning.withValues(alpha: 0.16),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.statusWarning.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.calendarDays,
                color: AppColors.statusWarning,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$count batch${count == 1 ? '' : 'es'} scheduled',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarProductCard extends StatelessWidget {
  final ProductModel product;

  const _CalendarProductCard({required this.product});

  Color _statusColor() {
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: ProductThumbnailPanel(
              product: product,
              fallbackColor: statusColor,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatExpiryDate(product.expiryDate),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      LucideIcons.store,
                      size: 12,
                      color: AppColors.textPrimary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 5),
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
        ],
      ),
    );
  }
}

class _CalendarEmptyState extends StatelessWidget {
  final String title;

  const _CalendarEmptyState({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No batches scheduled for $title.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

String _formatExpiryDate(DateTime date) {
  final month = _monthNames[date.month - 1];
  final day = date.day.toString().padLeft(2, '0');
  return '$month $day, ${date.year}';
}

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
