import 'package:flutter/material.dart';

import '../../../app/app_services.dart';
import '../../../core/cache/cache_cleanup_service.dart';
import 'package:cambric_design/cambric_design.dart';
import '../../widgets/cambric_version_label.dart';

/// What the template gives you, with values read from the services at runtime.
class HomeScreen extends StatefulWidget {
  /// Create the home screen.
  const HomeScreen({super.key, required this.services});

  /// Application services.
  final AppServices services;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeData {
  const _HomeData({
    required this.storagePath,
    required this.cache,
    this.lastCheck,
    this.lastCheckState,
  });

  final String storagePath;
  final CacheSummary cache;
  final DateTime? lastCheck;
  final String? lastCheckState;
}

/// Key used for the last user-initiated update check, stored as user data.
const String _lastCheckKey = 'last_update_check';

class _HomeScreenState extends State<HomeScreen> {
  _HomeData? _data;
  bool _checking = false;
  String? _checkMessage;

  String get _repository => widget.services.config.repository?.trim() ?? '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    String path;
    CacheSummary cache;

    try {
      final directory = await widget.services.storage.dataDirectory;
      path = directory.path;
    } catch (error) {
      path = 'Unavailable';
      widget.services.diagnostics.reportError(
        'Could not resolve the data directory',
        error: error,
      );
    }

    try {
      cache = await widget.services.cacheCleanup.summary();
    } catch (error) {
      cache = const CacheSummary(sizeBytes: 0, entryCount: 0);
      widget.services.diagnostics.reportError('Could not read cache size', error: error);
    }

    final raw = await widget.services.storage.read(_lastCheckKey);
    DateTime? lastCheck;
    String? lastState;

    if (raw is Map<String, dynamic>) {
      lastCheck = DateTime.tryParse(raw['at']?.toString() ?? '');
      lastState = raw['state']?.toString();
    }

    if (!mounted) return;
    setState(() {
      _data = _HomeData(
        storagePath: path,
        cache: cache,
        lastCheck: lastCheck,
        lastCheckState: lastState,
      );
    });
  }

