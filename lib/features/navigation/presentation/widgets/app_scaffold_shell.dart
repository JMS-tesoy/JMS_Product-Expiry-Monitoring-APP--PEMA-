import 'package:flutter/material.dart';
import 'app_bottom_nav.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../inventory/presentation/screens/inventory_screen.dart';
import '../../../scan_invoice/presentation/screens/scan_invoice_screen.dart';
import '../../../outlets/presentation/screens/outlets_screen.dart';
import '../../../alerts/presentation/screens/alerts_screen.dart';

class AppScaffoldShell extends StatefulWidget {
  const AppScaffoldShell({super.key});

  @override
  State<AppScaffoldShell> createState() => _AppScaffoldShellState();
}

class _AppScaffoldShellState extends State<AppScaffoldShell> {
  int _currentIndex = 0;

  late final List<Widget?> _loadedScreens;

  @override
  void initState() {
    super.initState();
    _loadedScreens = List<Widget?>.filled(5, null);
    _loadedScreens[0] = const DashboardScreen();
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const InventoryScreen(); // <-- Removed const
      case 2:
        return const ScanInvoiceScreen();
      case 3:
        return const OutletsScreen(); // <-- Removed const
      case 4:
        return const AlertsScreen(); // <-- Removed const
      default:
        return const SizedBox.shrink();
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _loadedScreens[index] ??= _buildScreen(index);
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List<Widget>.generate(
          _loadedScreens.length,
          (index) => _loadedScreens[index] ?? const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}