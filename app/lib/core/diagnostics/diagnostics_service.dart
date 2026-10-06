import 'dart:io';

import '../config/cambric_config.dart';
import '../lifecycle/version_service.dart';

/// Generates local diagnostic reports for the Cambric app.
///
/// No secrets, no personal data. The user must explicitly request
/// a report — nothing is transmitted automatically.
class DiagnosticsService {
  DiagnosticsService({
    required CambricConfig config,
    required VersionService version,
  })  : _config = config,
        _version = version;

  final CambricConfig _config;
  final VersionService _version;

  final List<_DiagnosticEntry> _errors = [];
  int _errorCount = 0;

  bool _storageHealthy = true;
  bool _networkHealthy = true;
  bool _cacheHealthy = true;

  void setStorageHealthy(bool v) => _storageHealthy = v;
  void setNetworkHealthy(bool v) => _networkHealthy = v;
  void setCacheHealthy(bool v) => _cacheHealthy = v;

  bool get isHealthy =>
      _storageHealthy && _networkHealthy && _cacheHealthy;

  void reportError(String message, {Object? error, StackTrace? stackTrace}) {
    _errorCount++;
    _errors.add(_DiagnosticEntry(
      message: message,
      error: error?.toString(),
      timestamp: DateTime.now(),
    ));
    if (_errors.length > 50) _errors.removeAt(0);
  }

  int get errorCount => _errorCount;

  Future<String> generateReport() async {
    final sb = StringBuffer()
      ..writeln('=== Cambric App Diagnostic Report ===')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln()
      ..writeln('--- Product ---')
      ..writeln('Name:        ${_config.productName}')
      ..writeln('Version:     ${_version.display}')
      ..writeln('Environment: ${_config.environment}')
      ..writeln()
      ..writeln('--- Platform ---')
      ..writeln('OS: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}')
      ..writeln('Dart: ${Platform.version}')
      ..writeln()
      ..writeln('--- Health ---')
      ..writeln('Overall:  ${isHealthy ? "OK" : "DEGRADED"}')
      ..writeln('Storage:  ${_storageHealthy ? "OK" : "FAILED"}')
      ..writeln('Network:  ${_networkHealthy ? "OK" : "FAILED"}')
      ..writeln('Cache:    ${_cacheHealthy ? "OK" : "FAILED"}')
      ..writeln()
      ..writeln('--- Errors (${_errors.length} recent of $_errorCount total) ---');

    for (final e in _errors.take(20)) {
      sb.writeln('[${e.timestamp.toIso8601String()}] ${e.message}');
      if (e.error != null) sb.writeln('  Error: ${e.error}');
    }

    sb.writeln();
    sb.writeln('=== End of Report ===');
    return sb.toString();
  }

  Future<bool> writeReportToFile(File outputFile) async {
    try {
      await outputFile.parent.create(recursive: true);
      await outputFile.writeAsString(await generateReport());
      return true;
    } catch (_) {
      return false;
    }
  }

  void reset() {
    _errors.clear();
    _errorCount = 0;
    _storageHealthy = true;
    _networkHealthy = true;
    _cacheHealthy = true;
  }
}

class _DiagnosticEntry {
  const _DiagnosticEntry({
    required this.message,
    required this.timestamp,
    this.error,
  });
  final String message;
  final DateTime timestamp;
  final String? error;
}
