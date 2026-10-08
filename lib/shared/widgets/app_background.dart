import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Paints the soft brand gradient behind every screen.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient(Theme.of(context).brightness),
      ),
      child: child,
    );
  }
}
