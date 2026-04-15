import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/supabase/supabase_bootstrap.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/data/alert_repository.dart';
import '../../../../shared/models/alert_model.dart';
import '../../../../shared/models/product_status.dart';
import '../../../../shared/widgets/neumorphic_card.dart';

enum AlertsScreenFilter { all, critical, warning }

enum _AlertFilter { all, critical, warning }

class AlertsScreen extends StatefulWidget {
  final AlertsScreenFilter initialFilter;

  const AlertsScreen({
    super.key,
    this.initialFilter = AlertsScreenFilter.all,
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final AlertRepository _alertRepository = const AlertRepository();
  late final Future<List<AlertModel>> _alertsFuture;
  _AlertFilter _selectedFilter = _AlertFilter.all;

  @override
  void initState() {
    super.initState();
    _selectedFilter = _mapInitialFilter(widget.initialFilter);
    _alertsFuture = _alertRepository.fetchAlerts();
  }

  _AlertFilter _mapInitialFilter(AlertsScreenFilter filter) {
    switch (filter) {
      case AlertsScreenFilter.all:
        return _AlertFilter.all;
      case AlertsScreenFilter.critical:
        return _AlertFilter.critical;
      case AlertsScreenFilter.warning:
        return _AlertFilter.warning;
    }
  }

  List<AlertModel> _applyFilter(List<AlertModel> alerts) {
    switch (_selectedFilter) {
      case _AlertFilter.all:
        return alerts;
      case _AlertFilter.critical:
        return alerts.where((alert) {
          return alert.alertType == ProductStatus.critical ||
              alert.alertType == ProductStatus.expired;
        }).toList();
      case _AlertFilter.warning:
        return alerts
            .where((alert) => alert.alertType == ProductStatus.warning)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: FutureBuilder<List<AlertModel>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          final alerts = snapshot.data ?? const <AlertModel>[];
          final filteredAlerts = _applyFilter(alerts);

          return Column(
            children: [
              _AlertSummary(
                alerts: alerts,
                selectedFilter: _selectedFilter,
                onFilterSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),
              Expanded(
                child:
                    snapshot.connectionState == ConnectionState.waiting &&
                        alerts.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryTeal,
                        ),
                      )
                    : filteredAlerts.isEmpty
                    ? _AlertEmptyState(
                        requiresSupabaseConnection:
                            !SupabaseBootstrap.isInitialized,
                        selectedFilter: _selectedFilter,
                        hasAnyAlerts: alerts.isNotEmpty,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAlerts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _AlertCard(alert: filteredAlerts[index]);
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

class _AlertSummary extends StatelessWidget {
  final List<AlertModel> alerts;
  final _AlertFilter selectedFilter;
  final ValueChanged<_AlertFilter> onFilterSelected;

  const _AlertSummary({
    required this.alerts,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final criticalCount = alerts
        .where(
          (alert) =>
              alert.alertType == ProductStatus.critical ||
              alert.alertType == ProductStatus.expired,
        )
        .length;
    final warningCount = alerts
        .where((alert) => alert.alertType == ProductStatus.warning)
        .length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: NeumorphicCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildSummaryItem(
                label: 'Active',
                count: '${alerts.length}',
                color: AppColors.primaryTeal,
                isSelected: selectedFilter == _AlertFilter.all,
                onTap: () => onFilterSelected(_AlertFilter.all),
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            Expanded(
              child: _buildSummaryItem(
                label: 'Critical',
                count: '$criticalCount',
                color: AppColors.statusCritical,
                isSelected: selectedFilter == _AlertFilter.critical,
                onTap: () => onFilterSelected(_AlertFilter.critical),
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            Expanded(
              child: _buildSummaryItem(
                label: 'Warning',
                count: '$warningCount',
                color: AppColors.statusWarning,
                isSelected: selectedFilter == _AlertFilter.warning,
                onTap: () => onFilterSelected(_AlertFilter.warning),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String count,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.08) : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.35)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Text(
                count,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? color : AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertEmptyState extends StatelessWidget {
  final bool requiresSupabaseConnection;
  final _AlertFilter selectedFilter;
  final bool hasAnyAlerts;

  const _AlertEmptyState({
    this.requiresSupabaseConnection = false,
    this.selectedFilter = _AlertFilter.all,
    this.hasAnyAlerts = false,
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
                LucideIcons.bell,
                color: AppColors.textSecondary,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              requiresSupabaseConnection
                  ? 'Supabase is not connected'
                  : hasAnyAlerts && selectedFilter == _AlertFilter.critical
                  ? 'No critical alerts'
                  : hasAnyAlerts && selectedFilter == _AlertFilter.warning
                  ? 'No warning alerts'
                  : 'No active alerts',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              requiresSupabaseConnection
                  ? 'Add SUPABASE_URL and SUPABASE_ANON_KEY to .env, then fully restart the app.'
                  : hasAnyAlerts && selectedFilter == _AlertFilter.critical
                  ? 'There are no critical or expired items in the current alert list.'
                  : hasAnyAlerts && selectedFilter == _AlertFilter.warning
                  ? 'There are no warning items in the current alert list.'
                  : 'No warning or critical expiry items were returned from the database.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertModel alert;

  const _AlertCard({required this.alert});

  Color _getAlertColor() {
    switch (alert.alertType) {
      case ProductStatus.critical:
      case ProductStatus.expired:
        return AppColors.statusCritical;
      case ProductStatus.warning:
        return AppColors.statusWarning;
      default:
        return AppColors.primaryTeal;
    }
  }

  IconData _getAlertIcon() {
    switch (alert.alertType) {
      case ProductStatus.critical:
      case ProductStatus.expired:
        return LucideIcons.alertOctagon;
      case ProductStatus.warning:
        return LucideIcons.clock;
      default:
        return LucideIcons.bell;
    }
  }

  String _formatTimeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getAlertColor();
    final isCritical =
        alert.alertType == ProductStatus.critical ||
        alert.alertType == ProductStatus.expired;
    final title = alert.alertType == ProductStatus.expired
        ? 'Expired Batch Alert'
        : isCritical
        ? 'Critical Expiry Alert'
        : 'Expiry Warning';
    final description = alert.alertType == ProductStatus.expired
        ? '${alert.productName} at ${alert.outletName} has already expired.'
        : '${alert.productName} at ${alert.outletName} is expiring soon.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getAlertIcon(), color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(alert.createdAt),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expires: ${alert.expiryDate.year}-${alert.expiryDate.month.toString().padLeft(2, '0')}-${alert.expiryDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
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
