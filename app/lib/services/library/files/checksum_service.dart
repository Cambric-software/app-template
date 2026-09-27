import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

/// Computes and verifies checksums for files and data.
class ChecksumService {
  String get name => 'ChecksumService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<String> sha256File(File file) async {
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  String sha256String(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  String sha256Bytes(List<int> bytes) =>
      sha256.convert(bytes).toString();

  Future<bool> verifyFile(File file, String expected) async {
    final actual = await sha256File(file);
    return _constantEquals(actual.toLowerCase(), expected.toLowerCase());
  }

  bool verifyString(String input, String expected) {
    final actual = sha256String(input);
    return _constantEquals(actual.toLowerCase(), expected.toLowerCase());
  }

  bool _constantEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
