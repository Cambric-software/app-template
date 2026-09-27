import 'dart:async';

typedef RequestRunner<T> = Future<T> Function();

class _QueuedRequest {
  final String id;
  final Future<dynamic> Function() run;
  final Completer<dynamic> completer = Completer<dynamic>();
  _QueuedRequest({required this.id, required this.run});
}

/// Serializes HTTP requests to prevent flooding the server.
class RequestQueueService {
  final int maxConcurrent;
  final _queue = <_QueuedRequest>[];
  int _running = 0;

  RequestQueueService({this.maxConcurrent = 2});

  String get name => 'RequestQueueService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async { _queue.clear(); }
  Future<bool> healthCheck() async => true;

  int get pending => _queue.length;
  int get running => _running;

  Future<T> enqueue<T>(String id, Future<T> Function() runner) {
    final completer = Completer<T>();
    final req = _QueuedRequest(
      id: id,
      run: () async => runner(),
    );
    _queue.add(req);
    _drain(req, completer);
    return completer.future;
  }

  void _drain<T>(_QueuedRequest req, Completer<T> completer) {
    if (_running >= maxConcurrent) {
      Future<void>.delayed(const Duration(milliseconds: 50)).then((_) => _drain(req, completer));
      return;
    }
    if (!_queue.contains(req)) return;
    _queue.remove(req);
    _running++;
    req.run().then((val) {
      completer.complete(val as T);
    }).catchError((Object e) {
      completer.completeError(e);
    }).whenComplete(() {
      _running--;
    });
  }
}
