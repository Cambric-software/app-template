import 'package:flutter/foundation.dart';

/// Observable value with typed change notifications.
class Observable<T> extends ChangeNotifier {
  T _value;
  Observable(this._value);
  T get value => _value;
  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListeners();
  }
}

class ObserverService {
  final Map<String, Observable> _observables = {};

  String get name => 'ObserverService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {
    for (final o in _observables.values) { o.dispose(); }
    _observables.clear();
  }
  Future<bool> healthCheck() async => true;

  Observable<T> observe<T>(String key, T initialValue) {
    if (!_observables.containsKey(key)) {
      _observables[key] = Observable<T>(initialValue);
    }
    return _observables[key] as Observable<T>;
  }

  void set<T>(String key, T value) {
    final obs = _observables[key];
    if (obs is Observable<T>) obs.value = value;
  }

  T? get<T>(String key) {
    final obs = _observables[key];
    return obs is Observable<T> ? obs.value : null;
  }
}
