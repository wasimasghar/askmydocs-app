import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_card.dart';
import 'online_dot.dart';

/// Card showing backend health: online dot and indexed chunk count.
class ServerStatusCard extends StatelessWidget {
  const ServerStatusCard({
    super.key,
    required this.isOnline,
    required this.indexedChunks,
    this.isChecking = false,
  });

  final bool isOnline;
  final int indexedChunks;

  /// True on first load, before anything is known.
  final bool isChecking;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(Icons.dns_rounded, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(width: AppSizes.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.serverStatusTitle, style: textTheme.titleMedium),
                const SizedBox(height: AppSizes.xs),
                Row(
                  children: [
                    if (isChecking)
                      const SizedBox.square(
                        dimension: 10,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      OnlineDot(isOnline: isOnline),
                    const SizedBox(width: AppSizes.sm),
                    Flexible(
                      child: Text(_statusLine, style: textTheme.bodyMedium),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _statusLine {
    if (isChecking) return AppStrings.checkingServer;
    if (!isOnline) return AppStrings.offline;
    return '${AppStrings.online} · ${AppStrings.chunksIndexed(indexedChunks)}';
  }
}
