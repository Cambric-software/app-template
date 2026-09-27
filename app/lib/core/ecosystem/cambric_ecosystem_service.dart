import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../storage/cambric_paths.dart';

/// Manages this application's identity and presence within the local
/// Cambric ecosystem.
///
/// Each Cambric application maintains a stable local installation ID
/// (randomly generated, not hardware fingerprint) and an identity file
/// stored in the shared Cambric ecosystem directory.
class CambricEcosystemService {
  static const int _currentProtocolVersion = 1;

  String? _installationId;

  // ignore: prefer_const_declarations — AtomicFileService is not const-constructible

  /// Returns the current local installation ID, or null if not yet initialized.
  String? get installationId => _installationId;

  /// Ensures this application has a stable local identity.
  ///
  /// If no identity file exists, generates a new random installation ID
  /// and persists it.  Safe to call on every startup.
  Future<void> ensureIdentity() async {
    final file = await _identityFile();

    if (await file.exists()) {
      try {
        final raw = await file.readAsString();
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final id = data['installationId']?.toString();
        if (id != null && id.isNotEmpty) {
          _installationId = id;
          return;
        }
      } catch (_) {
        // Identity file corrupt — regenerate below.
      }
    }

    _installationId = _generateId();
    await _persistIdentity(file);
  }

  /// Returns the local ecosystem protocol version for compatibility checks.
  int get protocolVersion => _currentProtocolVersion;

  /// Returns whether this application has an established identity.
  bool get hasIdentity => _installationId != null;

  // ── private helpers ──────────────────────────────────────────────────────

  Future<File> _identityFile() async {
    final dir = await CambricPaths.ecosystem();
    return File(
      '${dir.path}${Platform.pathSeparator}identity.json',
    );
  }

  Future<void> _persistIdentity(File file) async {
    final data = jsonEncode({
      'installationId': _installationId,
      'protocolVersion': _currentProtocolVersion,
      'createdAt': DateTime.now().toIso8601String(),
    });

    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(data, flush: true);
    if (await file.exists()) await file.delete();
    await tmp.rename(file.path);
  }

  String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    const prefix = 'cambric';
    final suffix = List.generate(
      16,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
    return '$prefix-$suffix';
  }
}
