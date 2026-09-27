import 'dart:async';

class ManagedTimer {
  final String id;
  Timer? _timer;
  bool _cancelled = false;
  ManagedTimer(this.id);
  bool get isActive => _timer?.isActive ?? false;
  void cancel() { _cancelled = true; _timer?.cancel(); }
}

class TimerService {
  final Map<String, ManagedTimer> _timers = {};

  String get name => 'TimerService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async { cancelAll(); }
  Future<bool> healthCheck() async => true;

  ManagedTimer after(String id, Duration delay, void Function() callback) {
    cancel(id);
    final t = ManagedTimer(id);
    t._timer = Timer(delay, () { if (!t._cancelled) callback(); _timers.remove(id); });
    _timers[id] = t;
    return t;
  }

  ManagedTimer every(String id, Duration interval, void Function() callback) {
    cancel(id);
    final t = ManagedTimer(id);
    t._timer = Timer.periodic(interval, (_) { if (!t._cancelled) callback(); });
    _timers[id] = t;
    return t;
  }

  void cancel(String id) { _timers[id]?.cancel(); _timers.remove(id); }
  void cancelAll() { for (final t in _timers.values) { t.cancel(); } _timers.clear(); }
  bool exists(String id) => _timers.containsKey(id);
}
