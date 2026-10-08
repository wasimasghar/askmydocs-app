import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/app_logo.dart';

/// App bar with the logo, title, tagline and a "New chat" action.
/// The action is an icon on phones and a labelled button on wider screens.
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key, required this.onNewChat});

  final VoidCallback onNewChat;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isCompact = Responsive.isCompact(context);

    return AppBar(
      titleSpacing: Responsive.pagePadding(context),
      title: Row(
        children: [
          if (isCompact) ...[
            const AppLogo(size: 34),
            const SizedBox(width: AppSizes.md),
          ],
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(AppStrings.appName),
              Text(
                AppStrings.appTagline,
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: Responsive.pagePadding(context)),
          child: isCompact
              ? IconButton.filledTonal(
                  tooltip: AppStrings.newChat,
                  icon: const Icon(Icons.add_comment_outlined),
                  onPressed: onNewChat,
                )
              : FilledButton.tonalIcon(
                  icon: const Icon(Icons.add_comment_outlined, size: 18),
                  label: const Text(AppStrings.newChat),
                  onPressed: onNewChat,
                ),
        ),
      ],
    );
  }
}
