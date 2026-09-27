import 'dart:convert';
import 'package:http/http.dart' as http;

class ReleaseAsset {
  final String name; final String url; final int sizeBytes;
  const ReleaseAsset({required this.name, required this.url, required this.sizeBytes});
  factory ReleaseAsset.fromJson(Map<String, dynamic> j) => ReleaseAsset(name: j['name'] ?? '', url: j['browser_download_url'] ?? '', sizeBytes: (j['size'] as num?)?.toInt() ?? 0);
}

class ReleaseMetadata {
  final String version; final String name; final String releaseUrl; final List<ReleaseAsset> assets;
  const ReleaseMetadata({required this.version, required this.name, required this.releaseUrl, required this.assets});
  factory ReleaseMetadata.fromJson(Map<String, dynamic> j) => ReleaseMetadata(
    version: j['tag_name'] ?? '', name: j['name'] ?? '', releaseUrl: j['html_url'] ?? '',
    assets: (j['assets'] as List? ?? []).whereType<Map<String, dynamic>>().map(ReleaseAsset.fromJson).toList());
  ReleaseAsset? get windowsAsset => assets.where((a) => a.name.toLowerCase().contains('windows')).firstOrNull;
  ReleaseAsset? get linuxAsset => assets.where((a) => a.name.toLowerCase().contains('linux')).firstOrNull;
  ReleaseAsset? get androidAsset => assets.where((a) => a.name.toLowerCase().contains('android') || a.name.endsWith('.apk')).firstOrNull;
}

class ReleaseService {
  String get name => 'ReleaseService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<ReleaseMetadata?> latest(String repository) async {
    if (repository.trim().isEmpty) return null;
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$repository/releases/latest'),
        headers: {'Accept': 'application/vnd.github+json'}).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      return ReleaseMetadata.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } catch (_) { return null; }
  }
}
