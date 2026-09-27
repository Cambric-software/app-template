/// Redacts secrets and credentials from strings and maps before logging or
/// displaying them to users.
class SecretRedactionService {
  static const _placeholder = '[REDACTED]';

  final List<RegExp> _patterns = [
    RegExp(r'-----BEGIN[\w\s]+PRIVATE KEY', caseSensitive: true),
    RegExp(r'[Aa]pi[-_]?[Kk]ey\s*[:=]\s*\S+'),
    RegExp(r'[Ss]ecret\s*[:=]\s*\S+'),
    RegExp(r'[Pp]assword\s*[:=]\s*\S+'),
    RegExp(r'ghp_[A-Za-z0-9]{36}'),
    RegExp(r'AKIA[A-Z0-9]{16}'),
  ];

  String get name => 'SecretRedactionService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Replaces all secret patterns found in [input] with [_placeholder].
  String redact(String input) {
    var result = input;
    for (final p in _patterns) {
      result = result.replaceAll(p, _placeholder);
    }
    return result;
  }

  /// Returns a copy of [data] with secret-looking keys and values redacted.
  ///
  /// - Map keys that look like secret names have their value replaced wholesale.
  /// - String values are passed through [redact] for pattern-based scrubbing.
  /// - Non-string values are left unchanged.
  Map<String, dynamic> redactMap(Map<String, dynamic> data) {
    return data.map((k, v) {
      if (_isSecretKey(k)) return MapEntry(k, _placeholder);
      if (v is String) return MapEntry(k, redact(v));
      return MapEntry(k, v);
    });
  }

  bool _isSecretKey(String k) {
    final l = k.toLowerCase();
    return l.contains('password') ||
        l.contains('secret') ||
        l.contains('token') ||
        l.contains('api_key') ||
        l.contains('credential') ||
        l.contains('private_key');
  }
}
