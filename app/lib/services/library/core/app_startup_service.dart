import 'package:flutter/foundation.dart';

/// A single startup task.
class StartupTask {
  final String name;
  final Future<void> Function() run;
  final bool critical;

  const StartupTask({
    required this.name,
    required this.run,
    this.critical = true,
  });
}

/// Result of the startup sequence.
class StartupResult {
  final bool succeeded;
  final List<String> completed;
  final List<String> failed;
  final Duration elapsed;

  const StartupResult({
    required this.succeeded,
    required this.completed,
    required this.failed,
    required this.elapsed,
  });
}

/// Runs an ordered sequence of startup tasks with error isolation.
///
/// Critical tasks that fail abort the sequence.
/// Non-critical tasks log a warning and continue.
///
/// Usage:
/// ```dart
/// final startup = AppStartupService();
/// startup.add(StartupTask(
///   name: 'Load config',
///   run: () async => config = await CambricConfig.load(...),
/// ));
/// startup.add(StartupTask(
///   name: 'Init cache',
///   run: () async => cache.initialize(),
///   critical: false,
/// ));
///
/// final result = await startup.run();
/// ```
class AppStartupService {
  final List<StartupTask> _tasks = [];

  String get name => 'AppStartupService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async => _tasks.clear();
  Future<bool> healthCheck() async => true;

  void add(StartupTask task) => _tasks.add(task);

  void addAll(List<StartupTask> tasks) => _tasks.addAll(tasks);

  Future<StartupResult> run() async {
    final start = DateTime.now();
    final completed = <String>[];
    final failed = <String>[];

    for (final task in _tasks) {
      try {
        if (kDebugMode) debugPrint('[Startup] Running: ${task.name}');
        await task.run();
        completed.add(task.name);
        if (kDebugMode) debugPrint('[Startup] OK: ${task.name}');
      } catch (e, st) {
        failed.add(task.name);
        if (kDebugMode) {
          debugPrint('[Startup] FAILED: ${task.name} | $e');
          debugPrint(st.toString());
        }
        if (task.critical) {
          return StartupResult(
            succeeded: false,
            completed: completed,
            failed: failed,
            elapsed: DateTime.now().difference(start),
          );
        }
      }
    }

    return StartupResult(
      succeeded: failed.isEmpty,
      completed: completed,
      failed: failed,
      elapsed: DateTime.now().difference(start),
    );
  }
}
