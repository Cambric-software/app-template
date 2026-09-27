import 'dart:convert';
import 'dart:io';

/// Imports data from JSON or CSV files.
class ImportService {
  String get name => 'ImportService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<Map<String, dynamic>?> importJson(File file) async {
    if (!await file.exists()) return null;
    try {
      final decoded = jsonDecode(await file.readAsString());
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, String>>?> importCsv(
    File file, {
    String delimiter = ',',
    bool hasHeaders = true,
  }) async {
    if (!await file.exists()) return null;
    try {
      final lines = (await file.readAsLines())
          .where((l) => l.trim().isNotEmpty)
          .toList();
      if (lines.isEmpty) return [];
      if (!hasHeaders) return null;
      final headers = lines.first.split(delimiter);
      return lines.skip(1).map((line) {
        final cols = line.split(delimiter);
        final map = <String, String>{};
        for (var i = 0; i < headers.length; i++) {
          map[headers[i]] = i < cols.length ? cols[i] : '';
        }
        return map;
      }).toList();
    } catch (_) {
      return null;
    }
  }

  Future<String?> importText(File file) async {
    if (!await file.exists()) return null;
    try {
      return await file.readAsString();
    } catch (_) {
      return null;
    }
  }
}
