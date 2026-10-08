import 'package:flutter/material.dart';

/// Brand palette and gradients for AskMyDocs.
abstract final class AppColors {
  /// Deep indigo – the primary brand color and theme seed.
  static const Color indigo = Color(0xFF4F46E5);

  /// Seed for the generated Material 3 color scheme.
  static const Color seed = indigo;

  /// Violet – the secondary brand color used in gradients.
  static const Color violet = Color(0xFF7C3AED);

  /// Accent used for PDF icons.
  static const Color pdfRed = Color(0xFFE5484D);

  static const Color _successLight = Color(0xFF16A34A);
  static const Color _successDark = Color(0xFF4ADE80);
  static const Color _warningLight = Color(0xFFD97706);
  static const Color _warningDark = Color(0xFFFBBF24);

  /// Main brand gradient (buttons, user bubbles, logo).
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [indigo, violet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Green used for "online" and "indexed" states.
  static Color success(Brightness b) =>
      b == Brightness.light ? _successLight : _successDark;

  /// Amber used for "processing" states.
  static Color warning(Brightness b) =>
      b == Brightness.light ? _warningLight : _warningDark;

  /// Soft full-page background gradient.
  static LinearGradient backgroundGradient(Brightness b) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: b == Brightness.light
            ? const [Color(0xFFF5F3FF), Color(0xFFFBFAFF), Color(0xFFEEF2FF)]
            : const [Color(0xFF14121F), Color(0xFF0F0E17), Color(0xFF181430)],
      );

  /// Subtle elevation shadow for cards and bubbles.
  static List<BoxShadow> softShadow(Brightness b) => [
        BoxShadow(
          color: b == Brightness.light
              ? indigo.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}
