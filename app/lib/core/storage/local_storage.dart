import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalStorage {
  static final LocalStorage instance = LocalStorage._();

  LocalStorage._();

  Directory? _root;

  Future<Directory> get _dataDirectory async {
    if (_root != null) return _root!;

    final base = await getApplicationSupportDirectory();
    final directory = Directory(
      '${base.path}${Platform.pathSeparator}data',
    );

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    _root = directory;
    return directory;
  }

  Future<File> _file(String key) async {
    final directory = await _dataDirectory;
    return File(
      '${directory.path}${Platform.pathSeparator}$key.json',
    );
  }

  Future<void> write(String key, Object? value) async {
    final file = await _file(key);

    await file.writeAsString(
      jsonEncode(value),
      flush: true,
    );
  }

  Future<dynamic> read(String key) async {
    final file = await _file(key);

    if (!await file.exists()) {
      return null;
    }

    final content = await file.readAsString();

    if (content.trim().isEmpty) {
      return null;
    }

    return jsonDecode(content);
  }

  Future<bool> contains(String key) async {
    final file = await _file(key);
    return file.exists();
  }

  Future<void> delete(String key) async {
    final file = await _file(key);

    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> clear() async {
    final directory = await _dataDirectory;

    if (!await directory.exists()) return;

    await for (final entity in directory.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        await entity.delete();
      }
    }
  }
}
