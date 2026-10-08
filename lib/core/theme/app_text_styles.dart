import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography for AskMyDocs, built on the Inter font.
abstract final class AppTextStyles {
  /// Line height used for chat bubbles and long-form text.
  static const double readingHeight = 1.5;

  /// Returns [base] re-styled with Inter and slightly tighter headings.
  static TextTheme textTheme(TextTheme base) {
    final inter = GoogleFonts.interTextTheme(base);
    return inter.copyWith(
      headlineSmall: inter.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: inter.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: inter.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: inter.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: inter.bodyLarge?.copyWith(
        fontSize: 15,
        height: readingHeight,
      ),
      labelLarge: inter.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
