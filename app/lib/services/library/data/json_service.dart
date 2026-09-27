import 'dart:convert';

/// JSON encode/decode with error safety and pretty-print support.
///
/// Usage:
/// ```dart
/// final json = JsonService();
/// final encoded = json.encode({'key': 'value'});
/// final decoded = json.decode(encoded);
/// ```
class JsonService {
  String get name => 'JsonService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  String encode(dynamic value, {bool pretty = false}) {
    if (pretty) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(value);
    }
    return jsonEncode(value);
  }

  dynamic decode(String source) {
    try {
      return jsonDecode(source);
    } on FormatException catch (e) {
      throw FormatException('JsonService.decode failed: ${e.message}', source);
    }
  }

  Map<String, dynamic>? decodeObject(String source) {
    final result = decode(source);
    return result is Map<String, dynamic> ? result : null;
  }

  List<dynamic>? decodeList(String source) {
    final result = decode(source);
    return result is List ? result : null;
  }

  /// Returns null instead of throwing on invalid JSON.
  dynamic tryDecode(String source) {
    try { return jsonDecode(source); } catch (_) { return null; }
  }
}
