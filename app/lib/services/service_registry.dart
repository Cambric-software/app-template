/// Central registry for optional Cambric services.
///
/// Services are deliberately not instantiated automatically.
/// A project should register only what it actually uses.
class ServiceRegistry {
  final Map<Type, Object> _services = <Type, Object>{};

  void register<T extends Object>(T service) {
    _services[T] = service;
  }

  T? get<T extends Object>() {
    final value = _services[T];
    return value is T ? value : null;
  }

  bool contains<T extends Object>() {
    return _services.containsKey(T);
  }

  void clear() {
    _services.clear();
  }

  int get length => _services.length;
}
