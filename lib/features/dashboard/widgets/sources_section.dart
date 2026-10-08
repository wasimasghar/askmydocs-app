import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/source_model.dart';
import 'source_chip.dart';

/// Collapsible "Sources (n)" row under an assistant answer.
/// Expands to show one [SourceChip] per referenced passage.
class SourcesSection extends StatelessWidget {
  const SourcesSection({super.key, required this.sources});

  final List<SourceModel> sources;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          ExpansionTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: AppSizes.xs),
            shape: const Border(),
            collapsedShape: const Border(),
            iconColor: primary,
            collapsedIconColor: primary,
            expandedAlignment: Alignment.centerLeft,
            leading: Icon(Icons.menu_book_rounded, size: 18, color: primary),
            title: Text(
              '${AppStrings.sources} (${sources.length})',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: primary),
            ),
            children: [
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: [
                  for (final source in sources) SourceChip(source: source),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
