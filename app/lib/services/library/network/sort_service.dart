/// Sort items by one or more fields with direction control.
enum SortDirection { ascending, descending }

class SortCriteria<T> {
  final Comparable Function(T) by;
  final SortDirection direction;
  const SortCriteria({required this.by, this.direction = SortDirection.ascending});
}

class SortService {
  String get name => 'SortService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  List<T> sort<T>(List<T> items, SortCriteria<T> criteria) {
    final sorted = List<T>.from(items)
      ..sort((a, b) {
        final cmp = criteria.by(a).compareTo(criteria.by(b));
        return criteria.direction == SortDirection.ascending ? cmp : -cmp;
      });
    return sorted;
  }

  List<T> sortMulti<T>(List<T> items, List<SortCriteria<T>> criteriaList) {
    final sorted = List<T>.from(items)
      ..sort((a, b) {
        for (final c in criteriaList) {
          final cmp = c.by(a).compareTo(c.by(b));
          if (cmp != 0) return c.direction == SortDirection.ascending ? cmp : -cmp;
        }
        return 0;
      });
    return sorted;
  }

  List<T> sortBy<T>(List<T> items, Comparable Function(T) key, {bool descending = false}) {
    final sorted = List<T>.from(items)
      ..sort((a, b) {
        final cmp = key(a).compareTo(key(b));
        return descending ? -cmp : cmp;
      });
    return sorted;
  }
}
