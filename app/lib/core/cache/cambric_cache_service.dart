import 'dart:io';

import '../storage/cambric_paths.dart';

class CambricCacheService {
  Future<File> file(
    String productId,
    String key,
  ) async {
    final directory = await CambricPaths.productCache(productId);

    return File(
      '${directory.path}${Platform.pathSeparator}$key',
    );
  }

  Future<void> clear(
    String productId,
  ) async {
    final directory = await CambricPaths.productCache(productId);

    if (await directory.exists()) {
      await directory.delete(recursive: true);
      await directory.create(recursive: true);
    }
  }
}
