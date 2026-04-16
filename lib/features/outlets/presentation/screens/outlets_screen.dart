import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/supabase/supabase_bootstrap.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../inventory/presentation/screens/inventory_screen.dart';
import '../../../../shared/data/outlet_repository.dart';
import '../../../../shared/models/outlet_model.dart';
import '../../../../shared/widgets/neumorphic_card.dart';

enum _OutletFilter { all, urgent, healthy }

class OutletsScreen extends StatefulWidget {
  const OutletsScreen({super.key});

  @override
  State<OutletsScreen> createState() => _OutletsScreenState();
}

class _OutletsScreenState extends State<OutletsScreen> {
  final OutletRepository _outletRepository = const OutletRepository();
  late final Future<List<OutletModel>> _outletsFuture;
  String _searchQuery = '';
  _OutletFilter _selectedFilter = _OutletFilter.all;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _outletsFuture = _outletRepository.fetchOutlets();
  }

  List<OutletModel> _filteredOutlets(List<OutletModel> outlets) {
    final query = _searchQuery.trim().toLowerCase();
    final searchResults = query.isEmpty
        ? outlets
        : outlets.where((outlet) {
            return outlet.name.toLowerCase().contains(query) ||
                outlet.id.toLowerCase().contains(query);
          }).toList();

    return searchResults.where((outlet) {
      switch (_selectedFilter) {
        case _OutletFilter.all:
          return true;
        case _OutletFilter.urgent:
          return outlet.criticalProductsCount > 0;
        case _OutletFilter.healthy:
          return outlet.criticalProductsCount == 0;
      }
    }).toList();
  }

  void _showOutletDetails(BuildContext context, OutletModel outlet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _OutletDetailSheet(
        outlet: outlet,
        onViewInventory: () {
          Navigator.of(sheetContext).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => InventoryScreen(
                initialOutletId: outlet.inventoryOutletId ?? outlet.id,
                initialOutletName: outlet.name,
                initialOutletFilterName:
                    outlet.inventoryOutletName ?? outlet.name,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outlets')),
      body: FutureBuilder<List<OutletModel>>(
        future: _outletsFuture,
        builder: (context, snapshot) {
          final outlets = snapshot.data ?? const <OutletModel>[];
          final filteredOutlets = _filteredOutlets(outlets);
          final urgentOutlets = filteredOutlets
              .where((outlet) => outlet.criticalProductsCount > 0)
              .length;

          return Column(
            children: [
              _OutletSearchBar(
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
              _OutletFilterBar(
                selectedFilter: _selectedFilter,
                onFilterSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),
              _OutletSummary(
                totalCount: filteredOutlets.length,
                urgentCount: urgentOutlets,
              ),
              Expanded(
                child:
                    snapshot.connectionState == ConnectionState.waiting &&
                        outlets.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryTeal,
                        ),
                      )
                    : filteredOutlets.isEmpty
                    ? _OutletEmptyState(
                        hasSearch: _searchQuery.isNotEmpty,
                        requiresSupabaseConnection:
                            !SupabaseBootstrap.isInitialized,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: filteredOutlets.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final outlet = filteredOutlets[index];
                          return _OutletCard(
                            outlet: outlet,
                            totalProducts: outlet.totalProducts,
                            criticalProducts: outlet.criticalProductsCount,
                            onTap: () => _showOutletDetails(context, outlet),
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

class _OutletFilterBar extends StatelessWidget {
  final _OutletFilter selectedFilter;
  final ValueChanged<_OutletFilter> onFilterSelected;

  const _OutletFilterBar({
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _OutletFilterChip(
            label: 'All',
            isSelected: selectedFilter == _OutletFilter.all,
            onTap: () => onFilterSelected(_OutletFilter.all),
          ),
          _OutletFilterChip(
            label: 'Urgent',
            isSelected: selectedFilter == _OutletFilter.urgent,
            onTap: () => onFilterSelected(_OutletFilter.urgent),
            selectedColor: AppColors.statusCritical,
          ),
          _OutletFilterChip(
            label: 'Healthy',
            isSelected: selectedFilter == _OutletFilter.healthy,
            onTap: () => onFilterSelected(_OutletFilter.healthy),
            selectedColor: AppColors.statusSafe,
          ),
        ],
      ),
    );
  }
}

class _OutletFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;

  const _OutletFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor = AppColors.primaryTeal,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isSelected
        ? selectedColor
        : AppColors.textPrimary.withValues(alpha: 0.7);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedColor.withValues(alpha: 0.14)
                : AppColors.cardDark,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? selectedColor.withValues(alpha: 0.28)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutletSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _OutletSearchBar({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
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
            hintText: 'Search by branch name or ID',
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
                    color: AppColors.textPrimary.withValues(alpha: 0.4),
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

class _OutletSummary extends StatelessWidget {
  final int totalCount;
  final int urgentCount;

  const _OutletSummary({required this.totalCount, required this.urgentCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Outlet Directory',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalCount outlets currently visible',
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
              color: urgentCount > 0
                  ? AppColors.statusCritical.withValues(alpha: 0.12)
                  : AppColors.statusSafe.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: urgentCount > 0
                    ? AppColors.statusCritical.withValues(alpha: 0.2)
                    : AppColors.statusSafe.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  urgentCount > 0
                      ? LucideIcons.alertTriangle
                      : LucideIcons.checkCircle2,
                  size: 14,
                  color: urgentCount > 0
                      ? AppColors.statusCritical
                      : AppColors.statusSafe,
                ),
                const SizedBox(width: 6),
                Text(
                  urgentCount > 0 ? '$urgentCount urgent' : 'All safe',
                  style: TextStyle(
                    color: urgentCount > 0
                        ? AppColors.statusCritical
                        : AppColors.statusSafe,
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

class _OutletEmptyState extends StatelessWidget {
  final bool hasSearch;
  final bool requiresSupabaseConnection;

  const _OutletEmptyState({
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
                LucideIcons.search,
                color: AppColors.textSecondary,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch
                  ? 'No matching outlets'
                  : requiresSupabaseConnection
                  ? 'Supabase is not connected'
                  : 'No outlet data found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasSearch
                  ? 'Try a different branch name or outlet ID.'
                  : requiresSupabaseConnection
                  ? 'Add SUPABASE_URL and SUPABASE_ANON_KEY to .env, then fully restart the app.'
                  : 'Products and sales data are required to build outlet summaries.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OutletCard extends StatelessWidget {
  final OutletModel outlet;
  final int totalProducts;
  final int criticalProducts;
  final VoidCallback onTap;

  const _OutletCard({
    required this.outlet,
    required this.totalProducts,
    required this.criticalProducts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasCritical = criticalProducts > 0;
    final accentColor = hasCritical
        ? AppColors.statusCritical
        : AppColors.primaryTeal;

    return NeumorphicCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.cardElevated, AppColors.cardDark],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(LucideIcons.store, color: accentColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              outlet.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundDark,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Text(
                              outlet.id,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const _ChatCustomerPill(),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.chevronRight,
                    color: AppColors.textPrimary.withValues(alpha: 0.35),
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _OutletStatPill(
                    icon: LucideIcons.package,
                    label: '$totalProducts batches',
                    iconColor: AppColors.primaryTeal,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _OutletStatPill(
                    icon: hasCritical
                        ? LucideIcons.alertTriangle
                        : LucideIcons.checkCircle2,
                    label: hasCritical
                        ? '$criticalProducts critical'
                        : 'All safe',
                    iconColor: hasCritical
                        ? AppColors.statusCritical
                        : AppColors.statusSafe,
                    textColor: hasCritical
                        ? AppColors.statusCritical
                        : AppColors.statusSafe,
                    backgroundColor: hasCritical
                        ? AppColors.statusCritical.withValues(alpha: 0.1)
                        : AppColors.statusSafe.withValues(alpha: 0.1),
                    borderColor: hasCritical
                        ? AppColors.statusCritical.withValues(alpha: 0.16)
                        : AppColors.statusSafe.withValues(alpha: 0.16),
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

class _ChatCustomerPill extends StatelessWidget {
  const _ChatCustomerPill();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primaryTeal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.primaryTeal.withValues(alpha: 0.16),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.messageCircle,
              size: 13,
              color: AppColors.primaryTeal,
            ),
            SizedBox(width: 6),
            Text(
              'Chat Customer',
              style: TextStyle(
                color: AppColors.primaryTeal,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutletStatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;

  const _OutletStatPill({
    required this.icon,
    required this.label,
    required this.iconColor,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color:
                    textColor ?? AppColors.textPrimary.withValues(alpha: 0.75),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// --- New Detail View Bottom Sheet ---
class _OutletDetailSheet extends StatelessWidget {
  final OutletModel outlet;
  final VoidCallback onViewInventory;

  const _OutletDetailSheet({
    required this.outlet,
    required this.onViewInventory,
  });

  @override
  Widget build(BuildContext context) {
    final hasCritical = outlet.criticalProductsCount > 0;
    final statusColor = hasCritical
        ? AppColors.statusCritical
        : AppColors.statusSafe;
    final statusText = hasCritical ? 'Action Required' : 'Healthy Status';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.store,
                    color: AppColors.primaryTeal,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outlet.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Outlet ID: ${outlet.id}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Divider(color: Colors.white.withValues(alpha: 0.05)),
            const SizedBox(height: 24),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildDetailStat(
                    'Total Batches',
                    outlet.totalProducts.toString(),
                    LucideIcons.package,
                    AppColors.primaryTeal,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailStat(
                    'Critical Items',
                    outlet.criticalProductsCount.toString(),
                    LucideIcons.alertTriangle,
                    hasCritical
                        ? AppColors.statusCritical
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDetailStat(
                    'Total Units',
                    outlet.totalQuantity.toString(),
                    LucideIcons.package,
                    AppColors.primaryTeal,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailStat(
                    'Invoices',
                    outlet.invoiceCount.toString(),
                    LucideIcons.calendar,
                    AppColors.primaryTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailStat(
              'Customers',
              outlet.customerCount.toString(),
              LucideIcons.user,
              AppColors.primaryTeal,
            ),

            const SizedBox(height: 24),

            // Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    hasCritical
                        ? LucideIcons.alertOctagon
                        : LucideIcons.checkCircle2,
                    color: statusColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onViewInventory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'View Inventory',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
