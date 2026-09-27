/// Logical permissions the app may need from the user or platform.
enum AppPermission {
  storage,
  network,
  notifications,
  clipboard,
  camera,
  microphone,
  location,
}

/// The grant status of a single permission.
enum PermissionStatus {
  granted,
  denied,
  notDetermined,
}

/// In-memory permission registry.
///
/// On platforms with real OS permission APIs (Android, iOS) this service acts
/// as a local cache / abstraction layer. On desktop platforms where most
/// permissions are implicit, it allows the app to track any manual grants.
class PermissionService {
  final Map<AppPermission, PermissionStatus> _status = {};

  String get name => 'PermissionService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Returns the current status of [permission], defaulting to [PermissionStatus.notDetermined].
  PermissionStatus statusOf(AppPermission permission) =>
      _status[permission] ?? PermissionStatus.notDetermined;

  /// Returns true only when [permission] has been explicitly granted.
  bool isGranted(AppPermission permission) =>
      statusOf(permission) == PermissionStatus.granted;

  /// Records [permission] as granted.
  void grant(AppPermission permission) =>
      _status[permission] = PermissionStatus.granted;

  /// Records [permission] as denied.
  void deny(AppPermission permission) =>
      _status[permission] = PermissionStatus.denied;

  /// An unmodifiable snapshot of all recorded statuses.
  Map<AppPermission, PermissionStatus> get all => Map.unmodifiable(_status);
}
