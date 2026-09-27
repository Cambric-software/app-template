import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

/// Verifies file and data integrity using SHA-256.
///
/// Usage:
/// ```dart
/// final integrity = IntegrityService();
/// await integrity.writeWithTag(file, content, secret: appSecret);
/// final ok = await integrity.verifyFile(file, secret: appSecret);
/// ```
class IntegrityService {
  String get name => 'IntegrityService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Computes SHA-256 of [data].
  String computeHash(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }

  /// Computes SHA-256 of file bytes.
  Future<String> hashFile(File file) async {
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  /// Verifies a file matches [expectedHash].
  Future<bool> verifyFile(File file, {required String expectedHash}) async {
    final actual = await hashFile(file);
    return _constantTimeEquals(actual, expectedHash.toLowerCase());
  }

  /// Constant-time string comparison.
  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Generates an HMAC-SHA256 tag for [data] using [secret].
  String generateTag(String data, {required String secret}) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(data);
    return Hmac(sha256, key).convert(bytes).toString();
  }

  /// Verifies [data] against [tag] using [secret].
  bool verifyTag(String data, String tag, {required String secret}) {
    final expected = generateTag(data, secret: secret);
    return _constantTimeEquals(expected, tag);
  }
}
