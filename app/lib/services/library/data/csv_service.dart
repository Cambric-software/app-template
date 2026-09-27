/// Parse and generate CSV data without external dependencies.
///
/// Handles quoted fields, commas within quotes, and newlines.
///
/// Usage:
/// ```dart
/// final csv = CsvService();
///
/// final rows = csv.parse('name,age\n"Smith, John",30\nJane,25');
/// // [['name','age'], ['Smith, John','30'], ['Jane','25']]
///
/// final output = csv.encode(rows);
/// ```
class CsvService {
  final String delimiter;
  final String lineEnding;

  const CsvService({
    this.delimiter = ',',
    this.lineEnding = '\n',
  });

  String get name => 'CsvService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Parses CSV [source] into a list of rows (each row is a list of strings).
  List<List<String>> parse(String source) {
    final rows = <List<String>>[];
    final lines = source.split(RegExp(r'\r?\n'));
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      rows.add(_parseLine(line));
    }
    return rows;
  }

  /// Parses CSV with the first row as headers.
  /// Returns a list of maps keyed by header.
  List<Map<String, String>> parseWithHeaders(String source) {
    final rows = parse(source);
    if (rows.isEmpty) return [];
    final headers = rows.first;
    return rows.skip(1).map((row) {
      final map = <String, String>{};
      for (var i = 0; i < headers.length; i++) {
        map[headers[i]] = i < row.length ? row[i] : '';
      }
      return map;
    }).toList();
  }

  /// Encodes [rows] to a CSV string.
  String encode(List<List<String>> rows) {
    return rows
        .map((row) => row.map(_quoteField).join(delimiter))
        .join(lineEnding);
  }

  List<String> _parseLine(String line) {
    final fields = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == delimiter && !inQuotes) {
        fields.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }
    fields.add(buffer.toString());
    return fields;
  }

  String _quoteField(String field) {
    if (field.contains(delimiter) ||
        field.contains('"') ||
        field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
