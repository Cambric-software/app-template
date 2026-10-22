import 'package:flutter/material.dart';

import '../screens/onboarding/onboarding_screen.dart';
import '../theme/app_theme.dart';
import 'app_services.dart';
import 'app_shell.dart';

/// Persisted preference keys owned by the app shell.
class AppPreferenceKeys {
  const AppPreferenceKeys._();

  /// `ThemeMode.name` for the selected theme.
  static const String themeMode = 'theme_mode';

  /// Whether the first-run welcome has been completed.
  static const String onboardingComplete = 'onboarding_complete';
}

/// Resolve a stored theme name back to a [ThemeMode].
ThemeMode themeModeFromName(String? name) {
  switch (name) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

/// The root widget. It owns the theme mode and whether the welcome flow is
/// showing, so both can be persisted and replayed from Settings.
class CambricApp extends StatefulWidget {
  /// Create the app.
  const CambricApp({
    super.key,
    required this.services,
    this.initialThemeMode = ThemeMode.system,
    this.initialOnboardingComplete = false,
  });

  /// Services loaded in `main()`.
  final AppServices services;

  /// Theme mode read from preferences before the first frame.
  final ThemeMode initialThemeMode;

  /// Whether the welcome flow has already been completed.
  final bool initialOnboardingComplete;

  @override
  State<CambricApp> createState() => _CambricAppState();
}

class _CambricAppState extends State<CambricApp> {
  late ThemeMode _themeMode = widget.initialThemeMode;
  late bool _onboardingComplete = widget.initialOnboardingComplete;

  List<OnboardingPage> get _onboardingPages {
    final config = widget.services.config;
    final repository = config.repository?.trim() ?? '';

    return <OnboardingPage>[
      const OnboardingPage(
        icon: Icons.storage_outlined,
        title: 'Local-first by default',
        description:
            'User data is written to a product-scoped folder on this device. '
            'This template never sends diagnostics anywhere unless your product '
            'adds that step.',
      ),
      const OnboardingPage(
        icon: Icons.palette_outlined,
        title: 'A design system, not a seed colour',
        description:
            'The theme and widget library are shared with Cambric web and game '
            'products, so a new app starts in the same visual language.',
      ),
      OnboardingPage(
        icon: Icons.system_update_outlined,
        title: 'Updates stay under your control',
        description: repository.isEmpty
            ? 'Set release.repository in cambric_config.json to connect a '
                'GitHub release feed. Until then, the update check is disabled '
                'rather than showing a fake result.'
            : 'Release checks read $repository. Nothing downloads or installs '
                'without an explicit action.',
      ),
    ];
  }

  Future<void> _completeOnboarding() async {
    await widget.services.preferences.setBool(
      AppPreferenceKeys.onboardingComplete,
      true,
    );
    if (!mounted) return;
    setState(() => _onboardingComplete = true);
  }

  void _replayOnboarding() {
    setState(() => _onboardingComplete = false);
  }

  Future<void> _changeThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await widget.services.preferences.setString(
      AppPreferenceKeys.themeMode,
      mode.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: widget.services.config.productName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: _onboardingComplete
          ? AppShell(
              services: widget.services,
              themeMode: _themeMode,
              onThemeModeChanged: _changeThemeMode,
              onReplayOnboarding: _replayOnboarding,
            )
          : OnboardingScreen(
              pages: _onboardingPages,
              onComplete: _completeOnboarding,
            ),
    );
  }
}
