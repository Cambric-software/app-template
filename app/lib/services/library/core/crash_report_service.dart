import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// A recorded crash event.
class CrashRecord {
  final String id;
  final DateTime timestamp;
  final String error;
  final String stackTrace;
  final Map<String, dynamic> context;
  final bool reported;

  const CrashRecord({
    required this.id,
    required this.timestamp,
    required this.error,
    required this.stackTrace,
    this.context = const {},
    this.reported = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'error': error,
        'stackTrace': stackTrace,
        'context': context,
        'reported': reported,
      };

  factory CrashRecord.fromJson(Map<String, dynamic> json) => CrashRecord(
        id: json['id']?.toString() ?? '',
        timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
            DateTime.now(),
        error: json['error']?.toString() ?? '',
        stackTrace: json['stackTrace']?.toString() ?? '',
        context: (json['context'] as Map<String, dynamic>?) ?? {},
        reported: json['reported'] as bool? ?? false,
      );
}

/// Records and persists crash events locally.
///
/// Crash data stays on-device by default — never sent anywhere unless
/// the product explicitly implements user-approved reporting.
///
/// Hooks into Flutter's [FlutterError.onError] and [PlatformDispatcher].
///
/// Usage:
/// ```dart
/// final crashes = CrashReportService();
/// await crashes.initialize();
/// crashes.setContext({'version': '1.4.3', 'env': 'production'});
///
/// final pending = await crashes.pendingReports();
/// ```
class CrashReportService {
  Map<String, dynamic> _context = {};
  bool _initialized = false;

  String get name => 'CrashReportService';
  bool get isAvailable => _initialized;

  Future<void> initialize() async {
    _initialized = true;

    // Override Flutter error handler.
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _record(
        details.exception.toString(),
        details.stack?.toString() ?? '',
      );
    };

    // Override platform dispatcher for async errors.
    PlatformDispatcher.instance.onError = (error, stack) {
      _record(error.toString(), stack.toString());
      return false; // Let platform also handle.
    };
  }

  Future<void> dispose() async {
    _initialized = false;
  }

  Future<bool> healthCheck() async => _initialized;

  /// Sets key/value context included with every crash report.
  void setContext(Map<String, dynamic> context) {
    _context = {..._context, ...context};
  }

  /// Manually records an error as a crash event.
  void record(Object error, StackTrace stackTrace) {
    _record(error.toString(), stackTrace.toString());
  }

  /// Returns all pending (unacknowledged) crash records from disk.
  Future<List<CrashRecord>> pendingReports() async {
    final dir = await _crashDir();
    final records = <CrashRecord>[];

    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final raw = await entity.readAsString();
          final data = jsonDecode(raw) as Map<String, dynamic>;
          records.add(CrashRecord.fromJson(data));
        } catch (_) {}
      }
    }

    records.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return records;
  }

  /// Deletes all crash records from disk.
  Future<void> clearReports() async {
    final dir = await _crashDir();
    await for (final entity in dir.list()) {
      if (entity is File) await entity.delete();
    }
  }

  // ── private ────────────────────────────────────────────────────────────────

  void _record(String error, String stackTrace) {
    final record = CrashRecord(
      id: 'crash_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      context: Map.from(_context),
    );

    // Write to disk asynchronously — never block the crash handler.
    _persistRecord(record);

    if (kDebugMode) {
      debugPrint('[CrashReport] ${record.error}');
    }
  }

  Future<void> _persistRecord(CrashRecord record) async {
    try {
      final dir = await _crashDir();
      final file = File(
        '${dir.path}${Platform.pathSeparator}${record.id}.json',
      );
      await file.writeAsString(jsonEncode(record.toJson()), flush: true);
    } catch (_) {}
  }

  Future<Directory> _crashDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(
      '${base.path}${Platform.pathSeparator}CrashReports',
    );
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}
