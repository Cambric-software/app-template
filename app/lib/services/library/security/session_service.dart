import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Immutable session snapshot.
class Session {
  final String id;
  final DateTime startedAt;
  final Map<String, dynamic> data;

  const Session({
    required this.id,
    required this.startedAt,
    this.data = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'data': data,
      };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'] as String,
        startedAt:
            DateTime.tryParse(json['startedAt'] as String? ?? '') ??
                DateTime.now(),
        data: (json['data'] as Map<String, dynamic>?) ?? {},
      );
}

/// Persists a single active session via [SharedPreferences].
class SessionService {
  Session? _session;
  static const _key = '__cambric_session__';

  String get name => 'SessionService';
  bool get isAvailable => true;

  /// Restores any persisted session from storage.
  Future<void> initialize() async {
    await _load();
  }

  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// The currently active session, or null if none.
  Session? get current => _session;

  /// True when a session is active.
  bool get isActive => _session != null;

  /// Starts a new session with the given [id] and optional [data], persisting it.
  Future<Session> start(
    String id, {
    Map<String, dynamic> data = const {},
  }) async {
    _session = Session(id: id, startedAt: DateTime.now(), data: data);
    await _persist();
    return _session!;
  }

  /// Ends the current session and removes it from storage.
  Future<void> end() async {
    _session = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        _session =
            Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        // Corrupted data — start fresh.
      }
    }
  }

  Future<void> _persist() async {
    if (_session == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_session!.toJson()));
  }
}
