import 'dart:async';

class ScheduledTask {
  final String id;
  final Duration interval;
  final Future<void> Function() run;
  Timer? _timer;
  ScheduledTask({required this.id, required this.interval, required this.run});
}

class SchedulerService {
  final Map<String, ScheduledTask> _tasks = {};

  String get name => 'SchedulerService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async { cancelAll(); }
  Future<bool> healthCheck() async => true;

  void schedule(String id, Duration interval, Future<void> Function() task, {bool runImmediately = false}) {
    cancel(id);
    final t = ScheduledTask(id: id, interval: interval, run: task);
    t._timer = Timer.periodic(interval, (_) async { try { await task(); } catch (_) {} });
    _tasks[id] = t;
    if (runImmediately) task().catchError((_) {});
  }

  void cancel(String id) {
    _tasks[id]?._timer?.cancel();
    _tasks.remove(id);
  }

  void cancelAll() {
    for (final t in _tasks.values) { t._timer?.cancel(); }
    _tasks.clear();
  }

  bool isRunning(String id) => _tasks.containsKey(id);
  int get count => _tasks.length;
}
