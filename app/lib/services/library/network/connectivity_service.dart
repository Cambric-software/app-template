import 'dart:async';
import 'dart:io';

enum ConnectivityState { online, offline, unknown }

/// Checks network connectivity via DNS lookup (no plugin required).
class ConnectivityService {
  static const String _host = 'dns.google';
  static const Duration _timeout = Duration(seconds: 5);

  ConnectivityState _last = ConnectivityState.unknown;

  String get name => 'ConnectivityService';
  bool get isAvailable => true;
  Future<void> initialize() async { await check(); }
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => _last != ConnectivityState.unknown;

  ConnectivityState get lastKnownState => _last;
  bool get isOnline => _last == ConnectivityState.online;
  bool get isOffline => _last == ConnectivityState.offline;

  Future<ConnectivityState> check() async {
    try {
      final result = await InternetAddress.lookup(_host).timeout(_timeout);
      _last = result.isNotEmpty && result.first.rawAddress.isNotEmpty
          ? ConnectivityState.online
          : ConnectivityState.offline;
    } on SocketException {
      _last = ConnectivityState.offline;
    } on TimeoutException {
      _last = ConnectivityState.offline;
    } catch (_) {
      _last = ConnectivityState.unknown;
    }
    return _last;
  }
}
