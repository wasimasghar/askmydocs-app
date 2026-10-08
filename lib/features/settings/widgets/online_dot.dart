import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Small glowing dot: green when online, red when offline.
class OnlineDot extends StatelessWidget {
  const OnlineDot({super.key, required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final color = isOnline
        ? AppColors.success(Theme.of(context).brightness)
        : Theme.of(context).colorScheme.error;

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8),
        ],
      ),
    );
  }
}
