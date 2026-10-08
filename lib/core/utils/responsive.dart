import 'package:flutter/widgets.dart';

import '../constants/app_sizes.dart';

/// The three layout sizes the app adapts to.
enum ScreenSize {
  /// Under 600px: phones. Bottom navigation bar.
  compact,

  /// 600–899px: small tablets / narrow windows. Navigation rail.
  medium,

  /// 900px and wider: tablets and desktop web. Rail + centered content.
  expanded,
}

/// Single breakpoint helper. Every layout decision goes through here.
abstract final class Responsive {
  /// Maps a width in logical pixels to a [ScreenSize].
  static ScreenSize fromWidth(double width) {
    if (width < AppSizes.compactBreakpoint) return ScreenSize.compact;
    if (width < AppSizes.expandedBreakpoint) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  /// The [ScreenSize] for the current window.
  static ScreenSize of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  /// True on phone-sized layouts.
  static bool isCompact(BuildContext context) =>
      of(context) == ScreenSize.compact;

  /// True when the left navigation rail should be shown.
  static bool useNavigationRail(BuildContext context) => !isCompact(context);

  /// Horizontal page padding for the current size.
  static double pagePadding(BuildContext context) =>
      isCompact(context) ? AppSizes.lg : AppSizes.xl;
}
