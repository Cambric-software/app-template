import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_services.dart';
import '../../core/cache/cache_cleanup_service.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/platform/platform_service.dart';
import '../../core/storage/cambric_paths.dart';
import 'package:cambric_design/cambric_design.dart';
import 'package:cambric_design/cambric_design.dart';

/// Local diagnostics: platform, connectivity, storage, cache and a report the
/// user can copy or save. Nothing is transmitted.
class DiagnosticsScreen extends StatefulWidget {
  /// Create the diagnostics screen.
  const DiagnosticsScreen({super.key, required this.services});

  /// Application services.
  final AppServices services;

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  String _report = '';
  ConnectivityState _connectivity = ConnectivityState.unknown;
  CacheSummary? _cache;
  bool _storageHealthy = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _gather();
  }

  Future<void> _gather() async {
    setState(() => _loading = true);

    final connectivity = await widget.services.connectivity.check();

    var storageHealthy = false;
    try {
      final directory = await widget.services.storage.dataDirectory;
      storageHealthy = await directory.exists();
    } catch (error) {
      widget.services.diagnostics.reportError(
        'Storage check failed',
        error: error,
      );
    }

    CacheSummary? cache;
    try {
      cache = await widget.services.cacheCleanup.summary();
    } catch (error) {
      widget.services.diagnostics.reportError('Cache check failed', error: error);
    }

    widget.services.diagnostics
      ..setNetworkHealthy(connectivity == ConnectivityState.online)
      ..setStorageHealthy(storageHealthy)
      ..setCacheHealthy(cache != null);

    final report = await widget.services.diagnostics.generateReport();

    if (!mounted) return;
    setState(() {
      _connectivity = connectivity;
      _storageHealthy = storageHealthy;
      _cache = cache;
      _report = report;
      _loading = false;
    });
  }

  Future<void> _copyReport() async {
    await Clipboard.setData(ClipboardData(text: _report));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnostics copied to clipboard.')),
    );
  }

  Future<void> _saveReport() async {
    setState(() => _saving = true);

    final logs = await CambricPaths.logs();
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(RegExp(r'[:.]'), '-');
    final file = File('${logs.path}${Platform.pathSeparator}diagnostics-$stamp.txt');
    final saved = await widget.services.diagnostics.writeReportToFile(file);

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Saved to ${file.path}'
              : 'The report could not be saved.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Run checks again',
            onPressed: _loading ? null : _gather,
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
                      _CheckCard(
                        title: 'Connectivity',
                        value: _connectivityLabel,
                        status: _connectivityStatus,
                        icon: Icons.wifi_outlined,
                      ),
                      _CheckCard(
                        title: 'Storage',
                        value: _storageHealthy ? 'Writable' : 'Unavailable',
                        status: _storageHealthy
                            ? DsStatus.positive
                            : DsStatus.critical,
                        icon: Icons.folder_outlined,
                      ),
                      _CheckCard(
                        title: 'Cache',
                        value: _cache == null
                            ? 'Unavailable'
                            : '${_cache!.entryCount} items, '
                                '${_cache!.readableSize}',
                        status: _cache == null
                            ? DsStatus.critical
                            : DsStatus.positive,
                        icon: Icons.storage_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.lg),
                  Wrap(
                    spacing: Space.sm,
                    runSpacing: Space.sm,
                    children: <Widget>[
                      DsStatusPill(
                        label: PlatformService.name,
                        color: theme.colorScheme.primary,
                        icon: Icons.devices_outlined,
                      ),
                      DsStatusPill(
                        label: widget.services.config.environment,
                        color: theme.colorScheme.secondary,
                        icon: Icons.terminal_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.xl),
                  DsSection(
                    title: 'Report',
                    subtitle:
                        'Secrets are redacted. Nothing leaves the device unless '
                        'you copy or save it.',
                    child: DsCard(
                      padding: const EdgeInsets.all(Space.md),
                      child: SelectableText(
                        _report,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Space.lg),
                  Wrap(
                    spacing: Space.sm,
                    runSpacing: Space.sm,
                    children: <Widget>[
                      OutlinedButton.icon(
                        onPressed: _report.isEmpty ? null : _copyReport,
                        icon: const Icon(Icons.copy_outlined),
                        label: const Text('Copy report'),
                      ),
                      FilledButton.icon(
                        onPressed: _report.isEmpty || _saving ? null : _saveReport,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(_saving ? 'Saving...' : 'Save to logs'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  String get _connectivityLabel {
    switch (_connectivity) {
      case ConnectivityState.online:
        return 'Online';
      case ConnectivityState.offline:
        return 'Offline';
      case ConnectivityState.unknown:
        return 'Unknown';
    }
  }

  DsStatus get _connectivityStatus {
    switch (_connectivity) {
      case ConnectivityState.online:
        return DsStatus.positive;
      case ConnectivityState.offline:
        return DsStatus.warning;
      case ConnectivityState.unknown:
        return DsStatus.unknown;
    }
  }
}

class _CheckCard extends StatelessWidget {
  const _CheckCard({
    required this.title,
    required this.value,
    required this.status,
    required this.icon,
  });

  final String title;
  final String value;
  final DsStatus status;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = dsStatusColor(status, context);

    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: Space.sm),
              Expanded(child: DsLabel(title)),
              DsStatusPill(
                label: status.label,
                color: color,
                icon: status.icon,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}
