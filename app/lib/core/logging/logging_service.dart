import 'package:logging/logging.dart';

/// Structured logging service for Cambric applications.
///
/// Wraps dart:logging to provide level-filtered output and a rolling
/// in-memory record store for diagnostic reports.
///
/// Initialize once at startup:
/// ```dart
/// CambricLogger.initialize(level: Level.INFO);
/// final log = CambricLogger.get('MyService');
/// log.info('Service started');
/// ```
class CambricLogger {
  CambricLogger._();

  static bool _initialized = false;
  static final List<LogRecord> _recentRecords = [];
  static const int _maxRecords = 200;

  /// Initialize the root logger. Call once before any other logging.
  static void initialize({
    Level level = Level.INFO,
    bool verbose = false,
  }) {
    if (_initialized) return;
    _initialized = true;

    Logger.root.level = verbose ? Level.ALL : level;
    Logger.root.onRecord.listen(_handle);
  }

  static void _handle(LogRecord r) {
    _recentRecords.add(r);
    if (_recentRecords.length > _maxRecords) _recentRecords.removeAt(0);

    final line = '[${r.level.name}] ${r.loggerName}: ${r.message}';
    if (r.error != null) {
      // ignore: avoid_print
      print('$line\n  ${r.error}\n  ${r.stackTrace ?? ""}');
    } else {
      // ignore: avoid_print
      print(line);
    }
  }

  /// Get a named logger for a class or module.
  static Logger get(String name) => Logger(name);

  /// Recent log records — used by DiagnosticsService.
  static List<LogRecord> get recentRecords =>
      List.unmodifiable(_recentRecords);

  static void clearRecords() => _recentRecords.clear();

  static void setLevel(Level level) => Logger.root.level = level;
}
