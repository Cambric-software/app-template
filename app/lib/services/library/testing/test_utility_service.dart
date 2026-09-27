import 'dart:io';

/// Testing utilities: temp dirs, fake data, time control.
class TestUtilityService {
  final List<Directory> _tempDirs = [];

  String get name => 'TestUtilityService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async { await cleanupAll(); }
  Future<bool> healthCheck() async => true;

  Future<Directory> createTempDir({String prefix = 'cambric_test_'}) async {
    final dir = await Directory.systemTemp.createTemp(prefix);
    _tempDirs.add(dir);
    return dir;
  }

  Future<File> createTempFile(String content, {String suffix = '.txt'}) async {
    final dir = await createTempDir();
    final file = File('${dir.path}${Platform.pathSeparator}test$suffix');
    await file.writeAsString(content);
    return file;
  }

  Future<void> cleanupAll() async {
    for (final dir in List.of(_tempDirs)) {
      try { if (await dir.exists()) await dir.delete(recursive: true); } catch (_) {}
    }
    _tempDirs.clear();
  }

  Map<String, dynamic> fakeProduct({String id = 'test-product', String name = 'Test Product'}) => {
    'productId': id, 'name': name, 'version': '1.0.0', 'platform': 'flutter',
    'protocolVersion': 1, 'capabilities': ['local-storage'], 'lastSeen': DateTime.now().toIso8601String(),
  };

  List<Map<String, dynamic>> fakeProducts(int count) =>
      List.generate(count, (i) => fakeProduct(id: 'product-$i', name: 'Product $i'));
}
