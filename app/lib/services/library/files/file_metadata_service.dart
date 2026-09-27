import 'dart:io';

/// File metadata model.
class FileMetadata {
  final String path;
  final String name;
  final String extension;
  final int sizeBytes;
  final DateTime modified;
  final DateTime accessed;
  final bool isReadOnly;

  const FileMetadata({
    required this.path,
    required this.name,
    required this.extension,
    required this.sizeBytes,
    required this.modified,
    required this.accessed,
    required this.isReadOnly,
  });

  String get readableSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Reads file metadata without loading file content.
class FileMetadataService {
  String get name => 'FileMetadataService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<FileMetadata?> read(File file) async {
    if (!await file.exists()) return null;
    final stat = await file.stat();
    final basename = file.uri.pathSegments.last;
    final dot = basename.lastIndexOf('.');
    return FileMetadata(
      path: file.path,
      name: basename,
      extension: dot >= 0 ? basename.substring(dot) : '',
      sizeBytes: stat.size,
      modified: stat.modified,
      accessed: stat.accessed,
      isReadOnly: !(stat.modeString().contains('w')),
    );
  }

  Future<List<FileMetadata>> readDirectory(Directory dir,
      {bool recursive = false}) async {
    final results = <FileMetadata>[];
    if (!await dir.exists()) return results;
    await for (final entity in dir.list(recursive: recursive)) {
      if (entity is File) {
        final meta = await read(entity);
        if (meta != null) results.add(meta);
      }
    }
    return results;
  }
}
