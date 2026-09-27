import 'dart:async';

/// Timeout presets for common operations.
abstract class Timeouts {
  static const Duration fast = Duration(seconds: 5);
  static const Duration network = Duration(seconds: 15);
  static const Duration download = Duration(minutes: 5);
  static const Duration install = Duration(minutes: 10);
  static const Duration userAction = Duration(seconds: 30);
}

/// Wraps futures with configurable timeouts and clear timeout messages.
///
/// Usage:
/// ```dart
/// final ts = TimeoutService();
///
/// final result = await ts.run(
///   () => http.get(uri),
///   timeout: Timeouts.network,
///   label: 'GitHub release fetch',
/// );
/// ```
class TimeoutService {
  String get name => 'TimeoutService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Runs [operation] and throws [TimeoutException] if [timeout] elapses.
  Future<T> run<T>(
    Future<T> Function() operation, {
    Duration timeout = Timeouts.network,
    String? label,
  }) async {
    try {
      return await operation().timeout(timeout);
    } on TimeoutException {
      throw TimeoutException(
        label != null
            ? 'Operation timed out after ${timeout.inSeconds}s: $label'
            : 'Operation timed out after ${timeout.inSeconds}s.',
        timeout,
      );
    }
  }

  /// Runs [operation] with timeout, returning [fallback] on timeout instead
  /// of throwing.
  Future<T> runOrFallback<T>(
    Future<T> Function() operation, {
    required T fallback,
    Duration timeout = Timeouts.network,
    String? label,
  }) async {
    try {
      return await run(operation, timeout: timeout, label: label);
    } on TimeoutException {
      return fallback;
    }
  }
}
