import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';

/// Rounded, tappable suggestion shown on the empty chat screen.
class SuggestedQuestionChip extends StatelessWidget {
  const SuggestedQuestionChip({
    super.key,
    required this.question,
    required this.onTap,
  });

  final String question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppSizes.radius);

    return Material(
      color: AppTheme.cardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.md,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  size: 18, color: scheme.primary),
              const SizedBox(width: AppSizes.sm),
              Flexible(
                child: Text(
                  question,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
