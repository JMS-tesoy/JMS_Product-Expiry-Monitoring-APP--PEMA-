import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabSelected,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.layoutDashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.package),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.scanLine),
          label: 'Scan',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.store),
          label: 'Outlets',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.bell),
          label: 'Alerts',
        ),
      ],
    );
  }
}