import 'package:flutter/material.dart';

/// The colour system for Cambric applications.
///
/// Two layers:
///
///  * **Semantic** ([AppColors]) - what a colour *means*. A screen never picks
///    a hex value; it names a role.
///  * **Surface** ([AppSurfaces]) - the light and dark background ramps.
///
/// Every semantic colour has a light and a dark form. [AppColors.of] resolves
/// between them, so a widget can ask for "the primary colour" without knowing
/// which brightness is active.
///
/// This file is the template's copy of the shared Cambric design system. The
/// values must stay in sync with the web and game templates; see
/// `docs/DESIGN.md`.
class AppColors {
  const AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF3B6FE0);
  static const Color primaryDark = Color(0xFF24509F);
  static const Color accent = Color(0xFF12A594);

  // ── Status ────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF12855F);
  static const Color warning = Color(0xFFB26A00);
  static const Color danger = Color(0xFFC63A34);

  // ── Surfaces and text ─────────────────────────────────────────────────
  static const Color background = Color(0xFFF6F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF5A6478);
  static const Color textMuted = Color(0xFF8A94A6);
  static const Color border = Color(0xFFE2E6EF);

  // ── Gradients ─────────────────────────────────────────────────────────
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: <Color>[Color(0xFF24509F), Color(0xFF4E82F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Dark-mode forms ───────────────────────────────────────────────────
  // Lifted and desaturated: the light values are too dark to read on a dark
  // surface, so these are distinct colours rather than the same hex.
  static const Color darkPrimary = Color(0xFF7FA8FF);
  static const Color darkAccent = Color(0xFF35D0BC);
  static const Color darkSuccess = Color(0xFF43C79A);
  static const Color darkWarning = Color(0xFFE8A33C);
  static const Color darkDanger = Color(0xFFF0736B);
  static const Color darkTextPrimary = Color(0xFFEDF0F6);
  static const Color darkTextSecondary = Color(0xFFA8B2C6);
  static const Color darkTextMuted = Color(0xFF737E92);

  /// Resolve a semantic colour for the current brightness.
  static Color of(Color light, Color dark, BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Background, surface and border ramps for both brightnesses.
class AppSurfaces {
  const AppSurfaces._();

  /// Page background.
  static const Color lightBackground = Color(0xFFF6F8FC);
  static const Color darkBackground = Color(0xFF0E1116);

  /// Raised surface (cards).
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF161B23);

  /// Surface above a card (nested panels, inputs).
  static const Color lightSurfaceRaised = Color(0xFFFAFBFE);
  static const Color darkSurfaceRaised = Color(0xFF1D232D);

  /// Hairline.
  static const Color lightBorder = Color(0xFFE2E6EF);
  static const Color darkBorder = Color(0xFF262E3A);
}

/// Elevation, expressed as shadow.
///
/// Cards use a hairline border instead of a shadow: a soft shadow disappears
/// on a dark surface and reads as smudge rather than depth. These remain for
/// the places where a genuine lift is wanted, such as a dragged surface.
class AppShadows {
  const AppShadows._();

  /// Subtle lift for a resting card.
  static List<BoxShadow> card = <BoxShadow>[
    const BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  /// A tinted lift that picks up an accent colour.
  static List<BoxShadow> coloredCard(Color c) => <BoxShadow>[
    BoxShadow(
      color: c.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// A strong lift for a surface that is genuinely above the page.
  static List<BoxShadow> float = <BoxShadow>[
    const BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 40,
      offset: Offset(0, 12),
    ),
  ];
}
