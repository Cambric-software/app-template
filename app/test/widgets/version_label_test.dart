import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cambric_app/widgets/cambric_version_label.dart';

void main() {
  group('CambricVersionLabel', () {
    testWidgets('displays version with v prefix', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CambricVersionLabel(version: '1.4.3'),
          ),
        ),
      );

      expect(find.text('v1.4.3'), findsOneWidget);
    });

    testWidgets('does not double-prefix v', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CambricVersionLabel(version: 'v2.0.0'),
          ),
        ),
      );

      expect(find.text('v2.0.0'), findsOneWidget);
      expect(find.text('vv2.0.0'), findsNothing);
    });

    testWidgets('has semantics label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CambricVersionLabel(version: '1.0.0'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.text('v1.0.0'));
      expect(semantics.label, contains('1.0.0'));
    });
  });
}
