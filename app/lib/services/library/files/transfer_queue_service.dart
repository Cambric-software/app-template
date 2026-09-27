import 'dart:async';

/// Status of a queued transfer.
enum TransferStatus { pending, running, completed, failed, cancelled }

/// A single item in the transfer queue.
class TransferItem {
  final String id;
  final String url;
  final String localPath;
  TransferStatus status;
  double progress;
  String? error;

  TransferItem({
    required this.id,
    required this.url,
    required this.localPath,
    this.status = TransferStatus.pending,
    this.progress = 0.0,
    this.error,
  });
}

/// Manages a queue of download/upload operations.
///
/// Processes transfers one at a time by default.
/// Notify completion via [onComplete] callback.
class TransferQueueService {
  final List<TransferItem> _queue = [];
  bool _running = false;
  Future<void> Function(TransferItem)? _processor;
  void Function(TransferItem)? onComplete;
  void Function(TransferItem)? onFailed;

  String get name => 'TransferQueueService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async { _queue.clear(); }
  Future<bool> healthCheck() async => true;

  List<TransferItem> get queue => List.unmodifiable(_queue);
  List<TransferItem> get pending =>
      _queue.where((i) => i.status == TransferStatus.pending).toList();
  bool get isRunning => _running;

  void setProcessor(Future<void> Function(TransferItem) processor) {
    _processor = processor;
  }

  void enqueue(TransferItem item) {
    _queue.add(item);
    _processNext();
  }

  void cancel(String id) {
    final item = _queue.where((i) => i.id == id).firstOrNull;
    if (item != null && item.status == TransferStatus.pending) {
      item.status = TransferStatus.cancelled;
    }
  }

  void clearCompleted() {
    _queue.removeWhere((i) =>
        i.status == TransferStatus.completed ||
        i.status == TransferStatus.cancelled);
  }

  Future<void> _processNext() async {
    if (_running || _processor == null) return;
    final next = _queue
        .where((i) => i.status == TransferStatus.pending)
        .firstOrNull;
    if (next == null) return;

    _running = true;
    next.status = TransferStatus.running;

    try {
      await _processor!(next);
      next.status = TransferStatus.completed;
      next.progress = 1.0;
      onComplete?.call(next);
    } catch (e) {
      next.status = TransferStatus.failed;
      next.error = e.toString();
      onFailed?.call(next);
    } finally {
      _running = false;
      _processNext();
    }
  }
}
