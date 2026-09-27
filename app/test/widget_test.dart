import 'package:flutter_test/flutter_test.dart';
import 'package:cambric_app/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const CambricTemplateApp());
    await tester.pumpAndSettle();

    expect(find.text('Cambric App'), findsOneWidget);
  });
}
