import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// An operation queued for execution when connectivity returns.
class OfflineOperation {
  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime queuedAt;
  int attempts;

  OfflineOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.queuedAt,
    this.attempts = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'payload': payload,
        'queuedAt': queuedAt.toIso8601String(),
        'attempts': attempts,
      };

  factory OfflineOperation.fromJson(Map<String, dynamic> json) =>
      OfflineOperation(
        id: json['id'] as String,
        type: json['type'] as String,
        payload: (json['payload'] as Map<String, dynamic>?) ?? {},
        queuedAt: DateTime.tryParse(json['queuedAt'] as String? ?? '') ?? DateTime.now(),
        attempts: json['attempts'] as int? ?? 0,
      );
}

/// Queues operations that cannot complete while offline and retries them
/// when connectivity returns.
///
/// Usage:
/// ```dart
/// final queue = OfflineQueueService();
/// await queue.initialize();
/// await queue.enqueue(OfflineOperation(
///   id: uuid(), type: 'sync_settings',
///   payload: {'key': 'value'}, queuedAt: DateTime.now(),
/// ));
/// // On reconnect:
/// await queue.flush((op) async => processOperation(op));
/// ```
class OfflineQueueService {
  late File _file;
  List<OfflineOperation> _ops = [];
  bool _initialized = false;

  String get name => 'OfflineQueueService';
  bool get isAvailable => _initialized;
  Future<bool> healthCheck() async => _initialized;

  Future<void> initialize() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}${Platform.pathSeparator}OfflineQueue');
    await dir.create(recursive: true);
    _file = File('${dir.path}${Platform.pathSeparator}queue.json');
    await _load();
    _initialized = true;
  }

  Future<void> dispose() async { _initialized = false; }

  List<OfflineOperation> get pending => List.unmodifiable(_ops);
  int get count => _ops.length;

  Future<void> enqueue(OfflineOperation op) async {
    _ops.add(op);
    await _persist();
  }

  Future<int> flush(Future<bool> Function(OfflineOperation) executor) async {
    var processed = 0;
    final toRemove = <String>[];

    for (final op in List.of(_ops)) {
      op.attempts++;
      try {
        final success = await executor(op);
        if (success) {
          toRemove.add(op.id);
          processed++;
        }
      } catch (_) {}
    }

    _ops.removeWhere((o) => toRemove.contains(o.id));
    await _persist();
    return processed;
  }

  Future<void> clear() async {
    _ops.clear();
    await _persist();
  }

  Future<void> _load() async {
    if (!await _file.exists()) { _ops = []; return; }
    try {
      final list = jsonDecode(await _file.readAsString()) as List<dynamic>;
      _ops = list.whereType<Map<String, dynamic>>().map(OfflineOperation.fromJson).toList();
    } catch (_) { _ops = []; }
  }

  Future<void> _persist() async {
    await _file.writeAsString(jsonEncode(_ops.map((o) => o.toJson()).toList()), flush: true);
  }
}
