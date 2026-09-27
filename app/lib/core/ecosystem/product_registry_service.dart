import 'dart:convert';
import 'dart:io';

import '../storage/atomic_file_service.dart';
import '../storage/cambric_paths.dart';

/// Registers and discovers Cambric products installed on this device.
///
/// Each product writes a small JSON manifest into the shared Cambric
/// registry directory when it first starts. The registry is a plain
/// directory — one file per product — so multiple applications can
/// coexist without coordination beyond the filesystem.
///
/// Schema version: 1
class ProductRegistryService {
  static const int _currentSchemaVersion = 1;

  final AtomicFileService _atomic = AtomicFileService();

  /// Register this product. Safe to call on every startup.
  ///
  /// Idempotent — updates the entry when data has changed.
  Future<void> register(Map<String, dynamic> productData) async {
    final id = productData['productId']?.toString();
    if (id == null || id.trim().isEmpty) {
      throw ArgumentError(
        'productData must contain a non-empty productId.',
      );
    }

    final entry = <String, dynamic>{
      'schemaVersion': _currentSchemaVersion,
      'registeredAt': DateTime.now().toIso8601String(),
      ...productData,
    };

    final file = await _fileForProduct(id);
    await _atomic.write(file, jsonEncode(entry));
  }

  /// Returns all registered products found in the shared registry.
  Future<List<Map<String, dynamic>>> products() async {
    final directory = await CambricPaths.registry();
    final result = <Map<String, dynamic>>[];

    if (!await directory.exists()) return result;

    await for (final entity in directory.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final raw = await entity.readAsString();
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            result.add(decoded);
          }
        } catch (_) {
          // Skip corrupt entries.
        }
      }
    }

    return result;
  }

  /// Returns a single product entry by [productId], or null if not found.
  Future<Map<String, dynamic>?> find(String productId) async {
    final file = await _fileForProduct(productId);
    if (!await file.exists()) return null;

    try {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// Returns all products that advertise [capability].
  Future<List<Map<String, dynamic>>> findByCapability(
    String capability,
  ) async {
    final all = await products();
    return all.where((p) {
      final caps = p['capabilities'];
      if (caps is List) {
        return caps.contains(capability);
      }
      return false;
    }).toList();
  }

  /// Removes this product from the shared registry.
  Future<void> unregister(String productId) async {
    final file = await _fileForProduct(productId);
    if (await file.exists()) await file.delete();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  Future<File> _fileForProduct(String productId) async {
    final directory = await CambricPaths.registry();
    final safeId =
        productId.replaceAll(RegExp(r'[^a-zA-Z0-9\-_]'), '_');
    return File(
      '${directory.path}${Platform.pathSeparator}$safeId.json',
    );
  }
}
