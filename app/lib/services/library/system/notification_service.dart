import 'package:flutter/foundation.dart';

class AppNotification {
  final String id;
  final String title;
  final String? body;
  final DateTime createdAt;
  bool read;
  AppNotification({required this.id, required this.title, this.body, required this.createdAt, this.read = false});
}

class NotificationService {
  final List<AppNotification> _notifications = [];
  final List<void Function(AppNotification)> _listeners = [];

  String get name => 'NotificationService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async { _listeners.clear(); }
  Future<bool> healthCheck() async => true;

  List<AppNotification> get all => List.unmodifiable(_notifications);
  List<AppNotification> get unread => _notifications.where((n) => !n.read).toList();
  int get unreadCount => unread.length;

  void post(String id, String title, {String? body}) {
    final n = AppNotification(id: id, title: title, body: body, createdAt: DateTime.now());
    _notifications.add(n);
    if (kDebugMode) debugPrint('[Notification] $title');
    for (final l in List.of(_listeners)) { try { l(n); } catch (_) {} }
  }

  void markRead(String id) {
    final n = _notifications.where((n) => n.id == id).firstOrNull;
    if (n != null) n.read = true;
  }

  void markAllRead() { for (final n in _notifications) { n.read = true; } }
  void clear() => _notifications.clear();
  void onNotification(void Function(AppNotification) listener) => _listeners.add(listener);
}
