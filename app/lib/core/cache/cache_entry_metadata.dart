/// Metadata stored alongside each cache entry.
class CacheEntryMetadata {
  final String key;
  final DateTime cachedAt;
  final int sizeBytes;
  final DateTime? lastAccessedAt;

  const CacheEntryMetadata({
    required this.key,
    required this.cachedAt,
    required this.sizeBytes,
    this.lastAccessedAt,
  });

  factory CacheEntryMetadata.fromJson(Map<String, dynamic> json) =>
      CacheEntryMetadata(
        key: json['key']?.toString() ?? '',
        cachedAt: DateTime.tryParse(
              json['cachedAt']?.toString() ?? '',
            ) ??
            DateTime.now(),
        sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
        lastAccessedAt: json['lastAccessedAt'] != null
            ? DateTime.tryParse(json['lastAccessedAt'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
    'key': key,
    'cachedAt': cachedAt.toIso8601String(),
    'sizeBytes': sizeBytes,
    if (lastAccessedAt != null)
      'lastAccessedAt': lastAccessedAt!.toIso8601String(),
  };

  /// Returns how long ago this entry was cached.
  Duration get age => DateTime.now().difference(cachedAt);
}
