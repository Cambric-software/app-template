import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_services.dart';
import 'core/config/cambric_config.dart';

/// Where the bundled product configuration lives.
///
/// The same path is used by `.template/setup/setup.ps1` and
/// `scripts-doctor.ps1`, and it is declared under `flutter.assets` in
/// `pubspec.yaml` so it is available in release builds.
const String kConfigAsset = 'lib/core/config/cambric_config.json';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = await CambricConfig.loadBundled(kConfigAsset);
  final services = AppServices(config: config);
  await services.initialize();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    services.diagnostics.reportError(
      'Unhandled Flutter error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  final themeName = await services.preferences.getString(
    AppPreferenceKeys.themeMode,
  );
  final onboardingComplete = await services.preferences.getBool(
    AppPreferenceKeys.onboardingComplete,
  );

  runApp(
    CambricApp(
      services: services,
      initialThemeMode: themeModeFromName(themeName),
      initialOnboardingComplete: onboardingComplete ?? false,
    ),
  );
}
