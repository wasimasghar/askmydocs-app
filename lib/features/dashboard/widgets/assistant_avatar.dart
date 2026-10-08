import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Small gradient circle shown next to assistant messages.
class AssistantAvatar extends StatelessWidget {
  const AssistantAvatar({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }
}
