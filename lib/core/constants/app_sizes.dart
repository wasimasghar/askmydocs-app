/// Spacing, radius and layout constants used across the app.
abstract final class AppSizes {
  // Spacing scale.
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Corner radii.
  static const double radius = 16;
  static const double radiusSm = 12;
  static const double radiusLg = 24;
  static const double radiusPill = 999;

  // Layout.
  static const double compactBreakpoint = 600;
  static const double expandedBreakpoint = 900;
  static const double maxContentWidth = 900;
  static const double dialogMaxWidth = 560;
  static const double toolbarHeight = 64;

  /// Bubbles never take more than this fraction of the chat width.
  static const double bubbleMaxWidthFactor = 0.8;
}
