import 'package:flutter/services.dart';

class SupabaseConfig {
  static String _url = const String.fromEnvironment('SUPABASE_URL');
  static String _anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
  static bool _hasLoadedEnvFile = false;

  static String get url => _normalizeUrl(_url);
  static String get anonKey => _anonKey.trim();

  static bool get isConfigured =>
      _hasUsableValue(url) && _hasUsableValue(anonKey);

  static Future<void> loadFromEnvFile() async {
    if (_hasLoadedEnvFile) return;
    _hasLoadedEnvFile = true;

    try {
      final raw = await rootBundle.loadString('.env');
      final values = _parseEnv(raw);

      if (!_hasUsableValue(_url)) {
        final envUrl = values['SUPABASE_URL'];
        if (_hasUsableValue(envUrl)) {
          _url = envUrl!.trim();
        }
      }

      if (!_hasUsableValue(_anonKey)) {
        final envAnonKey = values['SUPABASE_ANON_KEY'];
        if (_hasUsableValue(envAnonKey)) {
          _anonKey = envAnonKey!.trim();
        }
      }
    } catch (_) {
      // Keep using compile-time values if the local .env file is unavailable.
    }
  }

  static Map<String, String> _parseEnv(String raw) {
    final values = <String, String>{};

    for (final originalLine in raw.split(RegExp(r'\r?\n'))) {
      var line = originalLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      if (line.endsWith(',')) {
        line = line.substring(0, line.length - 1).trim();
      }

      line = _stripWrappingQuotes(line);

      if (line.startsWith('--dart-define=')) {
        line = line.substring('--dart-define='.length).trim();
      }

      final separatorIndex = line.indexOf('=');
      if (separatorIndex <= 0) continue;

      final key = line.substring(0, separatorIndex).trim();
      final value = _stripWrappingQuotes(
        line.substring(separatorIndex + 1).trim(),
      );

      if (key.isEmpty || value.isEmpty) continue;
      values[key] = value;
    }

    return values;
  }

  static String _stripWrappingQuotes(String value) {
    if (value.length < 2) return value;

    final first = value[0];
    final last = value[value.length - 1];
    final isWrappedInDoubleQuotes = first == '"' && last == '"';
    final isWrappedInSingleQuotes = first == "'" && last == "'";

    if (isWrappedInDoubleQuotes || isWrappedInSingleQuotes) {
      return value.substring(1, value.length - 1).trim();
    }

    return value;
  }

  static String _normalizeUrl(String value) {
    final trimmed = value.trim();
    if (!_hasUsableValue(trimmed)) return trimmed;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    if (RegExp(r'^[a-z0-9-]+$').hasMatch(trimmed) && !trimmed.contains('.')) {
      return 'https://$trimmed.supabase.co';
    }

    return trimmed;
  }

  static bool _hasUsableValue(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return false;

    return !trimmed.contains('PASTE_YOUR_SUPABASE_URL_HERE') &&
        !trimmed.contains('PASTE_YOUR_SUPABASE_ANON_KEY_HERE');
  }
}
