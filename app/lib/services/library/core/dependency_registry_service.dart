/// Lightweight service locator / dependency registry.
///
/// Register services once at startup, resolve them anywhere.
/// Supports optional services (returns null when not registered).
///
/// Usage:
/// ```dart
/// // Register
/// DependencyRegistry.instance.register<LoggingService>(LoggingService());
///
/// // Resolve (throws if not registered)
/// final log = DependencyRegistry.instance.get<LoggingService>();
///
/// // Optional resolve (null-safe)
/// final log = DependencyRegistry.instance.find<LoggingService>();
/// ```
class DependencyRegistry {
  DependencyRegistry._();

  static final DependencyRegistry instance = DependencyRegistry._();

  final Map<Type, Object> _registry = {};

  /// Registers [service] under type [T].
  void register<T extends Object>(T service) {
    _registry[T] = service;
  }

  /// Returns service of type [T], or throws if not registered.
  T get<T extends Object>() {
    final service = _registry[T];
    if (service is T) return service;
    throw StateError(
      'Service ${T.toString()} is not registered in DependencyRegistry. '
      'Call register<${T.toString()}>() during app initialization.',
    );
  }

  /// Returns service of type [T] or null if not registered.
  T? find<T extends Object>() {
    final service = _registry[T];
    return service is T ? service : null;
  }

  /// Returns true if [T] is registered.
  bool has<T extends Object>() => _registry.containsKey(T);

  /// Removes the registration for [T].
  void unregister<T extends Object>() => _registry.remove(T);

  /// Clears all registrations.
  void clear() => _registry.clear();

  /// Returns the count of registered services.
  int get count => _registry.length;
}

/// Alias for convenience.
typedef DependencyRegistryService = DependencyRegistry;
