import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/alert_model.dart';
import '../../../../shared/models/product_status.dart';
import '../../../../shared/widgets/neumorphic_card.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  // Mock Data for Alerts
  final List<AlertModel> _alerts = [
    AlertModel(
      id: 'a1',
      productId: 'p1',
      productName: 'Amoxicillin 500mg',
      outletName: 'City Pharmacy',
      expiryDate: DateTime.now().add(const Duration(days: 4)),
      alertType: ProductStatus.critical,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    AlertModel(
      id: 'a2',
      productId: 'p5',
      productName: 'Lisinopril 10mg',
      outletName: 'Westside Pharmacy',
      expiryDate: DateTime.now().add(const Duration(days: 6)),
      alertType: ProductStatus.critical,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
    ),
    AlertModel(
      id: 'a3',
      productId: 'p2',
      productName: 'Ibuprofen 200mg',
      outletName: 'Downtown Clinic',
      expiryDate: DateTime.now().add(const Duration(days: 25)),
      alertType: ProductStatus.warning,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () {
              // TODO: Open Alert Settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const _AlertSummary(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _alerts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _AlertCard(alert: _alerts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertSummary extends StatelessWidget {
  const _AlertSummary();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: NeumorphicCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem('Unread', '2', AppColors.primaryTeal),
            Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1)),
            _buildSummaryItem('Critical', '2', AppColors.statusCritical),
            Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1)),
            _buildSummaryItem('Warning', '1', AppColors.statusWarning),
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
    final isCritical = alert.alertType == ProductStatus.critical || alert.alertType == ProductStatus.expired;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alert.isRead ? AppColors.cardDark : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert.isRead ? Colors.white.withValues(alpha: 0.05) : color.withValues(alpha: 0.3),
        ),
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
                      isCritical ? 'Critical Expiry Alert' : 'Expiry Warning',
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
                  '${alert.productName} at ${alert.outletName} is expiring soon.',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 12, color: AppColors.textSecondary),
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
