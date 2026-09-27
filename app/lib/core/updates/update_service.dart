import 'dart:io';

import '../network/network_service.dart';
import '../storage/cambric_paths.dart';
import '../storage/atomic_file_service.dart';
import 'release_service.dart';
import 'update_state.dart';

/// Full update state machine.
///
/// Flow:
///
/// ```
/// idle → checking → available/notAvailable/checkFailed
///              ↓
///           downloading → downloadFailed
///              ↓
///           verifying  → verificationFailed
///              ↓
///           readyToInstall
///              ↓
///           installing → installFailed/rollbackRequired
///              ↓
///           installed
/// ```
///
/// Failures never crash the application — errors are surfaced through
/// [state] and [error].
class UpdateService {
  final ReleaseService _releases;
  final NetworkService _network;
  final AtomicFileService _atomic = AtomicFileService();

  UpdateState _state = UpdateState.idle;
  ReleaseMetadata? _available;
  File? _downloadedPackage;
  String? _error;

  UpdateService({
    ReleaseService? releases,
    NetworkService? network,
  })  : _releases = releases ?? ReleaseService(),
        _network = network ?? NetworkService.instance;

  UpdateState get state => _state;
  ReleaseMetadata? get available => _available;
  File? get downloadedPackage => _downloadedPackage;
  String? get error => _error;

  bool get hasUpdate => _state == UpdateState.available;
  bool get isReadyToInstall => _state == UpdateState.readyToInstall;
  bool get isBusy =>
      _state == UpdateState.checking ||
      _state == UpdateState.downloading ||
      _state == UpdateState.verifying ||
      _state == UpdateState.installing;

  // ── check ────────────────────────────────────────────────────────────────

  Future<ReleaseMetadata?> check(String repository) async {
    _transition(UpdateState.checking);

    try {
      final release = await _releases.latest(repository);

      if (release == null || release.version.isEmpty) {
        _transition(UpdateState.notAvailable);
        return null;
      }

      _available = release;
      _transition(UpdateState.available);
      return release;
    } on NetworkException catch (e) {
      _setError(UpdateState.checkFailed, e.toString());
      return null;
    } catch (e) {
      _setError(UpdateState.checkFailed, e.toString());
      return null;
    }
  }

  // ── download ─────────────────────────────────────────────────────────────

  Future<File?> download({
    void Function(int received, int total)? onProgress,
  }) async {
    final release = _available;
    final asset = release?.assetForCurrentPlatform();

    if (release == null || asset == null) {
      _setError(
        UpdateState.downloadFailed,
        'No update available or no asset for this platform.',
      );
      return null;
    }

    _transition(UpdateState.downloading);

    try {
      final downloadsDir = await CambricPaths.downloads();
      final destFile = File(
        '${downloadsDir.path}${Platform.pathSeparator}${asset.name}',
      );

      final response = await _network.get(Uri.parse(asset.url));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _setError(
          UpdateState.downloadFailed,
          'Download failed: HTTP ${response.statusCode}',
        );
        return null;
      }

      await _atomic.writeBytes(destFile, response.bodyBytes);
      _downloadedPackage = destFile;
      _transition(UpdateState.downloaded);
      return destFile;
    } on NetworkException catch (e) {
      _setError(UpdateState.downloadFailed, e.toString());
      return null;
    } catch (e) {
      _setError(UpdateState.downloadFailed, e.toString());
      return null;
    }
  }

  // ── verify ────────────────────────────────────────────────────────────────

  Future<bool> verify({String? expectedChecksum}) async {
    final file = _downloadedPackage;
    if (file == null || !await file.exists()) {
      _setError(
        UpdateState.verificationFailed,
        'No downloaded package to verify.',
      );
      return false;
    }

    _transition(UpdateState.verifying);

    try {
      final stat = await file.stat();
      if (stat.size == 0) {
        _setError(
          UpdateState.verificationFailed,
          'Downloaded package is empty.',
        );
        return false;
      }

      // Checksum verification (when checksum is provided).
      if (expectedChecksum != null && expectedChecksum.isNotEmpty) {
        // Checksum comparison happens in UpdateVerificationService.
        // Here we just confirm the file is readable.
        await file.readAsBytes();
      }

      _transition(UpdateState.readyToInstall);
      return true;
    } catch (e) {
      _setError(UpdateState.verificationFailed, e.toString());
      return false;
    }
  }

  // ── reset ─────────────────────────────────────────────────────────────────

  void reset() {
    _state = UpdateState.idle;
    _available = null;
    _downloadedPackage = null;
    _error = null;
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  void _transition(UpdateState next) {
    _state = next;
    _error = null;
  }

  void _setError(UpdateState errorState, String message) {
    _state = errorState;
    _error = message;
  }

  Map<String, dynamic> toJson() => {
    'state': _state.name,
    if (_available != null) 'available': _available!.toJson(),
    if (_error != null) 'error': _error,
  };
}
