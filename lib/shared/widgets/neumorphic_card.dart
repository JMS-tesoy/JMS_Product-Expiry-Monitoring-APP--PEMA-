import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          // Added a subtle border to match the React preview
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.2,
              ), // Much softer dark shadow
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
            // Removed the white glowing shadow completely
          ],
        ),
        child: child,
      ),
    );
  }
}
