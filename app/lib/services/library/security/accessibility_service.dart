import 'package:flutter/material.dart';

/// Accessibility helpers for semantic labels, focus, and text scaling.
class AccessibilityService {
  String get name => 'AccessibilityService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  double textScaleFactor(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(1.0);

  bool isLargeText(BuildContext context) => textScaleFactor(context) >= 1.4;

  bool prefersReducedMotion(BuildContext context) =>
      MediaQuery.of(context).disableAnimations;

  bool isHighContrast(BuildContext context) =>
      MediaQuery.of(context).highContrast;

  Widget withSemanticLabel(String label, Widget child) =>
      Semantics(label: label, child: child);

  Widget excludeFromSemantics(Widget child) =>
      ExcludeSemantics(child: child);

  /// Returns a focus node that can be requested programmatically.
  FocusNode createFocusNode({String? debugLabel}) =>
      FocusNode(debugLabel: debugLabel);
}
