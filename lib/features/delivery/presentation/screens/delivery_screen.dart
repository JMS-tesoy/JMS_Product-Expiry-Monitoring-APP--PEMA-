import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/supabase/supabase_bootstrap.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../inventory/presentation/screens/inventory_screen.dart';
import '../../../scan_invoice/presentation/screens/scan_invoice_screen.dart';
import '../../../../shared/widgets/neumorphic_card.dart';

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _DeliveryHeroCard(),
          const SizedBox(height: 16),
          _DeliveryActionCard(
            icon: LucideIcons.scanLine,
            accentColor: AppColors.primaryTeal,
            title: 'Receive Delivery',
            subtitle:
                'Scan a supplier invoice or delivery document before updating stock.',
            primaryLabel: 'Open Scanner',
            onPrimaryTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScanInvoiceScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _DeliveryActionCard(
            icon: LucideIcons.packageSearch,
            accentColor: AppColors.statusWarning,
            title: 'Review Inventory',
            subtitle:
                'Check current batches first so new deliveries are matched to the correct outlet stock.',
            primaryLabel: 'View Inventory',
            onPrimaryTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InventoryScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _DeliveryStatusCard(
            requiresSupabaseConnection: !SupabaseBootstrap.isInitialized,
          ),
        ],
      ),
    );
  }
}

class _DeliveryHeroCard extends StatelessWidget {
  const _DeliveryHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16211F), Color(0xFF141818)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryTeal.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            offset: const Offset(0, 10),
            blurRadius: 24,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              LucideIcons.truck,
              color: AppColors.primaryTeal,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Workspace',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Use this page to receive stock, scan delivery paperwork, and move into inventory review without adding another navbar tab.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.45,
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

class _DeliveryActionCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimaryTap;

  const _DeliveryActionCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 18),
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
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPrimaryTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(LucideIcons.arrowRight, size: 16),
                label: Text(
                  primaryLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryStatusCard extends StatelessWidget {
  final bool requiresSupabaseConnection;

  const _DeliveryStatusCard({required this.requiresSupabaseConnection});

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: requiresSupabaseConnection
                      ? AppColors.statusCritical.withValues(alpha: 0.14)
                      : AppColors.statusWarning.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  requiresSupabaseConnection
                      ? LucideIcons.wifiOff
                      : LucideIcons.clipboardList,
                  color: requiresSupabaseConnection
                      ? AppColors.statusCritical
                      : AppColors.statusWarning,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                requiresSupabaseConnection
                    ? 'Supabase is not connected'
                    : 'No delivery records yet',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            requiresSupabaseConnection
                ? 'Add SUPABASE_URL and SUPABASE_ANON_KEY to .env, then fully restart the app before using delivery actions.'
                : 'The current database does not include a dedicated deliveries table yet, so this page is focused on receiving and routing delivery work safely.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
