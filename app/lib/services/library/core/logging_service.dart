import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Log severity levels.
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical;

  bool operator >=(LogLevel other) => index >= other.index;
}

/// A single log entry.
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final Object? error;
  final StackTrace? stackTrace;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() {
    final ts = timestamp.toIso8601String();
    final lvl = level.name.toUpperCase().padRight(8);
    final t = tag != null ? '[$tag] ' : '';
    final err = error != null ? ' | $error' : '';
    return '$ts $lvl $t$message$err';
  }
}

/// Structured logging service with console output, optional file logging,
/// log level filtering, and in-memory buffer for diagnostics.
///
/// Usage:
/// ```dart
/// final log = LoggingService(minLevel: LogLevel.info, tag: 'App');
/// await log.initialize();
///
/// log.info('Application started');
/// log.warning('Cache miss', tag: 'Cache');
/// log.error('Network failed', error: e, stackTrace: st);
/// ```
class LoggingService {
  final LogLevel minLevel;
  final String? defaultTag;
  final int maxBufferEntries;
  final bool writeToFile;

  final List<LogEntry> _buffer = [];
  File? _logFile;
  bool _initialized = false;

  LoggingService({
    this.minLevel = LogLevel.debug,
    this.defaultTag,
    this.maxBufferEntries = 500,
    this.writeToFile = false,
  });

  String get name => 'LoggingService';
  bool get isAvailable => _initialized;

  Future<void> initialize() async {
    if (writeToFile) {
      try {
        final dir = await getApplicationSupportDirectory();
        final logsDir = Directory('${dir.path}${Platform.pathSeparator}Logs');
        await logsDir.create(recursive: true);
        _logFile = File(
          '${logsDir.path}${Platform.pathSeparator}app.log',
        );
      } catch (_) {
        // File logging unavailable — continue without it.
      }
    }
    _initialized = true;
    info('LoggingService initialized', tag: 'LoggingService');
  }

  Future<void> dispose() async {
    _buffer.clear();
    _initialized = false;
  }

  Future<bool> healthCheck() async => _initialized;

  // ── log methods ────────────────────────────────────────────────────────────

  void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);

  void info(String message, {String? tag, Object? error}) =>
      _log(LogLevel.info, message, tag: tag, error: error);

  void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);

  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);

  void critical(String message, {String? tag, Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.critical, message, tag: tag, error: error, stackTrace: stackTrace);

  // ── buffer ─────────────────────────────────────────────────────────────────

  /// Returns recent log entries at or above [minLevel].
  List<LogEntry> recent({int count = 100, LogLevel? level}) {
    final filter = level ?? minLevel;
    final entries = _buffer
        .where((e) => e.level >= filter)
        .toList();
    if (entries.length <= count) return entries;
    return entries.sublist(entries.length - count);
  }

  /// Clears the in-memory buffer.
  void clearBuffer() => _buffer.clear();

  // ── private ────────────────────────────────────────────────────────────────

  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < minLevel.index) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag ?? defaultTag,
      error: error,
      stackTrace: stackTrace,
    );

    // Keep buffer bounded.
    _buffer.add(entry);
    if (_buffer.length > maxBufferEntries) {
      _buffer.removeAt(0);
    }

    // Console output in debug mode.
    if (kDebugMode) {
      debugPrint(entry.toString());
      if (stackTrace != null && level >= LogLevel.error) {
        debugPrint(stackTrace.toString());
      }
    }

    // File output.
    if (_logFile != null) {
      _appendToFile(entry);
    }
  }

  void _appendToFile(LogEntry entry) {
    try {
      _logFile!.writeAsStringSync(
        '${entry.toString()}\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // Never crash the application because logging failed.
    }
  }
}
