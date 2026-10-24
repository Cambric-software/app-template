import 'package:flutter/material.dart';

import '../../../app/app_services.dart';
import '../../../core/platform/platform_service.dart';
import 'package:cambric_design/cambric_design.dart';
import 'package:cambric_design/cambric_design.dart';
import '../cache/cache_screen.dart';
import '../diagnostics/diagnostics_screen.dart';

/// Theme, onboarding, cache, diagnostics and product identity.
class SettingsScreen extends StatelessWidget {
  /// Create settings.
  const SettingsScreen({
    super.key,
    required this.services,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onReplayOnboarding,
  });

  /// Application services.
  final AppServices services;

  /// Current theme choice.
  final ThemeMode themeMode;

  /// Called when the user changes the theme.
  final ValueChanged<ThemeMode> onThemeModeChanged;

  /// Re-opens the first-run welcome.
  final VoidCallback onReplayOnboarding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = services.config;

    return DsPage(
      title: 'Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DsSection(
            title: 'Appearance',
            subtitle: 'Stored in shared preferences and restored at startup.',
            child: DsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const DsLabel('Theme'),
                  const SizedBox(height: Space.sm),
                  DsSegmented<ThemeMode>(
                    value: themeMode,
                    options: const <DsSegment<ThemeMode>>[
                      DsSegment<ThemeMode>(
                        value: ThemeMode.system,
                        label: 'System',
                        icon: Icons.brightness_auto_outlined,
                      ),
                      DsSegment<ThemeMode>(
                        value: ThemeMode.light,
                        label: 'Light',
                        icon: Icons.light_mode_outlined,
                      ),
                      DsSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        label: 'Dark',
                        icon: Icons.dark_mode_outlined,
                      ),
                    ],
                    onChanged: onThemeModeChanged,
                  ),
                  const SizedBox(height: Space.md),
                  Text(
                    'Both themes are complete designs. Switching does not reload '
                    'the app.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Space.xl),
          DsSection(
            title: 'Application',
            subtitle: 'Real screens backed by the kept services.',
            child: DsCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.storage_outlined),
                    title: const Text('Cache'),
                    subtitle: const Text('Inspect and clear disposable files'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CacheScreen(services: services),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: theme.colorScheme.outline),
                  ListTile(
                    leading: const Icon(Icons.troubleshoot_outlined),
                    title: const Text('Diagnostics'),
                    subtitle: const Text('Local report, copy or save it'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DiagnosticsScreen(services: services),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Space.xl),
          DsSection(
            title: 'Welcome flow',
            subtitle: 'Shown on first launch; you can replay it without resetting data.',
            child: DsCard(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'The welcome pages explain what this template does. They '
                      'are not a setup wizard and do not create fake data.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  OutlinedButton.icon(
                    onPressed: onReplayOnboarding,
                    icon: const Icon(Icons.replay_outlined),
                    label: const Text('Replay'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Space.xl),
          DsSection(
            title: 'About',
            subtitle: 'Identity comes from the bundled configuration.',
            child: DsCard(
              child: Column(
                children: <Widget>[
                  _InfoRow(label: 'Product', value: config.productName),
                  _InfoRow(label: 'Product id', value: config.productId),
                  _InfoRow(
                    label: 'Version',
                    value: services.version.versionString,
                  ),
                  _InfoRow(
                    label: 'Template',
                    value: config.templateVersion,
                  ),
                  _InfoRow(label: 'Environment', value: config.environment),
                  _InfoRow(label: 'Platform', value: PlatformService.name),
                  _InfoRow(
                    label: 'Release repository',
                    value: config.repository?.trim().isNotEmpty == true
                        ? config.repository!
                        : 'Not configured',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 150,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
