import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import '../features/navigation/presentation/widgets/app_scaffold_shell.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class PharmaExpiryApp extends StatelessWidget {
  const PharmaExpiryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharma Expiry Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      scrollBehavior: const AppScrollBehavior(),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const AppScrollBehavior(),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AppScaffoldShell(),
    );
  }
}
