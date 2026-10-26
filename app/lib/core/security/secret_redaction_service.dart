/// Redacts sensitive values from strings before logging or exporting.
///
/// Used in diagnostic reports, log output, and any place where
/// user-provided or system-provided data may contain credentials.
class SecretRedactionService {
  static const String _placeholder = '[REDACTED]';

  final List<RegExp> _patterns = [
    RegExp(
      r'-----BEGIN[\w\s]+PRIVATE KEY',
      caseSensitive: true,
    ),
    RegExp(
      r'[Aa][Pp][Ii][-_]?[Kk][Ee][Yy]\s*[:=]\s*\S+',
    ),
    RegExp(
      r'[Ss][Ee][Cc][Rr][Ee][Tt]\s*[:=]\s*\S+',
    ),
    RegExp(
      r'[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]\s*[:=]\s*\S+',
    ),
    RegExp(
      r'[Tt][Oo][Kk][Ee][Nn]\s*[:=]\s*\S{8,}',
    ),
    RegExp(r'ghp_[A-Za-z0-9]{36}'),
    RegExp(r'AKIA[A-Z0-9]{16}'),
  ];

  /// Redacts all detected secrets in [input] and returns the safe string.
  String redact(String input) {
    var result = input;
    for (final pattern in _patterns) {
      result = result.replaceAll(pattern, _placeholder);
    }
    return result;
  }

  /// Redacts all secrets in a map's values (shallow).
  Map<String, dynamic> redactMap(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (_keyLooksSecret(key)) {
        return MapEntry(key, _placeholder);
      }
      if (value is String) {
        return MapEntry(key, redact(value));
      }
      return MapEntry(key, value);
    });
  }

  bool _keyLooksSecret(String key) {
    final lower = key.toLowerCase();
    return lower.contains('password') ||
        lower.contains('secret') ||
        lower.contains('token') ||
        lower.contains('api_key') ||
        lower.contains('apikey') ||
        lower.contains('credential') ||
        lower.contains('private_key');
  }
}
