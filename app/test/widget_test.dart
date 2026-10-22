import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cambric_app/app/app.dart';
import 'package:cambric_app/app/app_services.dart';
import 'package:cambric_app/core/config/cambric_config.dart';

const CambricConfig _config = CambricConfig(
  productId: 'test-product',
  productName: 'Test App',
  subtitle: 'A test product',
  version: '1.0.0',
  templateVersion: '1.0.0',
);

AppServices _services() => AppServices(config: _config);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('app shell renders Home for a returning user', (tester) async {
    await tester.pumpWidget(
      CambricApp(
        services: _services(),
        initialOnboardingComplete: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('What this template gives you'), findsOneWidget);
    expect(find.text('Test App'), findsOneWidget);
    expect(find.text('v1.0.0'), findsWidgets);
  });

  testWidgets('bottom navigation reaches Components and Settings', (tester) async {
    await tester.pumpWidget(
      CambricApp(
        services: _services(),
        initialOnboardingComplete: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Components'));
    await tester.pumpAndSettle();
    expect(find.text('Buttons'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Cache'), findsOneWidget);
    expect(find.text('Diagnostics'), findsOneWidget);
  });

  testWidgets('first launch shows onboarding and Skip enters the app',
      (tester) async {
    await tester.pumpWidget(
      CambricApp(
        services: _services(),
        initialOnboardingComplete: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Local-first by default'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('What this template gives you'), findsOneWidget);
  });

  testWidgets('theme mode change rebuilds the app', (tester) async {
    await tester.pumpWidget(
      CambricApp(
        services: _services(),
        initialOnboardingComplete: true,
        initialThemeMode: ThemeMode.light,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme_mode'), 'dark');
  });
}
