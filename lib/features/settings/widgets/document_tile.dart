import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/document_model.dart';
import '../../../shared/widgets/pdf_icon_badge.dart';
import 'status_chip.dart';

/// One uploaded PDF: icon, file name, pages/chunks, status chip and a
/// delete button. While [isDeleting], the button becomes a small spinner.
class DocumentTile extends StatelessWidget {
  const DocumentTile({
    super.key,
    required this.document,
    this.onDelete,
    this.isDeleting = false,
  });

  final DocumentModel document;

  /// Null disables the button (e.g. while another change is running).
  final VoidCallback? onDelete;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDeleting ? 0.55 : 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.lg,
          AppSizes.sm,
          AppSizes.lg,
        ),
        child: Row(
          children: [
            const PdfIconBadge(),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.name,
                    style: textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    AppStrings.documentMeta(document.pages, document.chunks),
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            StatusChip(status: document.status),
            const SizedBox(width: AppSizes.xs),
            _buildDeleteAction(context),
          ],
        ),
      ),
    );
  }

  /// Fixed 48px square so the row doesn't jump when the spinner appears.
  Widget _buildDeleteAction(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: isDeleting
          ? const Center(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          : IconButton(
              tooltip: AppStrings.deleteTooltip,
              icon: const Icon(Icons.delete_outline_rounded),
              color: Theme.of(context).colorScheme.error,
              onPressed: onDelete,
            ),
    );
  }
}
