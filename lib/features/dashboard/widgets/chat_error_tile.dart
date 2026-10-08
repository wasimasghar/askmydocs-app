import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import 'assistant_avatar.dart';

/// Inline error shown where the answer would appear, with a retry button.
class ChatErrorTile extends StatelessWidget {
  const ChatErrorTile({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const AssistantAvatar(),
        const SizedBox(width: AppSizes.sm),
        Flexible(
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.sm,
              AppSizes.xs,
              AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: scheme.errorContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppSizes.radius),
              border: Border.all(color: scheme.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 20, color: scheme.error),
                const SizedBox(width: AppSizes.sm),
                Flexible(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onErrorContainer,
                        ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(AppStrings.retry),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
