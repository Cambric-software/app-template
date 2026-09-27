enum UpdateState {
  idle, checking, available, notAvailable,
  downloading, downloaded, verifying, readyToInstall,
  installing, installed, failed, rollbackRequired,
}

class ReleaseInfo {
  final String version;
  final String url;
  final String? checksum;
  final String? releaseUrl;
  const ReleaseInfo({required this.version, required this.url, this.checksum, this.releaseUrl});
}

class UpdateService {
  UpdateState _state = UpdateState.idle;
  ReleaseInfo? _available;
  String? _error;

  String get name => 'UpdateService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  UpdateState get state => _state;
  ReleaseInfo? get available => _available;
  String? get error => _error;
  bool get hasUpdate => _state == UpdateState.available;

  void setAvailable(ReleaseInfo info) {
    _available = info;
    _state = UpdateState.available;
  }

  void setError(String error) {
    _error = error;
    _state = UpdateState.failed;
  }

  void reset() {
    _state = UpdateState.idle;
    _available = null;
    _error = null;
  }
}
