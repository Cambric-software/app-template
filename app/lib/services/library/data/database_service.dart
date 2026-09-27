import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// ── DatabaseService ────────────────────────────────────────────────────────

/// Lightweight JSON-file-based key-collection store.
///
/// Not a relational database. Provides indexed collections of JSON documents
/// without requiring any native database plugin.
///
/// For heavier workloads, use sqflite or drift with this as the abstraction layer.
class DatabaseService {
  Directory? _dir;

  String get name => 'DatabaseService';
  bool get isAvailable => _dir != null;
  Future<bool> healthCheck() async => _dir != null;

  Future<void> initialize({String dbName = 'app_db'}) async {
    final base = await getApplicationSupportDirectory();
    _dir = Directory('${base.path}${Platform.pathSeparator}$dbName');
    await _dir!.create(recursive: true);
  }

  Future<void> dispose() async { _dir = null; }

  /// Inserts or replaces document [id] in [collection].
  Future<void> upsert(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final file = await _collectionFile(collection, id);
    await file.writeAsString(jsonEncode({...data, '_id': id}), flush: true);
  }

  /// Returns a document by [id] from [collection], or null.
  Future<Map<String, dynamic>?> get(String collection, String id) async {
    final file = await _collectionFile(collection, id);
    if (!await file.exists()) return null;
    try {
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (_) { return null; }
  }

  /// Returns all documents in [collection].
  Future<List<Map<String, dynamic>>> getAll(String collection) async {
    final dir = await _collectionDir(collection);
    final results = <Map<String, dynamic>>[];
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final data = jsonDecode(await entity.readAsString());
          if (data is Map<String, dynamic>) results.add(data);
        } catch (_) {}
      }
    }
    return results;
  }

  /// Deletes document [id] from [collection].
  Future<void> delete(String collection, String id) async {
    final file = await _collectionFile(collection, id);
    if (await file.exists()) await file.delete();
  }

  Future<Directory> _collectionDir(String collection) async {
    final dir = Directory(
        '${_dir!.path}${Platform.pathSeparator}$collection');
    await dir.create(recursive: true);
    return dir;
  }

  Future<File> _collectionFile(String collection, String id) async {
    final dir = await _collectionDir(collection);
    final safeId = id.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    return File('${dir.path}${Platform.pathSeparator}$safeId.json');
  }
}

// ── RepositoryService ──────────────────────────────────────────────────────

/// Generic typed repository on top of [DatabaseService].
///
/// Usage:
/// ```dart
/// final repo = RepositoryService<User>(
///   db: db,
///   collection: 'users',
///   fromJson: User.fromJson,
///   toJson: (u) => u.toJson(),
/// );
///
/// await repo.save('user1', User('Alice'));
/// final user = await repo.find('user1');
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
}

// ── DataMigrationService ───────────────────────────────────────────────────

/// Runs data migrations at startup to move stored data to the current schema.
class DataMigrationService {
  String get name => 'DataMigrationService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  /// Runs [migrations] on [data] from current schema version to [targetVersion].
  Future<Map<String, dynamic>> migrate(
    Map<String, dynamic> data, {
    required int targetVersion,
    required String versionKey,
    required List<({int from, int to, Map<String, dynamic> Function(Map<String, dynamic>) apply})> migrations,
  }) async {
    var current = Map<String, dynamic>.from(data);
    var version = (current[versionKey] as num?)?.toInt() ?? 0;

    for (final migration in migrations) {
      if (migration.from != version) continue;
      if (migration.to > targetVersion) break;
      current = migration.apply(current);
      current[versionKey] = migration.to;
      version = migration.to;
    }

    return current;
  }
}
