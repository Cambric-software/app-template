import 'package:flutter/widgets.dart';

/// Tracks the Flutter application lifecycle and exposes current state.
///
/// Attach this service during `main()` before `runApp()`.  It registers
/// as a [WidgetsBindingObserver] and keeps the current [AppLifecycleState]
/// up to date so any part of the application can query it without coupling
/// to widget trees.
class AppLifecycleService with WidgetsBindingObserver {
  AppLifecycleState _state = AppLifecycleState.resumed;

  bool _initialized = false;

  /// Current Flutter application lifecycle state.
  AppLifecycleState get state => _state;

  /// Whether the application is currently in the foreground.
  bool get isActive =>
      _state == AppLifecycleState.resumed ||
      _state == AppLifecycleState.inactive;

  /// Whether the application is backgrounded or hidden.
  bool get isBackground =>
      _state == AppLifecycleState.paused ||
      _state == AppLifecycleState.detached ||
      _state == AppLifecycleState.hidden;

  /// Registers this service with [WidgetsBinding].
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<void> initialize() async {
    if (_initialized) return;
    WidgetsBinding.instance.addObserver(this);
    _initialized = true;
  }

  /// Removes this service from [WidgetsBinding].
  Future<void> dispose() async {
    if (!_initialized) return;
    WidgetsBinding.instance.removeObserver(this);
    _initialized = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _state = state;
  }
}
