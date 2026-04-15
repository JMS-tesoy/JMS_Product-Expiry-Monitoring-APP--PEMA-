import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/supabase/supabase_bootstrap.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/data/alert_repository.dart';
import '../../../../shared/models/alert_model.dart';
import '../../../../shared/models/product_status.dart';
import '../../../../shared/widgets/neumorphic_card.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final AlertRepository _alertRepository = const AlertRepository();
  late final Future<List<AlertModel>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = _alertRepository.fetchAlerts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: FutureBuilder<List<AlertModel>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          final alerts = snapshot.data ?? const <AlertModel>[];

          return Column(
            children: [
              _AlertSummary(alerts: alerts),
              Expanded(
                child:
                    snapshot.connectionState == ConnectionState.waiting &&
                        alerts.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryTeal,
                        ),
                      )
                    : alerts.isEmpty
                    ? _AlertEmptyState(
                        requiresSupabaseConnection:
                            !SupabaseBootstrap.isInitialized,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: alerts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _AlertCard(alert: alerts[index]);
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

  const _AlertSummary({required this.alerts});

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
            _buildSummaryItem(
              'Active',
              '${alerts.length}',
              AppColors.primaryTeal,
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            _buildSummaryItem(
              'Critical',
              '$criticalCount',
              AppColors.statusCritical,
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            _buildSummaryItem(
              'Warning',
              '$warningCount',
              AppColors.statusWarning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String count, Color color) {
    return Column(
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
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _AlertEmptyState extends StatelessWidget {
  final bool requiresSupabaseConnection;

  const _AlertEmptyState({this.requiresSupabaseConnection = false});

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
