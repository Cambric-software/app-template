import 'package:flutter/foundation.dart';

/// Runs registered cleanup tasks when the application shuts down.
///
/// Usage:
/// ```dart
/// final shutdown = AppShutdownService();
/// shutdown.register('analytics', () async => analytics.flush());
/// shutdown.register('cache', () async => cache.clear());
///
/// // Call before exit:
/// await shutdown.run();
/// ```
class AppShutdownService {
  final Map<String, Future<void> Function()> _handlers = {};

  String get name => 'AppShutdownService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async => _handlers.clear();
  Future<bool> healthCheck() async => true;

  void register(String name, Future<void> Function() handler) {
    _handlers[name] = handler;
  }

  void unregister(String name) => _handlers.remove(name);

  /// Runs all shutdown handlers. Errors are logged but do not abort others.
  Future<void> run() async {
    for (final entry in _handlers.entries) {
      try {
        if (kDebugMode) debugPrint('[Shutdown] Running: ${entry.key}');
        await entry.value();
      } catch (e) {
        if (kDebugMode) debugPrint('[Shutdown] FAILED: ${entry.key} | $e');
      }
    }
  }
}
