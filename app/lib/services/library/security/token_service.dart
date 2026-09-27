import 'dart:math';

/// Generates cryptographically random tokens for CSRF, API keys, and sessions.
class TokenService {
  String get name => 'TokenService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Generates a random token of [length] characters.
  ///
  /// [urlSafe] restricts the alphabet to lowercase alphanumerics, suitable
  /// for use in URLs and query parameters without encoding.
  String generate({int length = 32, bool urlSafe = true}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const urlChars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final pool = urlSafe ? urlChars : chars;
    final rand = Random.secure();
    return List.generate(length, (_) => pool[rand.nextInt(pool.length)]).join();
  }

  /// 40-character URL-safe CSRF token.
  String generateCsrf() => generate(length: 40);

  /// 48-character mixed-case alphanumeric API key.
  String generateApiKey() => generate(length: 48, urlSafe: false);

  /// 64-character URL-safe session identifier.
  String generateSessionId() => generate(length: 64);

  /// Returns true if the token issued at [issuedAt] has exceeded [validity].
  bool isExpired(DateTime issuedAt, Duration validity) =>
      DateTime.now().isAfter(issuedAt.add(validity));
}
