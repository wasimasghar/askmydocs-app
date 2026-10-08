import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/document_model.dart';

/// Pill showing a document's processing state: green "Indexed",
/// amber "Processing" or red "Failed".
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final DocumentStatus status;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final (label, icon, color) = switch (status) {
      DocumentStatus.indexed => (
          AppStrings.statusIndexed,
          Icons.check_circle_rounded,
          AppColors.success(brightness),
        ),
      DocumentStatus.processing => (
          AppStrings.statusProcessing,
          Icons.hourglass_top_rounded,
          AppColors.warning(brightness),
        ),
      DocumentStatus.failed => (
          AppStrings.statusFailed,
          Icons.error_rounded,
          Theme.of(context).colorScheme.error,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm + 2,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSizes.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
