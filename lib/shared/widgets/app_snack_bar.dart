import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

/// Floating, rounded SnackBars in the app's style.
abstract final class AppSnackBar {
  /// Red-accented message for failures.
  static void showError(BuildContext context, String message) => _show(
        context,
        message,
        icon: Icons.error_outline_rounded,
        iconColor: Theme.of(context).colorScheme.error,
      );

  /// Green-accented message for completed actions.
  static void showSuccess(BuildContext context, String message) => _show(
        context,
        message,
        icon: Icons.check_circle_rounded,
        iconColor: AppColors.success(Theme.of(context).brightness),
      );

  static void _show(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color iconColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: scheme.inverseSurface,
          // A fixed width on phones would push the margins negative.
          width: Responsive.isCompact(context) ? null : AppSizes.dialogMaxWidth,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          content: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: scheme.onInverseSurface),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
