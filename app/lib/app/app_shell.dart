import 'package:flutter/material.dart';

import '../screens/components/components_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/settings/settings_screen.dart';
import 'package:cambric_design/cambric_design.dart';
import '../widgets/cambric_version_label.dart';
import 'app_services.dart';

/// The three top-level places in the template.
enum AppDestination {
  /// What the template gives you, with live values.
  home('Home', Icons.home_outlined, Icons.home_rounded),

  /// The living component gallery.
  components('Components', Icons.widgets_outlined, Icons.widgets_rounded),

  /// Theme, cache, diagnostics and onboarding.
  settings('Settings', Icons.settings_outlined, Icons.settings_rounded);

  const AppDestination(this.label, this.icon, this.selectedIcon);

  /// Label shown in the navigation.
  final String label;

  /// Unselected icon.
  final IconData icon;

  /// Selected icon.
  final IconData selectedIcon;
}

/// Responsive shell: bottom navigation on phones, a navigation rail on wide
/// windows and desktop.
class AppShell extends StatefulWidget {
  /// Create the shell.
  const AppShell({
    super.key,
    required this.services,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onReplayOnboarding,
  });

  /// Application services, passed explicitly to each screen.
  final AppServices services;

  /// Current theme choice, owned by [CambricApp].
  final ThemeMode themeMode;

  /// Called when Settings changes the theme.
  final ValueChanged<ThemeMode> onThemeModeChanged;

  /// Called when Settings asks to replay the welcome flow.
  final VoidCallback onReplayOnboarding;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  AppDestination get _destination => AppDestination.values[_index];

  Widget _screen() {
    switch (_destination) {
      case AppDestination.home:
        return HomeScreen(services: widget.services);
      case AppDestination.components:
        return const ComponentsScreen();
      case AppDestination.settings:
        return SettingsScreen(
          services: widget.services,
          themeMode: widget.themeMode,
          onThemeModeChanged: widget.onThemeModeChanged,
          onReplayOnboarding: widget.onReplayOnboarding,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final usesRail = Breakpoints.usesRail(width);

    if (!usesRail) {
      return Scaffold(
        body: _screen(),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: <Widget>[
            for (final destination in AppDestination.values)
              NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: destination.label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                right: BorderSide(color: theme.colorScheme.outline),
              ),
            ),
            child: NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.sm,
                  Space.lg,
                  Space.sm,
                  Space.xl,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(Radii.button),
                      ),
                      child: Icon(
                        Icons.layers_rounded,
                        size: 20,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: Space.sm),
                    SizedBox(
                      width: 84,
                      child: Text(
                        widget.services.config.productName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(bottom: Space.lg),
                child: CambricVersionLabel(
                  version: widget.services.version.versionString,
                ),
              ),
              destinations: <NavigationRailDestination>[
                for (final destination in AppDestination.values)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: Text(destination.label),
                  ),
              ],
            ),
          ),
          Expanded(child: _screen()),
        ],
      ),
    );
  }
}
