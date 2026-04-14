import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/supabase/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseBootstrap.initialize();
  runApp(const PharmaExpiryApp());
}
