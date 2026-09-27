import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// A single audit log entry.
class AuditEntry {
  final String id;
  final DateTime timestamp;
  final String action;
  final String? actor;
  final Map<String, dynamic> details;

  const AuditEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    this.actor,
    this.details = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'action': action,
        if (actor != null) 'actor': actor,
        if (details.isNotEmpty) 'details': details,
      };

  factory AuditEntry.fromJson(Map<String, dynamic> json) => AuditEntry(
        id: json['id']?.toString() ?? '',
        timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
            DateTime.now(),
        action: json['action']?.toString() ?? '',
        actor: json['actor']?.toString(),
        details: (json['details'] as Map<String, dynamic>?) ?? {},
      );

  @override
  String toString() {
    final a = actor != null ? ' [$actor]' : '';
    return '${timestamp.toIso8601String()}$a $action';
  }
}

/// Append-only local audit log.
///
/// Records significant user and system actions for traceability.
/// Each entry is appended to a local JSONL file.
/// Never used for telemetry — stays on device.
///
/// Usage:
/// ```dart
/// final audit = AuditLogService();
/// await audit.initialize();
///
/// await audit.log('user.settings.changed',
///   actor: 'user',
///   details: {'theme': 'dark'},
/// );
///
/// final recent = await audit.recentEntries(count: 50);
/// ```
class AuditLogService {
  File? _logFile;
  bool _initialized = false;

  String get name => 'AuditLogService';
  bool get isAvailable => _initialized;

  Future<void> initialize() async {
    final base = await getApplicationSupportDirectory();
    final logsDir = Directory(
      '${base.path}${Platform.pathSeparator}AuditLog',
    );
    await logsDir.create(recursive: true);
    _logFile = File(
      '${logsDir.path}${Platform.pathSeparator}audit.jsonl',
    );
    _initialized = true;
  }

  Future<void> dispose() async => _initialized = false;
  Future<bool> healthCheck() async => _initialized && _logFile != null;

  /// Appends an audit entry.
  Future<void> log(
    String action, {
    String? actor,
    Map<String, dynamic> details = const {},
  }) async {
    final entry = AuditEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      action: action,
      actor: actor,
      details: details,
    );
    await _append(entry);
  }

  /// Returns the most recent [count] entries.
  Future<List<AuditEntry>> recentEntries({int count = 100}) async {
    final all = await _readAll();
    if (all.length <= count) return all;
    return all.sublist(all.length - count);
  }

  /// Returns all entries matching [action].
  Future<List<AuditEntry>> entriesForAction(String action) async {
    final all = await _readAll();
    return all.where((e) => e.action == action).toList();
  }

  /// Clears the audit log (only for testing / explicit user reset).
  Future<void> clear() async {
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.delete();
    }
  }

  // ── private ────────────────────────────────────────────────────────────────

  Future<void> _append(AuditEntry entry) async {
    if (_logFile == null) return;
    try {
      await _logFile!.writeAsString(
        '${jsonEncode(entry.toJson())}\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {}
  }

  Future<List<AuditEntry>> _readAll() async {
    if (_logFile == null || !await _logFile!.exists()) return [];
    final lines = await _logFile!.readAsLines();
    final results = <AuditEntry>[];
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        final data = jsonDecode(line) as Map<String, dynamic>;
        results.add(AuditEntry.fromJson(data));
      } catch (_) {}
    }
    return results;
  }
}
