import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../core/cache/cache_cleanup_service.dart';
import 'package:cambric_design/cambric_design.dart';
import 'package:cambric_design/cambric_design.dart';

/// Inspect and clear the disposable cache.
///
/// Uses [CacheCleanupService], which only touches the cache directory. User data
/// stored through `LocalStorage` is never removed here.
class CacheScreen extends StatefulWidget {
  /// Create the cache screen.
  const CacheScreen({super.key, required this.services});

  /// Application services.
  final AppServices services;

  @override
  State<CacheScreen> createState() => _CacheScreenState();
}

class _CacheScreenState extends State<CacheScreen> {
  CacheSummary? _summary;
  String? _error;
  bool _loading = true;
  bool _clearing = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final summary = await widget.services.cacheCleanup.summary();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _loading = false;
      });
    } catch (error) {
      widget.services.diagnostics.reportError('Could not read cache state', error: error);
      if (!mounted) return;
      setState(() {
        _error = 'The cache directory could not be read.';
        _loading = false;
      });
    }
  }

  Future<void> _clear() async {
    setState(() => _clearing = true);

    try {
      final result = await widget.services.cacheCleanup.clearAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cleared ${result.entriesRemoved} items '
            '(${_formatBytes(result.bytesFreed)}).',
          ),
        ),
      );
    } catch (error) {
      widget.services.diagnostics.reportError('Could not clear cache', error: error);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clearing the cache failed.')),
      );
    }

    await _refresh();
    if (mounted) setState(() => _clearing = false);
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = _summary;
    final empty = summary != null && summary.entryCount == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loading ? null : _refresh,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : DsPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DsGrid(
                    minTileWidth: 220,
                    children: <Widget>[
                      DsMetricTile(
                        label: 'Total size',
                        value: summary?.readableSize ?? 'Unknown',
                        accent: theme.colorScheme.primary,
                        icon: Icons.storage_outlined,
                        status: summary == null
                            ? HealthStatus.normal
                            : HealthStatus.normal,
                      ),
                      DsMetricTile(
                        label: 'Cached items',
                        value: '${summary?.entryCount ?? 0}',
                        accent: AppColors.accent,
                        icon: Icons.folder_outlined,
                        status: empty ? HealthStatus.normal : HealthStatus.normal,
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.lg),
                  DsCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: Space.sm),
                        Expanded(
                          child: Text(
                            'Cache is disposable. Clearing it never deletes user '
                            'data, backups or settings.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...<Widget>[
                    const SizedBox(height: Space.lg),
                    DsCard(
                      borderColor: theme.colorScheme.error,
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: Space.xl),
                  if (empty)
                    const DsCard(
                      padding: EdgeInsets.zero,
                      child: DsEmptyState(
                        icon: Icons.cleaning_services_outlined,
                        title: 'Cache is empty',
                        message:
                            'There are no disposable files yet. Products fill '
                            'this through CacheService.',
                      ),
                    ),
                  const SizedBox(height: Space.lg),
                  FilledButton.icon(
                    onPressed: _clearing || summary == null || empty
                        ? null
                        : _clear,
                    icon: _clearing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline),
                    label: Text(_clearing ? 'Clearing...' : 'Clear cache'),
                  ),
                ],
              ),
            ),
    );
  }
}
