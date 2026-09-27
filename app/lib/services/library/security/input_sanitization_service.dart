/// Input sanitization and validation utilities.
///
/// All methods are static so they can be called directly from form validators
/// without requiring dependency injection.
class InputSanitizationService {
  String get name => 'InputSanitizationService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Trims leading/trailing whitespace and collapses internal runs to a single space.
  static String trimWhitespace(String v) =>
      v.trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Converts [v] to a URL/identifier-safe lowercase slug.
  static String toSafeId(String v) =>
      v.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\-_]'), '-');

  /// Strips characters that are illegal in file names on Windows/Linux/macOS.
  static String sanitizeFilename(String v) =>
      v.replaceAll(RegExp(r'[/\\:*?"<>|]'), '_').replaceAll('..', '_').trim();

  /// Escapes HTML special characters to prevent XSS in rendered content.
  static String escapeHtml(String v) => v
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');

  /// Returns an error message if [v] is null or blank, null otherwise.
  static String? validateRequired(String? v, {String? label}) =>
      (v == null || v.trim().isEmpty)
          ? '${label ?? 'This field'} is required.'
          : null;

  /// Returns an error message if [v] is not a valid email address, null otherwise.
  static String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required.';
    return RegExp(r'^[\w._%+\-]+@[\w.\-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim())
        ? null
        : 'Enter a valid email.';
  }

  /// Returns an error message if [v] is not a valid HTTP/HTTPS URL, null otherwise.
  /// An empty or null value is treated as valid (field is optional).
  static String? validateUrl(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final uri = Uri.tryParse(v.trim());
    return (uri != null && uri.hasScheme && uri.scheme.startsWith('http'))
        ? null
        : 'Enter a valid URL.';
  }

  /// Heuristic check for common secret patterns (AWS keys, GitHub tokens, PEM headers).
  static bool looksLikeSecret(String v) => RegExp(
        r'AKIA[A-Z0-9]{16}|ghp_[A-Za-z0-9]{36}|-----BEGIN.*PRIVATE KEY',
      ).hasMatch(v);
}
