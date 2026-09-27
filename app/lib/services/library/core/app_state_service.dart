import 'package:flutter/foundation.dart';

/// Cambric application runtime states.
enum AppState {
  /// Before initialization has started.
  initializing,

  /// Core services are loading.
  loading,

  /// Application is ready and active.
  ready,

  /// Application is in the background.
  background,

  /// Application has been suspended.
  suspended,

  /// Application is shutting down.
  shuttingDown,

  /// An unrecoverable error has occurred.
  error,
}

/// Manages and broadcasts the application runtime state.
///
/// Combine with [AppLifecycleService] to automatically transition
/// between foreground/background states.
///
/// Usage:
/// ```dart
/// final appState = AppStateService();
/// appState.addListener(() => print('State: ${appState.state}'));
/// appState.transition(AppState.ready);
/// ```
class AppStateService extends ChangeNotifier {
  AppState _state = AppState.initializing;
  String? _errorMessage;
  final List<void Function(AppState prev, AppState next)> _transitionListeners = [];

  String get name => 'AppStateService';
  bool get isAvailable => true;
  Future<void> initialize() async => transition(AppState.loading);
  @override
  void dispose() {
    _transitionListeners.clear();
    super.dispose();
  }
  Future<bool> healthCheck() async => _state == AppState.ready;

  AppState get state => _state;
  String? get errorMessage => _errorMessage;

  bool get isReady => _state == AppState.ready;
  bool get isLoading => _state == AppState.loading || _state == AppState.initializing;
  bool get hasError => _state == AppState.error;

  /// Transitions to a new [AppState].
  void transition(AppState next, {String? errorMessage}) {
    if (_state == next) return;
    final prev = _state;
    _state = next;
    _errorMessage = next == AppState.error ? errorMessage : null;

    for (final listener in List.of(_transitionListeners)) {
      try { listener(prev, next); } catch (_) {}
    }
    notifyListeners();

    if (kDebugMode) {
      debugPrint('[AppState] ${prev.name} → ${next.name}');
    }
  }

  void onTransition(void Function(AppState prev, AppState next) callback) {
    _transitionListeners.add(callback);
  }
}
