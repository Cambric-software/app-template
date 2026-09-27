import 'dart:io';
import 'package:crypto/crypto.dart';

class VerificationResult {
  final bool passed;
  final String? reason;
  final String? actualChecksum;
  const VerificationResult({required this.passed, this.reason, this.actualChecksum});
  static const ok = VerificationResult(passed: true);
}

class UpdateVerificationService {
  String get name => 'UpdateVerificationService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<VerificationResult> verify(File file, {String? expectedSha256}) async {
    if (!await file.exists()) return const VerificationResult(passed: false, reason: 'File not found');
    if (await file.length() == 0) return const VerificationResult(passed: false, reason: 'File is empty');
    if (expectedSha256 == null) return VerificationResult.ok;
    final bytes = await file.readAsBytes();
    final actual = sha256.convert(bytes).toString();
    final match = _eq(actual.toLowerCase(), expectedSha256.toLowerCase());
    return match ? VerificationResult(passed: true, actualChecksum: actual)
        : VerificationResult(passed: false, reason: 'Checksum mismatch', actualChecksum: actual);
  }

  bool _eq(String a, String b) {
    if (a.length != b.length) return false;
    var r = 0; for (var i = 0; i < a.length; i++) { r |= a.codeUnitAt(i) ^ b.codeUnitAt(i); } return r == 0;
  }
}
