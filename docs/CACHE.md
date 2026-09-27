# Cache

How the Cambric cache system works.

---

## What is cache?

Cache is **disposable data**. It can always be regenerated from a source.

Examples of cache:
- Downloaded release metadata
- Downloaded assets
- API responses

Examples of NOT cache (user data):
- Application settings
- User-created content
- Configuration

**Clearing cache must NEVER delete user data.**

---

## CacheService

```dart
final cache = CacheService.instance;

// Download and cache a URL
final file = await cache.download(
  'https://example.com/asset.zip',
  'asset.zip',
);

// Check if a cached entry is still valid (within 1 hour)
final valid = await cache.isValid(
  'asset.zip',
  maxAge: Duration(hours: 1),
);

// Get a cached file
final file = await cache.get('asset.zip');

// Save raw bytes
await cache.saveBytes('icon.png', bytes);

// Save text
await cache.saveString('metadata.json', jsonString);

// Delete one entry
await cache.delete('asset.zip');

// Get total cache size
final bytes = await cache.sizeBytes();

// Get entry count
final count = await cache.entryCount();

// Clear everything
await cache.clear();
```

---

## CacheCleanupService

```dart
final cleanup = CacheCleanupService();

// Remove entries older than 7 days
final result = await cleanup.evictExpired(Duration(days: 7));
print('Removed ${result.entriesRemoved} entries');

// Clear all cache (user-initiated)
await cleanup.clearAll();

// Get summary
final summary = await cleanup.summary();
print('${summary.readableSize} in ${summary.entryCount} entries');
```

---

## TTL

Pass `maxAge` to `isValid` or `download`:

```dart
// Only use cached value if fresher than 24 hours
final file = await cache.download(
  url,
  key,
  maxAge: Duration(hours: 24),
);
```

If the cache entry is older than `maxAge`, a fresh download is performed.

---

## Size limits

Set `CacheService.instance.maxSizeBytes` to limit total cache size:

```dart
CacheService.instance.maxSizeBytes = 200 * 1024 * 1024; // 200 MB
```

Default is 500 MB (from `cambric_config.json`).

---

## Cache screen

`CacheScreen` shows size and entry count and provides a clear button.
It never touches user data — only the `cambric_cache` directory.
