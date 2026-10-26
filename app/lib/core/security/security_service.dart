import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Core security utilities.
///
/// Provides hashing, integrity checking, and constant-time comparison.
/// Use [InputSanitizationService] for input validation and
/// [SecretRedactionService] for log/diagnostic redaction.
class SecurityService {
  const SecurityService();

  // ── hashing ───────────────────────────────────────────────────────────────

  /// Returns the SHA-256 hex digest of a UTF-8 string.
  static String sha256String(String value) {
    final bytes = utf8.encode(value);
    return sha256.convert(bytes).toString();
  }

  /// Returns the SHA-256 hex digest of raw [bytes].
  static String sha256Bytes(List<int> bytes) =>
      sha256.convert(bytes).toString();

  /// Returns the SHA-256 hex digest of a file.
  static Future<String> sha256File(File file) async {
    final bytes = await file.readAsBytes();
    return sha256Bytes(bytes);
  }

  // ── comparison ────────────────────────────────────────────────────────────

  /// Compares two strings in constant time to prevent timing attacks.
  ///
  /// Use this when comparing secrets, checksums, or tokens.
  static bool constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  // ── integrity ─────────────────────────────────────────────────────────────

  /// Generates an integrity tag for [data] using a shared [secret].
  ///
  /// Uses HMAC-SHA256.  The [secret] is never stored in the output.
  static String generateIntegrityTag(String data, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    return hmac.convert(bytes).toString();
  }

  /// Verifies that [data] matches the [expectedTag] using [secret].
  static bool verifyIntegrityTag(
    String data,
    String expectedTag,
    String secret,
  ) {
    final actual = generateIntegrityTag(data, secret);
    return constantTimeEquals(actual, expectedTag);
  }

  // ── file integrity ────────────────────────────────────────────────────────

  /// Verifies the SHA-256 checksum of [file] against [expectedHex].
  ///
  /// Returns `true` when the file matches the expected checksum.
  static Future<bool> verifyFileChecksum(
    File file,
    String expectedHex,
  ) async {
    final actual = await sha256File(file);
    return constantTimeEquals(
      actual.toLowerCase(),
      expectedHex.toLowerCase(),
    );
  }
}
