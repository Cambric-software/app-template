import 'dart:async';

/// Publish/subscribe event bus for decoupled communication.
class EventBusService {
  final Map<Type, List<Function>> _listeners = {};
  final StreamController<Object> _controller = StreamController.broadcast();

  String get name => 'EventBusService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {
    _listeners.clear();
    await _controller.close();
  }
  Future<bool> healthCheck() async => !_controller.isClosed;

  Stream<T> on<T>() => _controller.stream.where((e) => e is T).cast<T>();

  void emit<T>(T event) {
    if (!_controller.isClosed) _controller.add(event as Object);
    final handlers = _listeners[T];
    if (handlers != null) {
      for (final h in List.of(handlers)) { try { (h as void Function(T))(event); } catch (_) {} }
    }
  }

  void subscribe<T>(void Function(T) handler) =>
      _listeners.putIfAbsent(T, () => []).add(handler);

  void unsubscribe<T>(void Function(T) handler) =>
      _listeners[T]?.remove(handler);
}
