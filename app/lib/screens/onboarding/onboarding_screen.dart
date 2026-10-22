import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';

/// A single onboarding page definition.
class OnboardingPage {
  /// Create a page.
  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  /// Illustrative icon.
  final IconData icon;

  /// Page title.
  final String title;

  /// What this page is telling the user.
  final String description;
}

/// Reusable paged onboarding screen.
///
/// Provide [pages] with your product-specific content. Call [onComplete] when
/// the user finishes or skips; the caller is responsible for persisting that
/// choice, so re-opening onboarding is possible from Settings.
///
/// Usage:
///
/// ```dart
/// OnboardingScreen(
///   pages: const <OnboardingPage>[
///     OnboardingPage(
///       icon: Icons.storage_outlined,
///       title: 'Local first',
///       description: 'All your data stays on your device.',
///     ),
///   ],
///   onComplete: () => Navigator.of(context).pushReplacement(...),
/// )
/// ```
class OnboardingScreen extends StatefulWidget {
  /// Create an onboarding flow.
  const OnboardingScreen({
    super.key,
    required this.pages,
    required this.onComplete,
    this.skipLabel,
    this.finishLabel,
  }) : assert(pages.length > 0, 'Onboarding needs at least one page.');

  /// Pages, shown in order.
  final List<OnboardingPage> pages;

  /// Called when the user skips or finishes the last page.
  final VoidCallback onComplete;

  /// Label for the skip action.
  final String? skipLabel;

  /// Label for the final action.
  final String? finishLabel;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < widget.pages.length - 1) {
      _controller.nextPage(
        duration: Motion.normal,
        curve: Motion.enter,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _current == widget.pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Space.lg,
                      Space.sm,
                      Space.lg,
                      0,
                    ),
                    child: TextButton(
                      onPressed: widget.onComplete,
                      child: Text(widget.skipLabel ?? 'Skip'),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _current = i),
                    itemCount: widget.pages.length,
                    itemBuilder: (context, index) {
                      final page = widget.pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.xl,
                          vertical: Space.lg,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(Radii.lg),
                              ),
                              child: Icon(
                                page.icon,
                                size: 42,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: Space.xl),
                            Text(
                              page.title,
                              style: theme.textTheme.displaySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: Space.md),
                            Text(
                              page.description,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(widget.pages.length, (i) {
                    final selected = _current == i;
                    return AnimatedContainer(
                      duration: Motion.normal,
                      margin: const EdgeInsets.symmetric(horizontal: Space.xs),
                      width: selected ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: Space.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.xl),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '${_current + 1} of ${widget.pages.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.of(
                            AppColors.textMuted,
                            AppColors.darkTextMuted,
                            context,
                          ),
                        ),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: _next,
                        child: Text(
                          isLast
                              ? (widget.finishLabel ?? 'Get started')
                              : 'Next',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Space.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
