/// Sanitizes and validates user-provided input before it is stored,
/// rendered, or sent to any downstream system.
///
/// Validation methods return `null` on success or an error message string
/// when invalid, making them directly usable in Flutter form validators:
///
/// ```dart
/// TextFormField(
///   validator: InputSanitizationService.validateEmail,
/// )
/// ```
class InputSanitizationService {
  const InputSanitizationService();

  // ── sanitization ─────────────────────────────────────────────────────────

  /// Trims and collapses internal whitespace in [value].
  static String trimWhitespace(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Removes all characters not in the alphanumeric + hyphen/underscore set.
  static String toSafeIdentifier(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\-_]'), '-');

  /// Removes path traversal sequences from a filename component.
  static String sanitizeFilename(String value) => value
      .replaceAll(RegExp(r'[/\\:*?"<>|]'), '_')
      .replaceAll('..', '_')
      .trim();

  /// Escapes characters that have special meaning in HTML/XML.
  static String escapeHtml(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');

  // ── validators ────────────────────────────────────────────────────────────

  /// Returns an error message if [value] is null or empty.
  static String? validateRequired(String? value, {String? label}) {
    if (value == null || value.trim().isEmpty) {
      return '${label ?? 'This field'} is required.';
    }
    return null;
  }

  /// Returns an error message if [value] is not a valid email address.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required.';
    }
    final pattern = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!pattern.hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  /// Returns an error message if [value] is not a valid URL.
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        (!uri.hasScheme) ||
        (!uri.scheme.startsWith('http'))) {
      return 'Enter a valid URL (https://...).';
    }
    return null;
  }

  /// Returns an error message if [value] is shorter than [minLength].
  static String? validateMinLength(
    String? value,
    int minLength, {
    String? label,
  }) {
    if (value == null || value.length < minLength) {
      return '${label ?? 'Value'} must be at least $minLength characters.';
    }
    return null;
  }

  /// Returns an error message if [value] is not a valid integer.
  static String? validateInteger(String? value, {String? label}) {
    if (value == null || value.trim().isEmpty) return null;
    if (int.tryParse(value.trim()) == null) {
      return '${label ?? 'Value'} must be a whole number.';
    }
    return null;
  }

  /// Returns an error message if [value] contains path traversal sequences.
  static String? validateSafePath(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.contains('..') ||
        value.contains('\x00') ||
        RegExp(r'[<>:"|?*]').hasMatch(value)) {
      return 'Path contains invalid characters.';
    }
    return null;
  }

  /// Checks for common secret patterns (API keys, tokens, private keys).
  ///
  /// Returns `true` when the string looks like it may contain a secret.
  /// Use this for scanning before storing or logging.
  static bool looksLikeSecret(String value) {
    const patterns = [
      r'-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----',
      r'[Aa][Pp][Ii][-_]?[Kk][Ee][Yy]\s*[:=]\s*\S{8,}',
      r'[Ss][Ee][Cc][Rr][Ee][Tt]\s*[:=]\s*\S{8,}',
      r'[Tt][Oo][Kk][Ee][Nn]\s*[:=]\s*[A-Za-z0-9\-_.]{20,}',
      r'ghp_[A-Za-z0-9]{36}',   // GitHub personal access token.
      r'AKIA[A-Z0-9]{16}',      // AWS access key ID.
    ];

    for (final pattern in patterns) {
      if (RegExp(pattern).hasMatch(value)) return true;
    }
    return false;
  }
}
