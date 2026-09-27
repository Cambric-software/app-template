import 'package:flutter/material.dart';

enum ScreenClass { compact, medium, expanded }

/// Breakpoints from Material Design 3 adaptive layout guidelines.
abstract class Breakpoints {
  static const double compact = 600;
  static const double medium = 840;
}

/// Responsive layout builder that provides the current screen class.
class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext, ScreenClass) builder;

  const ResponsiveLayout({super.key, required this.builder});

  static ScreenClass of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < Breakpoints.compact) return ScreenClass.compact;
    if (width < Breakpoints.medium) return ScreenClass.medium;
    return ScreenClass.expanded;
  }

  static bool isCompact(BuildContext context) => of(context) == ScreenClass.compact;
  static bool isMedium(BuildContext context) => of(context) == ScreenClass.medium;
  static bool isExpanded(BuildContext context) => of(context) == ScreenClass.expanded;
  static bool isDesktop(BuildContext context) => of(context) == ScreenClass.expanded;
  static bool isMobile(BuildContext context) => isCompact(context);

  @override
  Widget build(BuildContext context) {
    return builder(context, of(context));
  }
}

/// Two-panel adaptive layout: single-pane on compact, side-by-side on wider.
class AdaptiveTwoPanel extends StatelessWidget {
  final Widget sidebar;
  final Widget detail;
  final double sidebarWidth;

  const AdaptiveTwoPanel({
    super.key,
    required this.sidebar,
    required this.detail,
    this.sidebarWidth = 280,
  });

  @override
  Widget build(BuildContext context) {
    final cls = ResponsiveLayout.of(context);
    if (cls == ScreenClass.compact) return sidebar;
    return Row(
      children: [
        SizedBox(width: sidebarWidth, child: sidebar),
        const VerticalDivider(width: 1),
        Expanded(child: detail),
      ],
    );
  }
}
