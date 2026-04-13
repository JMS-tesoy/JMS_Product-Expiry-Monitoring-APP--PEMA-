import 'package:flutter/material.dart';

class ScanInvoiceScreen extends StatelessWidget {
  const ScanInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Invoice')),
      body: const Center(child: Text('Scan Invoice Screen')),
    );
  }
}