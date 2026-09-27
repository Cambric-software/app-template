import 'dart:convert';

import 'package:crypto/crypto.dart';

class SecurityService {
  static String sha256String(String value) {
    final bytes = utf8.encode(value);
    return sha256.convert(bytes).toString();
  }

  static bool constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;

    var result = 0;

    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }

    return result == 0;
  }
}
