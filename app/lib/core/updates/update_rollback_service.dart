import 'dart:convert';
import 'dart:io';

import '../storage/cambric_paths.dart';
import '../storage/atomic_file_service.dart';

/// Stores and restores rollback information before installing an update.
///
/// Before replacing any application files:
/// 1. Save rollback metadata (version, paths, timestamps).
/// 2. Install the new version.
/// 3. If installation or startup fails, call [rollback].
///
/// Rollback data is stored in `Cambric/Updates/rollback_<productId>.json`.
class UpdateRollbackService {
  final AtomicFileService _atomic = AtomicFileService();

  /// Saves rollback information before an update.
  Future<void> saveRollbackPoint({
    required String productId,
    required String currentVersion,
    Map<String, dynamic> extraMetadata = const {},
  }) async {
    final file = await _rollbackFile(productId);
    final data = {
      'productId': productId,
      'version': currentVersion,
      'savedAt': DateTime.now().toIso8601String(),
      ...extraMetadata,
    };
    await _atomic.write(file, jsonEncode(data));
  }

  /// Returns the saved rollback point, or `null` if none exists.
  Future<Map<String, dynamic>?> getRollbackPoint(String productId) async {
    final file = await _rollbackFile(productId);
    if (!await file.exists()) return null;

    try {
      final raw = await file.readAsString();
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Performs rollback — clears rollback state after use.
  ///
  /// The actual reinstallation of the previous version is
  /// platform-specific and handled by [InstallerService].
  /// This service only manages the rollback metadata.
  Future<bool> rollback(String productId) async {
    final point = await getRollbackPoint(productId);
    if (point == null) return false;

    // Remove rollback state — consumed.
    await clearRollbackPoint(productId);
    return true;
  }

  /// Removes rollback data after a successful installation.
  Future<void> clearRollbackPoint(String productId) async {
    final file = await _rollbackFile(productId);
    if (await file.exists()) await file.delete();
  }

  /// Whether a rollback point exists for [productId].
  Future<bool> hasRollbackPoint(String productId) async {
    final file = await _rollbackFile(productId);
    return file.exists();
  }

  Future<File> _rollbackFile(String productId) async {
    final dir = await CambricPaths.updates();
    final safeId = productId.replaceAll(RegExp(r'[^a-zA-Z0-9\-_]'), '_');
    return File(
      '${dir.path}${Platform.pathSeparator}rollback_$safeId.json',
    );
  }
}
