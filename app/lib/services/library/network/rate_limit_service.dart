import 'dart:async';

/// Enforces a maximum number of operations per time window.
class RateLimitService {
  final int maxRequests;
  final Duration window;
  final List<DateTime> _log = [];

  RateLimitService({this.maxRequests = 10, this.window = const Duration(seconds: 1)});

  String get name => 'RateLimitService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async { _log.clear(); }
  Future<bool> healthCheck() async => true;

  bool get isAllowed {
    _purge();
    return _log.length < maxRequests;
  }

  int get remainingRequests {
    _purge();
    return (maxRequests - _log.length).clamp(0, maxRequests);
  }

  /// Records a request. Returns true if within limit, false if throttled.
  bool consume() {
    _purge();
    if (_log.length >= maxRequests) return false;
    _log.add(DateTime.now());
    return true;
  }

  /// Waits until a request slot is available, then consumes it.
  Future<void> acquire() async {
    while (!consume()) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  void _purge() {
    final cutoff = DateTime.now().subtract(window);
    _log.removeWhere((t) => t.isBefore(cutoff));
  }
}
