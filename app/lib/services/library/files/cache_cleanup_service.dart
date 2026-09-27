import 'cache_service.dart';

/// Runs cleanup passes on a [CacheService].
class CacheCleanupService {
  final CacheService cache;

  CacheCleanupService({required this.cache});

  String get name => 'CacheCleanupService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<void> clearAll() => cache.clear();
  Future<int> sizeBytes() => cache.sizeBytes();

  String humanSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