  Future<void> _checkForUpdates() async {
    if (_repository.isEmpty || _checking) return;

    setState(() {
      _checking = true;
      _checkMessage = null;
    });

    final release = await widget.services.updates.check(_repository);
    final state = widget.services.updates.state;
    final checkedAt = DateTime.now();

    await widget.services.storage.write(_lastCheckKey, <String, dynamic>{
      'at': checkedAt.toIso8601String(),
      'state': state.name,
      'version': release?.version ?? '',
    });

    if (!mounted) return;
    setState(() {
      _checking = false;
      _checkMessage = release == null
          ? 'Check finished: ${state.name}.'
          : 'Latest release: ${release.version}.';
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _data;
    final config = widget.services.config;

    return DsPage(
      title: 'Home',
      actions: <Widget>[
        CambricVersionLabel(version: widget.services.version.versionString),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DsCard(
            color: theme.colorScheme.primaryContainer,
            borderColor: theme.colorScheme.primary.withValues(alpha: 0.28),
            padding: const EdgeInsets.all(Space.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.layers_rounded,
                  size: 34,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: Space.md),
                Text(
                  config.productName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: Space.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(
                    config.subtitle == null || config.subtitle!.isEmpty
                        ? 'A Cambric application foundation: local-first storage, '
                            'cache, updates, diagnostics and one design system.'
                        : config.subtitle!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.xxl),
          DsSection(
            title: 'Live values',
            subtitle: 'Read from the running services, not hard-coded strings.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DsGrid(
                  minTileWidth: 220,
                  children: <Widget>[
                    DsMetricTile(
                      label: 'Version',
                      value: widget.services.version.versionString,
                      accent: theme.colorScheme.primary,
                      icon: Icons.tag,
                    ),
                    DsMetricTile(
                      label: 'Cache',
                      value: data?.cache.readableSize ?? '...',
                      accent: AppColors.accent,
                      icon: Icons.storage_outlined,
                    ),
                    DsMetricTile(
                      label: 'Last update check',
                      value: _relativeTime(data?.lastCheck),
                      accent: AppColors.warning,
                      icon: Icons.schedule_outlined,
                      status: _checkStatus(data?.lastCheckState),
                    ),
                  ],
                ),
                const SizedBox(height: Space.md),
                DsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const DsLabel('Storage path'),
                      const SizedBox(height: Space.xs),
                      SelectableText(
                        data?.storagePath ?? 'Resolving...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: Space.sm),
                      Text(
                        'User data stays here. Clearing the cache removes only '
                        'disposable files.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          DsSection(
            title: 'Updates',
            subtitle: 'Release discovery is real, and disabled until you point it '
                'at a repository.',
            child: DsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _repository.isEmpty
                              ? 'No release repository configured'
                              : _repository,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      if (_checking)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: Space.sm),
                  Text(
                    _repository.isEmpty
                        ? 'Set release.repository in cambric_config.json to '
                            'enable update checks for this product.'
                        : 'The check reads the latest GitHub release and records '
                            'when it last ran.',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (_checkMessage != null) ...<Widget>[
                    const SizedBox(height: Space.sm),
                    Text(_checkMessage!, style: theme.textTheme.bodySmall),
                  ],
                  const SizedBox(height: Space.md),
                  Wrap(
                    spacing: Space.sm,
                    runSpacing: Space.sm,
                    children: <Widget>[
                      FilledButton.icon(
                        onPressed: _repository.isEmpty || _checking
                            ? null
                            : _checkForUpdates,
                        icon: const Icon(Icons.system_update_alt),
                        label: const Text('Check for updates'),
                      ),
                      if (_repository.isEmpty)
                        const DsStatusPill(
                          label: 'Not configured',
                          color: AppColors.textMuted,
                          dense: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Space.xl),
          DsSection(
            title: 'What this template gives you',
            subtitle: 'Each card maps to code in this repository.',
            child: DsGrid(
              children: <Widget>[
                const DsInfoCard(
                  title: 'Design system',
                  subtitle: 'Palette, type, spacing and components',
                  icon: Icons.palette_outlined,
                  badge: 'Shared',
                  badgeStatus: DsStatus.info,
                  details: <String>[
                    'Light and dark are complete designs, not an inversion.',
                    'Spacing, radii and type come from design_tokens.dart.',
                    'The Components tab is the living gallery.',
                  ],
                ),
                const DsInfoCard(
                  title: 'Storage and cache',
                  subtitle: 'User data and disposable files are separate',
                  icon: Icons.folder_outlined,
                  badge: 'Wired',
                  badgeStatus: DsStatus.positive,
                  details: <String>[
                    'LocalStorage writes JSON under the product data folder.',
                    'CacheService uses TTL metadata and can be cleared safely.',
                    'Atomic writes avoid a half-written settings file.',
                  ],
                ),
                DsInfoCard(
                  title: 'Updates',
                  subtitle: 'GitHub release discovery and verification',
                  icon: Icons.system_update_outlined,
                  badge: _repository.isEmpty ? 'Configure' : 'Configured',
                  badgeStatus: _repository.isEmpty
                      ? DsStatus.warning
                      : DsStatus.positive,
                  details: const <String>[
                    'ReleaseService reads releases/latest and caches metadata.',
                    'UpdateService checks, downloads and verifies packages.',
                    'A supplied checksum must match; the template verifies and '
                        'stops without installing.',
                  ],
                ),
                const DsInfoCard(
                  title: 'Diagnostics',
                  subtitle: 'Local report, no telemetry',
                  icon: Icons.bug_report_outlined,
                  badge: 'Wired',
                  badgeStatus: DsStatus.positive,
                  details: <String>[
                    'Network, storage and cache health are reported.',
                    'Secrets are redacted before the report is shown.',
                    'The report can be copied or saved under Cambric/Logs.',
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _relativeTime(DateTime? time) {
    if (time == null) return 'Never';
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    final local = time.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  static HealthStatus? _checkStatus(String? state) {
    if (state == null) return null;
    switch (state) {
      case 'available':
        return HealthStatus.normal;
      case 'notAvailable':
        return HealthStatus.normal;
      case 'checkFailed':
        return HealthStatus.critical;
      default:
        return HealthStatus.normal;
    }
  }
}
