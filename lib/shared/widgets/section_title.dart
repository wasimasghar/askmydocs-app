import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

/// Small heading above a group of content, with optional trailing text.
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.xs,
        right: AppSizes.xs,
        bottom: AppSizes.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: textTheme.titleSmall?.copyWith(letterSpacing: 0.2),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: textTheme.bodySmall?.copyWith(color: muted),
            ),
        ],
      ),
    );
  }
}
