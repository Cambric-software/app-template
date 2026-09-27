import 'dart:convert';
import 'dart:math';

/// Simple XOR-based obfuscation for non-sensitive local data.
///
/// This is NOT cryptographically secure encryption. Use it only to prevent
/// casual inspection of stored values. For sensitive data, integrate a proper
/// cipher library (e.g. pointycastle, encrypt).
class EncryptionService {
  String get name => 'EncryptionService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// XOR-obfuscates [plaintext] with [key] and returns a Base-64 string.
  String obfuscate(String plaintext, String key) {
    final ptBytes = utf8.encode(plaintext);
    final keyBytes = utf8.encode(key);
    final result = List<int>.generate(
      ptBytes.length,
      (i) => ptBytes[i] ^ keyBytes[i % keyBytes.length],
    );
    return base64Encode(result);
  }

  /// Reverses [obfuscate]: decodes the Base-64 [ciphertext] and XORs with [key].
  String deobfuscate(String ciphertext, String key) {
    final ctBytes = base64Decode(ciphertext);
    final keyBytes = utf8.encode(key);
    final result = List<int>.generate(
      ctBytes.length,
      (i) => ctBytes[i] ^ keyBytes[i % keyBytes.length],
    );
    return utf8.decode(result);
  }

  /// Generates a cryptographically random alphanumeric key of [length] chars.
  String generateKey(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)])
        .join();
  }
}
