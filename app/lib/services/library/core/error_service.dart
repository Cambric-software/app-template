import 'package:flutter/foundation.dart';

/// Categories of application errors.
enum ErrorCategory {
  network,
  storage,
  cache,
  update,
  security,
  validation,
  platform,
  unknown,
}

/// A structured application error.
class AppError {
  final String message;
  final ErrorCategory category;
  final Object? originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final bool recoverable;

  const AppError({
    required this.message,
    this.category = ErrorCategory.unknown,
    this.originalError,
    this.stackTrace,
    required this.timestamp,
    this.recoverable = true,
  });

  @override
  String toString() =>
      '[${category.name}] $message'
      '${originalError != null ? ' | $originalError' : ''}';
}

/// Structured error handling, last-error tracking, and recovery callbacks.
///
/// Usage:
/// ```dart
/// final errors = ErrorService();
/// errors.onError((e) => showSnackbar(e.message));
///
/// errors.report(AppError(
///   message: 'Download failed',
///   category: ErrorCategory.network,
///   originalError: exception,
///   timestamp: DateTime.now(),
/// ));
/// ```
class ErrorService {
  final List<AppError> _history = [];
  final List<void Function(AppError)> _listeners = [];
  int maxHistory;

  ErrorService({this.maxHistory = 100});

  String get name => 'ErrorService';
  bool get isAvailable => true;

  Future<void> initialize() async {}
  Future<void> dispose() async {
    _listeners.clear();
    _history.clear();
  }
  Future<bool> healthCheck() async => true;

  // ── reporting ──────────────────────────────────────────────────────────────

  /// Reports an [AppError] to all registered listeners and history.
  void report(AppError error) {
    _history.add(error);
    if (_history.length > maxHistory) _history.removeAt(0);

    if (kDebugMode) {
      debugPrint('[ErrorService] ${error.toString()}');
      if (error.stackTrace != null) {
        debugPrint(error.stackTrace.toString());
      }
    }

    for (final listener in List.of(_listeners)) {
      try {
        listener(error);
      } catch (_) {
        // Never let a listener crash error reporting.
      }
    }
  }

  /// Convenience: report a simple message.
  void reportMessage(
    String message, {
    ErrorCategory category = ErrorCategory.unknown,
    Object? originalError,
    StackTrace? stackTrace,
    bool recoverable = true,
  }) {
    report(AppError(
      message: message,
      category: category,
      originalError: originalError,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      recoverable: recoverable,
    ));
  }

  // ── listeners ──────────────────────────────────────────────────────────────

  /// Registers a callback invoked whenever an error is reported.
  void onError(void Function(AppError) callback) {
    _listeners.add(callback);
  }

  /// Removes a previously registered callback.
  void removeListener(void Function(AppError) callback) {
    _listeners.remove(callback);
  }

  // ── history ────────────────────────────────────────────────────────────────

  List<AppError> get history => List.unmodifiable(_history);
  AppError? get lastError => _history.isEmpty ? null : _history.last;
  bool get hasErrors => _history.isNotEmpty;

  List<AppError> byCategory(ErrorCategory category) =>
      _history.where((e) => e.category == category).toList();

  void clearHistory() => _history.clear();
}
