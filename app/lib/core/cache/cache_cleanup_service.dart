import 'cache_service.dart';

/// Cleanup result summary.
class CacheCleanupResult {
  final int entriesRemoved;
  final int bytesFreed;
  final Duration elapsed;

  const CacheCleanupResult({
    required this.entriesRemoved,
    required this.bytesFreed,
    required this.elapsed,
  });

  @override
  String toString() =>
      'CacheCleanupResult(removed=$entriesRemoved, '
      'freed=${_humanSize(bytesFreed)}, '
      'elapsed=${elapsed.inMilliseconds}ms)';

  static String _humanSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Runs cleanup passes against the [CacheService].
///
/// Cleanup strategies:
///
/// - [evictExpired]: remove entries older than a TTL.
/// - [enforceSizeLimit]: remove least-recently-used entries when
///   total cache size exceeds [CacheService.maxSizeBytes].
/// - [clearAll]: remove everything (user-initiated only).
///
/// This service never touches [LocalStorage] or user data.
class CacheCleanupService {
  final CacheService _cache;

  CacheCleanupService({CacheService? cache})
      : _cache = cache ?? CacheService.instance;

  /// Removes all expired entries.
  Future<CacheCleanupResult> evictExpired(Duration maxAge) async {
    final start = DateTime.now();
    final before = await _cache.sizeBytes();

    final removed = await _cache.evictExpired(maxAge);

    final after = await _cache.sizeBytes();
    return CacheCleanupResult(
      entriesRemoved: removed,
      bytesFreed: before - after,
      elapsed: DateTime.now().difference(start),
    );
  }

  /// Clears the entire cache.
  Future<CacheCleanupResult> clearAll() async {
    final start = DateTime.now();
    final before = await _cache.sizeBytes();
    final count = await _cache.entryCount();

    await _cache.clear();

    return CacheCleanupResult(
      entriesRemoved: count,
      bytesFreed: before,
      elapsed: DateTime.now().difference(start),
    );
  }

  /// Returns a human-readable summary of the current cache state.
  Future<CacheSummary> summary() async {
    final size = await _cache.sizeBytes();
    final count = await _cache.entryCount();
    return CacheSummary(sizeBytes: size, entryCount: count);
  }
}

/// Current cache state summary.
class CacheSummary {
  final int sizeBytes;
  final int entryCount;

  const CacheSummary({
    required this.sizeBytes,
    required this.entryCount,
  });

  String get readableSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
