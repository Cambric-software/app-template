import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:cambric_app/core/storage/atomic_file_service.dart';

void main() {
  late Directory tempDir;
  late AtomicFileService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cambric_atomic_test_');
    service = AtomicFileService();
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('AtomicFileService', () {
    test('writes content to destination file', () async {
      final dest = File('${tempDir.path}/test.txt');
      await service.write(dest, 'hello world');
      expect(await dest.readAsString(), equals('hello world'));
    });

    test('destination contains exact content after write', () async {
      const content = '{"version":1,"data":"test"}';
      final dest = File('${tempDir.path}/data.json');
      await service.write(dest, content);
      expect(await dest.readAsString(), equals(content));
    });

    test('no .tmp file remains after successful write', () async {
      final dest = File('${tempDir.path}/clean.txt');
      await service.write(dest, 'data');
      expect(await File('${dest.path}.tmp').exists(), isFalse);
    });

    test('overwrites existing file atomically', () async {
      final dest = File('${tempDir.path}/overwrite.txt');
      await service.write(dest, 'version 1');
      await service.write(dest, 'version 2');
      expect(await dest.readAsString(), equals('version 2'));
    });

    test('writes empty string without throwing', () async {
      final dest = File('${tempDir.path}/empty.txt');
      await service.write(dest, '');
      expect(await dest.readAsString(), equals(''));
    });

    test('writes bytes to destination', () async {
      final dest = File('${tempDir.path}/bytes.bin');
      final bytes = [0x01, 0x02, 0x03, 0xFF];
      await service.writeBytes(dest, bytes);
      expect(await dest.readAsBytes(), equals(bytes));
    });

    test('byte write: no .tmp file remains after success', () async {
      final dest = File('${tempDir.path}/bytes2.bin');
      await service.writeBytes(dest, [1, 2, 3]);
      expect(await File('${dest.path}.tmp').exists(), isFalse);
    });

    test('write creates parent directories if missing', () async {
      final dest = File('${tempDir.path}/sub/dir/file.txt');
      await dest.parent.create(recursive: true);
      await service.write(dest, 'nested');
      expect(await dest.readAsString(), equals('nested'));
    });

    test('multiple sequential writes are all correct', () async {
      final dest = File('${tempDir.path}/seq.txt');
      for (var i = 0; i < 10; i++) {
        await service.write(dest, 'value $i');
      }
      expect(await dest.readAsString(), equals('value 9'));
    });
  });
}
