import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';

/// Friendly placeholder: gradient illustration icon, title, message and an
/// optional [child] (e.g. buttons or suggestion chips) underneath.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.child,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? child;

  /// Smaller illustration and title, for use inside cards.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIllustration(context),
        SizedBox(height: compact ? AppSizes.lg : AppSizes.xl),
        Text(
          title,
          textAlign: TextAlign.center,
          style: compact ? textTheme.titleMedium : textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSizes.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: mutedColor),
          ),
        ),
        if (child != null) ...[
          SizedBox(height: compact ? AppSizes.lg : AppSizes.xxl),
          child!,
        ],
      ],
    );
  }

  /// A gradient disc inside a soft halo.
  Widget _buildIllustration(BuildContext context) {
    final inner = compact ? 56.0 : 88.0;
    final halo = inner * 1.45;

    return Container(
      width: halo,
      height: halo,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.violet.withValues(alpha: 0.10),
      ),
      child: Container(
        width: inner,
        height: inner,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.indigo.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: inner * 0.48),
      ),
    );
  }
}
