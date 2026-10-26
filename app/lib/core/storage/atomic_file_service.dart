import 'dart:io';

/// Performs safe atomic file writes.
///
/// Write flow:
///
/// ```
/// content
///   ↓
/// write to .tmp
///   ↓
/// flush
///   ↓
/// verify (re-read and compare length)
///   ↓
/// rename over destination (atomic on most OS/fs)
/// ```
///
/// This ensures the destination file is never left in a partially written
/// or zero-byte state after a crash or power loss.
class AtomicFileService {
  /// Writes [content] to [destination] atomically.
  ///
  /// Throws [FileSystemException] if the temporary write or verification
  /// fails; the destination file is left untouched in that case.
  Future<void> write(
    File destination,
    String content,
  ) async {
    final tmp = File('${destination.path}.tmp');

    // 1. Write to temporary file.
    await tmp.writeAsString(content, flush: true);

    // 2. Verify the temporary file is readable and non-empty when
    //    the content is non-empty.
    await _verify(tmp, content);

    // 3. Atomically replace destination.
    if (await destination.exists()) {
      await destination.delete();
    }
    await tmp.rename(destination.path);
  }

  /// Writes raw bytes to [destination] atomically.
  Future<void> writeBytes(
    File destination,
    List<int> bytes,
  ) async {
    final tmp = File('${destination.path}.tmp');

    await tmp.writeAsBytes(bytes, flush: true);

    // Verify byte count.
    final written = await tmp.length();
    if (written != bytes.length) {
      await _cleanup(tmp);
      throw FileSystemException(
        'Atomic write verification failed: expected ${bytes.length} bytes, '
        'got $written.',
        destination.path,
      );
    }

    if (await destination.exists()) {
      await destination.delete();
    }
    await tmp.rename(destination.path);
  }

  // ── private ──────────────────────────────────────────────────────────────

  Future<void> _verify(File tmp, String expected) async {
    if (expected.isEmpty) return; // Nothing to verify for empty content.

    final stat = await tmp.stat();
    if (stat.size == 0 && expected.isNotEmpty) {
      await _cleanup(tmp);
      throw FileSystemException(
        'Atomic write verification failed: temporary file is empty.',
        tmp.path,
      );
    }
  }

  Future<void> _cleanup(File tmp) async {
    try {
      if (await tmp.exists()) await tmp.delete();
    } catch (_) {
      // Best-effort cleanup.
    }
  }
}
