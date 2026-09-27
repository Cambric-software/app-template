import 'dart:convert';
import 'dart:io';

/// Exports data to JSON, CSV, or plain text files.
class ExportService {
  String get name => 'ExportService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<File> exportJson(
    Map<String, dynamic> data,
    File destination, {
    bool pretty = true,
  }) async {
    await destination.parent.create(recursive: true);
    final content = pretty
        ? const JsonEncoder.withIndent('  ').convert(data)
        : jsonEncode(data);
    await destination.writeAsString(content, flush: true);
    return destination;
  }

  Future<File> exportCsv(
    List<Map<String, String>> rows,
    File destination, {
    String delimiter = ',',
  }) async {
    await destination.parent.create(recursive: true);
    if (rows.isEmpty) {
      await destination.writeAsString('', flush: true);
      return destination;
    }
    final headers = rows.first.keys.toList();
    final lines = <String>[headers.join(delimiter)];
    for (final row in rows) {
      lines.add(headers.map((h) => _quote(row[h] ?? '', delimiter)).join(delimiter));
    }
    await destination.writeAsString(lines.join('\n'), flush: true);
    return destination;
  }

  Future<File> exportText(String content, File destination) async {
    await destination.parent.create(recursive: true);
    await destination.writeAsString(content, flush: true);
    return destination;
  }

  String _quote(String value, String delimiter) {
    if (value.contains(delimiter) || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
