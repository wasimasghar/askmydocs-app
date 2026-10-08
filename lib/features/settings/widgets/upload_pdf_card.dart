import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/dashed_border.dart';
import '../../../shared/widgets/pdf_icon_badge.dart';
import '../../../shared/widgets/primary_button.dart';

/// Dashed drop-zone style card with a PDF icon, a "2 / 3 PDFs" counter and
/// an "Upload PDF" button.
///
/// The button is disabled while [isUploading] (a progress bar shows) and
/// when the limit is reached (a hint explains what to do).
class UploadPdfCard extends StatelessWidget {
  const UploadPdfCard({
    super.key,
    required this.onUpload,
    required this.documentCount,
    required this.maxDocuments,
    this.isUploading = false,
    this.uploadingFileName,
    this.isEnabled = true,
  });

  final VoidCallback onUpload;
  final int documentCount;
  final int maxDocuments;
  final bool isUploading;
  final String? uploadingFileName;

  /// False while another change (e.g. a delete) is running.
  final bool isEnabled;

  bool get _isFull => documentCount >= maxDocuments;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canUpload = isEnabled && !isUploading && !_isFull;

    return DashedBorder(
      color: scheme.primary.withValues(alpha: 0.45),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.xl,
          vertical: AppSizes.xxl,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.indigo.withValues(alpha: 0.06),
              AppColors.violet.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: Column(
          children: [
            const PdfIconBadge(size: 56),
            const SizedBox(height: AppSizes.md),
            _buildCounter(context),
            const SizedBox(height: AppSizes.md),
            Text(AppStrings.uploadTitle, style: textTheme.titleMedium),
            const SizedBox(height: AppSizes.xs),
            Text(
              AppStrings.uploadMessage,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            PrimaryButton(
              label: AppStrings.uploadButton,
              icon: Icons.upload_file_rounded,
              onPressed: canUpload ? onUpload : null,
            ),
            const SizedBox(height: AppSizes.md),
            if (isUploading) _buildProgress(context) else _buildHint(context),
          ],
        ),
      ),
    );
  }

  /// "2 / 3 PDFs" pill; amber once the limit is reached.
  Widget _buildCounter(BuildContext context) {
    final color = _isFull
        ? AppColors.warning(Theme.of(context).brightness)
        : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        AppStrings.pdfCounter(documentCount, maxDocuments),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildHint(BuildContext context) {
    final full = _isFull;
    final color = full
        ? AppColors.warning(Theme.of(context).brightness)
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (full) ...[
          Icon(Icons.info_outline_rounded, size: 16, color: color),
          const SizedBox(width: AppSizes.xs),
        ],
        Flexible(
          child: Text(
            full ? AppStrings.uploadLimitReached : AppStrings.uploadHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
          ),
        ),
      ],
    );
  }

  /// Indeterminate bar, "Uploading and indexing..." and the file name.
  Widget _buildProgress(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        children: [
          const ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusPill)),
            child: LinearProgressIndicator(minHeight: 6),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            AppStrings.uploadInProgress,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: muted),
          ),
          if (uploadingFileName != null)
            Text(
              uploadingFileName!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium,
            ),
        ],
      ),
    );
  }
}
