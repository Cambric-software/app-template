import 'dart:io';

/// A diagnostic report snapshot of the current application state.
class DiagnosticsReport {
  final Map<String, dynamic> data;
  final DateTime generatedAt;

  const DiagnosticsReport({
    required this.data,
    required this.generatedAt,
  });

  /// Returns the report as a human-readable string (secrets redacted).
  String toReadableString() {
    final lines = <String>['=== Cambric Diagnostics Report ==='];
    lines.add('Generated: ${generatedAt.toIso8601String()}');
    lines.add('');
    _flatten(data, '', lines);
    return lines.join('\n');
  }

  void _flatten(dynamic value, String prefix, List<String> lines) {
    if (value is Map<String, dynamic>) {
      for (final entry in value.entries) {
        final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
        _flatten(entry.value, key, lines);
      }
    } else {
      lines.add('  ${prefix.padRight(40)} $value');
    }
  }

  Map<String, dynamic> toJson() => {
        'generatedAt': generatedAt.toIso8601String(),
        'data': data,
      };
}

/// Collects and exports a safe diagnostic report of the application state.
///
/// All sensitive values are redacted automatically.
///
/// Usage:
/// ```dart
/// final diag = DiagnosticsService();
/// diag.addSection('App', {'version': '1.4.3', 'env': 'production'});
/// diag.addSection('Platform', {'os': Platform.operatingSystem});
///
/// final report = diag.generate();
/// print(report.toReadableString());
/// ```
class DiagnosticsService {
  final Map<String, Map<String, dynamic>> _sections = {};

  static const _redactedKeys = {
    'password', 'secret', 'token', 'api_key', 'apikey',
    'credential', 'private_key', 'authorization',
  };

  String get name => 'DiagnosticsService';
  bool get isAvailable => true;
  Future<void> initialize() async {
    // Auto-populate platform section.
    addSection('Platform', {
      'os': Platform.operatingSystem,
      'osVersion': Platform.operatingSystemVersion,
      'dart': Platform.version,
      'processors': Platform.numberOfProcessors,
      'locale': Platform.localeName,
    });
  }
  Future<void> dispose() async => _sections.clear();
  Future<bool> healthCheck() async => true;

  /// Registers a named section of diagnostic data.
  void addSection(String name, Map<String, dynamic> data) {
    _sections[name] = _redact(data);
  }

  /// Updates a single key within an existing section.
  void updateSection(String name, String key, dynamic value) {
    _sections.putIfAbsent(name, () => {})[key] =
        _redactedKeys.contains(key.toLowerCase()) ? '[REDACTED]' : value;
  }

  /// Generates a [DiagnosticsReport] from all registered sections.
  DiagnosticsReport generate() {
    return DiagnosticsReport(
      data: Map.unmodifiable(_sections),
      generatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> _redact(Map<String, dynamic> input) {
    return input.map((k, v) {
      if (_redactedKeys.contains(k.toLowerCase())) {
        return MapEntry(k, '[REDACTED]');
      }
      if (v is Map<String, dynamic>) {
        return MapEntry(k, _redact(v));
      }
      return MapEntry(k, v);
    });
  }
}
