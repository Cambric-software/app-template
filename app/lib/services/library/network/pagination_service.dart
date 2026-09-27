/// A page of results with navigation metadata.
class Page<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalItems;

  const Page({required this.items, required this.page, required this.pageSize, required this.totalItems});

  int get totalPages => (totalItems / pageSize).ceil();
  bool get hasNext => page < totalPages;
  bool get hasPrevious => page > 1;
  bool get isEmpty => items.isEmpty;
}

/// Pagination helper that slices a list into pages.
class PaginationService {
  String get name => 'PaginationService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Page<T> paginate<T>(List<T> items, {required int page, required int pageSize}) {
    if (pageSize <= 0) pageSize = 10;
    if (page <= 0) page = 1;
    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, items.length);
    final slice = start >= items.length ? <T>[] : items.sublist(start, end);
    return Page(items: slice, page: page, pageSize: pageSize, totalItems: items.length);
  }

  List<Page<T>> allPages<T>(List<T> items, {int pageSize = 20}) {
    final pages = <Page<T>>[];
    for (var p = 1; p <= (items.length / pageSize).ceil().clamp(1, 99999); p++) {
      pages.add(paginate(items, page: p, pageSize: pageSize));
    }
    return pages;
  }
}
