/// Fuzzy text search over a list of items.
class SearchService {
  String get name => 'SearchService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Searches [items] where [extract] returns the searchable text for each item.
  List<T> search<T>(List<T> items, String query, String Function(T) extract) {
    if (query.trim().isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((item) => extract(item).toLowerCase().contains(q)).toList();
  }

  /// Searches multiple fields per item.
  List<T> searchMulti<T>(List<T> items, String query, List<String Function(T)> extractors) {
    if (query.trim().isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((item) => extractors.any((e) => e(item).toLowerCase().contains(q))).toList();
  }

  /// Returns items sorted by relevance (number of query matches).
  List<T> ranked<T>(List<T> items, String query, String Function(T) extract) {
    if (query.trim().isEmpty) return items;
    final q = query.toLowerCase();
    final scored = items.map((item) {
      final text = extract(item).toLowerCase();
      final score = q.split('').fold(0, (acc, ch) => acc + (text.contains(ch) ? 1 : 0));
      return (item: item, score: score);
    }).where((e) => e.score > 0).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.item).toList();
  }
}
