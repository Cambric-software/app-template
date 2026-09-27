import 'package:flutter_test/flutter_test.dart';

import 'package:cambric_app/main.dart';
import 'package:cambric_app/core/config/cambric_config.dart';

void main() {
  testWidgets('App renders with config', (WidgetTester tester) async {
    const config = CambricConfig(
      productId: 'test-product',
      productName: 'Test App',
      version: '1.0.0',
      templateVersion: '1.0.0',
    );

    await tester.pumpWidget(
      const CambricTemplateApp(
        config: config,
        existingProducts: [],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test App'), findsOneWidget);
  });

  testWidgets('Setup button is visible', (WidgetTester tester) async {
    const config = CambricConfig(
      productId: 'test-product',
      productName: 'Test App',
      version: '1.0.0',
      templateVersion: '1.0.0',
    );

    await tester.pumpWidget(
      const CambricTemplateApp(
        config: config,
        existingProducts: [],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Open Cambric Setup'), findsOneWidget);
  });
}
