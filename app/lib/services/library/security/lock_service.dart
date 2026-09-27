import 'dart:async';

/// Named mutex locks to prevent concurrent access to shared resources.
///
/// Callers wrap critical sections with [withLock]. If the lock is already
/// held, the caller suspends until it is released, then proceeds.
class LockService {
  final Map<String, Completer<void>> _locks = {};

  String get name => 'LockService';
  bool get isAvailable => true;
  Future<void> initialize() async {}

  Future<void> dispose() async {
    _locks.clear();
  }

  Future<bool> healthCheck() async => true;

  /// Returns true if the named lock is currently held.
  bool isLocked(String name) => _locks.containsKey(name);

  /// Acquires the named lock, runs [operation], then releases the lock.
  ///
  /// If the lock is already held this method suspends (without spinning)
  /// until it is released. The lock is always released — even on exception.
  Future<T> withLock<T>(String name, Future<T> Function() operation) async {
    // Wait for any existing holder to finish.
    while (_locks.containsKey(name)) {
      await _locks[name]!.future;
    }

    final completer = Completer<void>();
    _locks[name] = completer;

    try {
      return await operation();
    } finally {
      _locks.remove(name);
      completer.complete();
    }
  }
}
