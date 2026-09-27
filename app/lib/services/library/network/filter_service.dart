/// Applies typed filter predicates to a list of items.
class FilterService {
  String get name => 'FilterService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  List<T> apply<T>(List<T> items, List<bool Function(T)> predicates) {
    if (predicates.isEmpty) return items;
    return items.where((item) => predicates.every((p) => p(item))).toList();
  }

  List<T> applyAny<T>(List<T> items, List<bool Function(T)> predicates) {
    if (predicates.isEmpty) return items;
    return items.where((item) => predicates.any((p) => p(item))).toList();
  }

  List<T> exclude<T>(List<T> items, bool Function(T) predicate) =>
      items.where((item) => !predicate(item)).toList();

  List<T> between<T, C extends Comparable<C>>(List<T> items, C Function(T) extract, C min, C max) =>
      items.where((item) { final v = extract(item); return v.compareTo(min) >= 0 && v.compareTo(max) <= 0; }).toList();
}
