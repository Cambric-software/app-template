import 'dart:async';
import 'dart:io';

/// The current network connectivity state.
enum ConnectivityState {
  /// Network is available and reachable.
  online,

  /// No network connection detected.
  offline,

  /// Connectivity could not be determined.
  unknown,
}

/// Detects network connectivity without requiring any third-party plugin.
///
/// Uses a lightweight DNS lookup against a well-known reliable host.
class ConnectivityService {
  static const Duration _defaultTimeout = Duration(seconds: 5);
  static const String _defaultCheckHost = 'dns.google';

  final String _checkHost;
  final Duration _timeout;

  ConnectivityState _lastKnownState = ConnectivityState.unknown;

  ConnectivityService({
    String checkHost = _defaultCheckHost,
    Duration timeout = _defaultTimeout,
  })  : _checkHost = checkHost,
        _timeout = timeout;

  ConnectivityState get lastKnownState => _lastKnownState;

  bool get isOnline => _lastKnownState == ConnectivityState.online;
  bool get isOffline => _lastKnownState == ConnectivityState.offline;

  Future<ConnectivityState> check() async {
    try {
      final result = await InternetAddress.lookup(_checkHost)
          .timeout(_timeout);

      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        _lastKnownState = ConnectivityState.online;
      } else {
        _lastKnownState = ConnectivityState.offline;
      }
    } on SocketException {
      _lastKnownState = ConnectivityState.offline;
    } on TimeoutException {
      _lastKnownState = ConnectivityState.offline;
    } catch (_) {
      _lastKnownState = ConnectivityState.unknown;
    }

    return _lastKnownState;
  }
}
