/// Minimal XML builder and simple key/value parser.
///
/// Not a full-featured XML library. Handles simple structured config
/// and manifest files without external dependencies.
///
/// For complex XML, add the `xml` pub package.
class XmlService {
  String get name => 'XmlService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Builds a simple XML document from a nested map.
  ///
  /// Example:
  /// ```dart
  /// xml.build('root', {'name': 'Cambric', 'version': '1.0'})
  /// // <root><name>Cambric</name><version>1.0</version></root>
  /// ```
  String build(String rootTag, Map<String, dynamic> data) {
    final buf = StringBuffer();
    buf.write('<?xml version="1.0" encoding="UTF-8"?>');
    buf.write('<$rootTag>');
    _writeNode(data, buf);
    buf.write('</$rootTag>');
    return buf.toString();
  }

  /// Extracts simple text content between matching tags.
  ///
  /// Returns null when the tag is not found.
  String? extractText(String source, String tag) {
    final regex = RegExp('<$tag>([^<]*)</$tag>');
    final match = regex.firstMatch(source);
    return match?.group(1);
  }

  /// Extracts all occurrences of a tag's text content.
  List<String> extractAll(String source, String tag) {
    final regex = RegExp('<$tag>([^<]*)</$tag>');
    return regex.allMatches(source).map((m) => m.group(1) ?? '').toList();
  }

  /// Escapes special XML characters.
  String escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');

  void _writeNode(dynamic value, StringBuffer buf, [String? tag]) {
    if (value is Map<String, dynamic>) {
      for (final entry in value.entries) {
        buf.write('<${entry.key}>');
        _writeNode(entry.value, buf);
        buf.write('</${entry.key}>');
      }
    } else if (value is List) {
      for (final item in value) {
        _writeNode(item, buf, tag);
      }
    } else {
      buf.write(escape(value.toString()));
    }
  }
}
