import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UpdateRollbackService {
  String get name => 'UpdateRollbackService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<void> saveRollbackPoint({required String productId, required String version}) async {
    final file = await _rollbackFile(productId);
    await file.writeAsString(jsonEncode({'productId': productId, 'version': version, 'savedAt': DateTime.now().toIso8601String()}), flush: true);
  }

  Future<Map<String, dynamic>?> getRollbackPoint(String productId) async {
    final file = await _rollbackFile(productId);
    if (!await file.exists()) return null;
    try { return jsonDecode(await file.readAsString()) as Map<String, dynamic>; } catch (_) { return null; }
  }

  Future<bool> hasRollbackPoint(String productId) async => (await _rollbackFile(productId)).exists();

  Future<void> clearRollbackPoint(String productId) async {
    final file = await _rollbackFile(productId);
    if (await file.exists()) await file.delete();
  }

  Future<File> _rollbackFile(String productId) async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}${Platform.pathSeparator}Updates');
    await dir.create(recursive: true);
    return File('${dir.path}${Platform.pathSeparator}rollback_${productId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.json');
  }
}
