import 'dart:async';
import 'dart:math';

/// Configuration for retry behavior.
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;
  final bool jitter;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
    this.jitter = true,
  });

  /// Calculates the delay before attempt [attemptNumber] (1-based).
  Duration delayFor(int attemptNumber) {
    if (attemptNumber <= 1) return Duration.zero;
    final base = initialDelay.inMilliseconds *
        pow(backoffMultiplier, attemptNumber - 2);
    var ms = base.toInt().clamp(0, maxDelay.inMilliseconds);
    if (jitter) {
      ms = (ms * (0.75 + Random().nextDouble() * 0.5)).toInt();
    }
    return Duration(milliseconds: ms);
  }

  static const RetryConfig none = RetryConfig(maxAttempts: 1);
  static const RetryConfig quick = RetryConfig(
    maxAttempts: 3,
    initialDelay: Duration(milliseconds: 200),
  );
  static const RetryConfig network = RetryConfig(
    maxAttempts: 4,
    initialDelay: Duration(seconds: 2),
    backoffMultiplier: 2.0,
    maxDelay: Duration(seconds: 15),
  );
}

/// Result of a retry run.
class RetryResult<T> {
  final T? value;
  final int attempts;
  final bool succeeded;
  final Object? lastError;

  const RetryResult({
    this.value,
    required this.attempts,
    required this.succeeded,
    this.lastError,
  });
}

/// Executes operations with configurable retry and exponential backoff.
///
/// Usage:
/// ```dart
/// final retry = RetryService();
/// final result = await retry.run(
///   () => http.get(uri),
///   config: RetryConfig.network,
///   retryIf: (e) => e is SocketException,
/// );
/// if (result.succeeded) print(result.value);
/// ```
class RetryService {
  String get name => 'RetryService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Runs [operation] with retry according to [config].
  ///
  /// [retryIf] is an optional predicate — if provided, only retries when
  /// it returns `true` for the thrown exception.
  Future<RetryResult<T>> run<T>(
    Future<T> Function() operation, {
    RetryConfig config = const RetryConfig(),
    bool Function(Object error)? retryIf,
    void Function(int attempt, Object error)? onRetry,
  }) async {
    Object? lastError;

    for (var attempt = 1; attempt <= config.maxAttempts; attempt++) {
      final delay = config.delayFor(attempt);
      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
      }

      try {
        final value = await operation();
        return RetryResult(
          value: value,
          attempts: attempt,
          succeeded: true,
        );
      } catch (e) {
        lastError = e;

        final shouldRetry = retryIf == null || retryIf(e);
        final hasMoreAttempts = attempt < config.maxAttempts;

        if (shouldRetry && hasMoreAttempts) {
          onRetry?.call(attempt, e);
          continue;
        }

        break;
      }
    }

    return RetryResult(
      attempts: config.maxAttempts,
      succeeded: false,
      lastError: lastError,
    );
  }
}
