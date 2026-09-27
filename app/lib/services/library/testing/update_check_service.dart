import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateCheckResult {
  final bool updateAvailable;
  final String? latestVersion;
  final String? releaseUrl;
  final String? downloadUrl;
  const UpdateCheckResult({
    required this.updateAvailable,
    this.latestVersion,
    this.releaseUrl,
    this.downloadUrl,
  });
}

class UpdateCheckService {
  String get name => 'UpdateCheckService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<UpdateCheckResult> check({
    required String repository,
    required String currentVersion,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/$repository/releases/latest',
        ),
        headers: {'Accept': 'application/vnd.github+json'},
      ).timeout(timeout);

      if (response.statusCode != 200) {
        return const UpdateCheckResult(updateAvailable: false);
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final latest =
          (json['tag_name']?.toString() ?? '').replaceFirst('v', '');
      final available = _isNewer(latest, currentVersion);

      return UpdateCheckResult(
        updateAvailable: available,
        latestVersion: latest,
        releaseUrl: json['html_url']?.toString(),
      );
    } catch (_) {
      return const UpdateCheckResult(updateAvailable: false);
    }
  }

  bool _isNewer(String latest, String current) {
    List<int> parse(String v) =>
        v.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final a = parse(latest);
    final b = parse(current);
    for (var i = 0; i < 3; i++) {
      final ai = i < a.length ? a[i] : 0;
      final bi = i < b.length ? b[i] : 0;
      if (ai > bi) return true;
      if (ai < bi) return false;
    }
    return false;
  }
}
