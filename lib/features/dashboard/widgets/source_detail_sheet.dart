import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/pdf_icon_badge.dart';
import '../../../data/models/source_model.dart';

/// Shows the full text of a source passage.
/// Use [SourceDetailSheet.show]: a bottom sheet on phones, a dialog on
/// wider screens (desktop web, tablets).
class SourceDetailSheet extends StatelessWidget {
  const SourceDetailSheet({
    super.key,
    required this.source,
    this.isDialog = false,
  });

  final SourceModel source;

  /// Dialogs get a close button and top padding; sheets use the drag handle.
  final bool isDialog;

  /// Opens the source in the presentation that fits the screen size.
  static Future<void> show(BuildContext context, SourceModel source) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.8;

    if (Responsive.isCompact(context)) {
      return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        constraints: BoxConstraints(maxHeight: maxHeight),
        builder: (_) => SourceDetailSheet(source: source),
      );
    }

    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppSizes.dialogMaxWidth,
            maxHeight: maxHeight,
          ),
          child: SourceDetailSheet(source: source, isDialog: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.xl,
        isDialog ? AppSizes.xl : 0,
        AppSizes.xl,
        AppSizes.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppSizes.xl),
          Text(AppStrings.excerpt, style: textTheme.labelLarge),
          const SizedBox(height: AppSizes.sm),
          Flexible(child: _buildExcerpt(context)),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Icon(Icons.verified_outlined, size: 16, color: muted),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  AppStrings.sourceFooter,
                  style: textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        const PdfIconBadge(),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                source.document,
                style: textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                AppStrings.page(source.page),
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (isDialog)
          IconButton(
            tooltip: AppStrings.close,
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
      ],
    );
  }

  Widget _buildExcerpt(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: SelectableText(
          source.text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
      ),
    );
  }
}
