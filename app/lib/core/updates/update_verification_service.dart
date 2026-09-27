import 'dart:io';

import 'package:crypto/crypto.dart';

/// Verifies downloaded update packages before installation.
///
/// Never install an unverified update.
///
/// Verification flow:
/// ```
/// downloaded file
///   ↓
/// file exists check
///   ↓
/// non-empty check
///   ↓
/// SHA-256 checksum comparison (when provided)
///   ↓
/// verified ✓  or  rejected ✗
/// ```
class UpdateVerificationService {
  /// Verifies [file] against [expectedSha256] (hex string).
  ///
  /// If [expectedSha256] is null or empty, only structural checks are run.
  /// Returns `true` when verification passes.
  Future<UpdateVerificationResult> verify(
    File file, {
    String? expectedSha256,
  }) async {
    // 1. File must exist.
    if (!await file.exists()) {
      return const UpdateVerificationResult(
        passed: false,
        reason: 'Package file does not exist.',
      );
    }

    // 2. File must not be empty.
    final stat = await file.stat();
    if (stat.size == 0) {
      return const UpdateVerificationResult(
        passed: false,
        reason: 'Package file is empty.',
      );
    }

    // 3. Checksum comparison.
    if (expectedSha256 != null && expectedSha256.isNotEmpty) {
      final actual = await _sha256(file);
      final match = _constantTimeEquals(
        actual.toLowerCase(),
        expectedSha256.toLowerCase(),
      );

      if (!match) {
        return UpdateVerificationResult(
          passed: false,
          reason:
              'SHA-256 mismatch. Expected $expectedSha256 but got $actual.',
          actualChecksum: actual,
        );
      }

      return UpdateVerificationResult(
        passed: true,
        actualChecksum: actual,
      );
    }

    // No checksum provided — structural checks passed.
    return const UpdateVerificationResult(passed: true);
  }

  /// Computes the SHA-256 hex digest of [file].
  Future<String> computeChecksum(File file) => _sha256(file);

  Future<String> _sha256(File file) async {
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Constant-time string equality to prevent timing attacks.
  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}

/// Result of an update verification check.
class UpdateVerificationResult {
  final bool passed;
  final String? reason;
  final String? actualChecksum;

  const UpdateVerificationResult({
    required this.passed,
    this.reason,
    this.actualChecksum,
  });

  @override
  String toString() => passed
      ? 'UpdateVerificationResult(passed)'
      : 'UpdateVerificationResult(failed: $reason)';
}
