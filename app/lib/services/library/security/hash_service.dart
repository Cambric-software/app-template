import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;

/// SHA-256 and HMAC hashing utilities.
class HashService {
  String get name => 'HashService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Returns the SHA-256 hex digest of [input].
  String sha256(String input) =>
      crypto.sha256.convert(utf8.encode(input)).toString();

  /// Returns the MD5 hex digest of [input].
  String md5(String input) =>
      crypto.md5.convert(utf8.encode(input)).toString();

  /// Returns the HMAC-SHA-256 hex digest of [data] signed with [secret].
  String hmacSha256(String data, String secret) {
    final key = utf8.encode(secret);
    return crypto.Hmac(crypto.sha256, key).convert(utf8.encode(data)).toString();
  }

  /// Constant-time comparison of the SHA-256 hash of [input] against
  /// [expectedHash]. Prevents timing-based side-channel attacks.
  bool verify(String input, String expectedHash) {
    final actual = sha256(input);
    if (actual.length != expectedHash.length) return false;
    var result = 0;
    for (var i = 0; i < actual.length; i++) {
      result |= actual.codeUnitAt(i) ^ expectedHash.codeUnitAt(i);
    }
    return result == 0;
  }
}
