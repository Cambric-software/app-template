class DeepLinkService {
  final List<void Function(Uri)> _handlers = [];
  Uri? _lastLink;

  String get name => 'DeepLinkService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async { _handlers.clear(); }
  Future<bool> healthCheck() async => true;

  Uri? get lastLink => _lastLink;

  void onLink(void Function(Uri) handler) => _handlers.add(handler);

  void handleLink(Uri uri) {
    _lastLink = uri;
    for (final h in List.of(_handlers)) { try { h(uri); } catch (_) {} }
  }

  void handleString(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null) handleLink(uri);
  }

  bool isScheme(Uri uri, String scheme) => uri.scheme == scheme;
  String? pathSegment(Uri uri, int index) =>
      index < uri.pathSegments.length ? uri.pathSegments[index] : null;
}
