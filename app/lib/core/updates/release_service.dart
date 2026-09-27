import 'dart:convert';
import 'dart:io';

import '../cache/cache_service.dart';
import '../network/network_service.dart';

/// A single release asset (platform binary).
class ReleaseAsset {
  final String name;
  final String url;
  final int sizeBytes;

  const ReleaseAsset({
    required this.name,
    required this.url,
    required this.sizeBytes,
  });

  factory ReleaseAsset.fromJson(Map<String, dynamic> json) => ReleaseAsset(
        name: json['name']?.toString() ?? '',
        url: json['browser_download_url']?.toString() ?? '',
        sizeBytes: (json['size'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'browser_download_url': url,
        'size': sizeBytes,
      };
}

/// Full metadata for a GitHub release.
class ReleaseMetadata {
  final String version;
  final String name;
  final String releaseUrl;
  final String publishedAt;
  final List<ReleaseAsset> assets;
  final DateTime? checkedAt;

  const ReleaseMetadata({
    required this.version,
    required this.name,
    required this.releaseUrl,
    required this.publishedAt,
    required this.assets,
    this.checkedAt,
  });

  factory ReleaseMetadata.fromJson(Map<String, dynamic> json) =>
      ReleaseMetadata(
        version: json['tag_name']?.toString() ?? json['version']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        releaseUrl: json['html_url']?.toString() ?? json['releaseUrl']?.toString() ?? '',
        publishedAt: json['published_at']?.toString() ?? json['publishedAt']?.toString() ?? '',
        assets: (json['assets'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(ReleaseAsset.fromJson)
            .toList(),
        checkedAt: json['checkedAt'] != null
            ? DateTime.tryParse(json['checkedAt'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        'tag_name': version,
        'version': version,
        'name': name,
        'html_url': releaseUrl,
        'releaseUrl': releaseUrl,
        'published_at': publishedAt,
        'publishedAt': publishedAt,
        'assets': assets.map((a) => a.toJson()).toList(),
        'checkedAt': (checkedAt ?? DateTime.now()).toIso8601String(),
      };

  /// Returns the best matching asset for the current platform.
  ReleaseAsset? assetForCurrentPlatform() {
    if (Platform.isWindows) return _findAsset(['windows', 'win']);
    if (Platform.isLinux) return _findAsset(['linux']);
    if (Platform.isAndroid) return _findAsset(['android', '.apk']);
    return null;
  }

  ReleaseAsset? _findAsset(List<String> keywords) {
    for (final asset in assets) {
      final lower = asset.name.toLowerCase();
      for (final keyword in keywords) {
        if (lower.contains(keyword)) return asset;
      }
    }
    return null;
  }
}

/// Discovers the latest release from a GitHub repository.
///
/// Caches valid release metadata locally so the application can
/// function when GitHub is temporarily unavailable.
class ReleaseService {
  static const String _cacheKeyPrefix = 'release_metadata_';
  static const Duration _cacheMaxAge = Duration(hours: 1);

  final NetworkService _network;
  final CacheService _cache;

  ReleaseService({
    NetworkService? network,
    CacheService? cache,
  })  : _network = network ?? NetworkService.instance,
        _cache = cache ?? CacheService.instance;

  /// Fetches the latest release for [repository] (format: `owner/repo`).
  ///
  /// Returns `null` when the repository is empty or no release is found.
  /// Falls back to cached metadata when the network request fails.
  Future<ReleaseMetadata?> latest(String repository) async {
    if (repository.trim().isEmpty) return null;

    final cacheKey = '$_cacheKeyPrefix${repository.replaceAll('/', '_')}';

    try {
      final uri = Uri.parse(
        'https://api.github.com/repos/$repository/releases/latest',
      );

      final response = await _network.get(
        uri,
        headers: {'Accept': 'application/vnd.github+json'},
      );

      if (response.statusCode != 200) {
        return await _cachedMetadata(cacheKey);
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final metadata = ReleaseMetadata.fromJson(json);

      // Cache the successful response.
      await _cache.saveString(
        cacheKey,
        jsonEncode(metadata.toJson()),
      );

      return metadata;
    } on NetworkException {
      return await _cachedMetadata(cacheKey);
    } catch (_) {
      return await _cachedMetadata(cacheKey);
    }
  }

  /// Returns cached metadata for [cacheKey] if still valid.
  Future<ReleaseMetadata?> _cachedMetadata(String cacheKey) async {
    if (!await _cache.isValid(cacheKey, maxAge: _cacheMaxAge)) {
      return null;
    }

    final file = await _cache.get(cacheKey);
    if (file == null) return null;

    try {
      final raw = await file.readAsString();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return ReleaseMetadata.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
