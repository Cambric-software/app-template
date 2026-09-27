import 'dart:async';

/// A background task with progress reporting.
typedef TaskRunner = Future<void> Function(BackgroundTask task);

class BackgroundTask {
  final String id;
  final String label;
  double progress;
  bool cancelled;
  String? error;

  BackgroundTask({required this.id, required this.label})
      : progress = 0,
        cancelled = false;

  void reportProgress(double value) => progress = value.clamp(0.0, 1.0);
  void cancel() => cancelled = true;
}

/// Runs named background tasks with progress tracking.
class BackgroundTaskService {
  final Map<String, BackgroundTask> _tasks = {};

  String get name => 'BackgroundTaskService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async { _tasks.clear(); }
  Future<bool> healthCheck() async => true;

  BackgroundTask? get(String id) => _tasks[id];
  List<BackgroundTask> get all => _tasks.values.toList();
  bool isRunning(String id) => _tasks.containsKey(id);

  Future<void> run(String id, String label, TaskRunner runner) async {
    if (_tasks.containsKey(id)) return; // Already running.
    final task = BackgroundTask(id: id, label: label);
    _tasks[id] = task;
    try {
      await runner(task);
    } catch (e) {
      task.error = e.toString();
    } finally {
      _tasks.remove(id);
    }
  }

  void cancel(String id) => _tasks[id]?.cancel();
}
