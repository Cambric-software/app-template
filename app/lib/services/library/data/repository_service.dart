import 'database_service.dart';

/// Generic typed repository that wraps [DatabaseService].
///
/// Provides strongly typed CRUD operations for a single collection.
///
/// Usage:
/// ```dart
/// final users = RepositoryService<User>(
///   db: DatabaseService(),
///   collection: 'users',
///   fromJson: User.fromJson,
///   toJson: (u) => u.toJson(),
/// );
/// await users.save('alice', User(name: 'Alice'));
/// final alice = await users.find('alice');
/// ```
class RepositoryService<T> {
  final DatabaseService db;
  final String collection;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  const RepositoryService({
    required this.db,
    required this.collection,
    required this.fromJson,
    required this.toJson,
  });

  Future<void> save(String id, T item) =>
      db.upsert(collection, id, toJson(item));

  Future<T?> find(String id) async {
    final data = await db.get(collection, id);
    return data != null ? fromJson(data) : null;
  }

  Future<List<T>> all() async {
    final docs = await db.getAll(collection);
    return docs.map(fromJson).toList();
  }

  Future<void> delete(String id) => db.delete(collection, id);

  Future<bool> exists(String id) async =>
      (await db.get(collection, id)) != null;
}
