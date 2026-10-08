import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/document_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import 'document_tile.dart';

/// Card listing uploaded documents, or an empty state when there are none.
class DocumentList extends StatelessWidget {
  const DocumentList({
    super.key,
    required this.documents,
    required this.onDelete,
    this.deletingName,
    this.canDelete = true,
  });

  final List<DocumentModel> documents;

  /// Called with the document name when its delete button is tapped.
  final ValueChanged<String> onDelete;

  /// The document currently being deleted, if any.
  final String? deletingName;

  /// False while an upload or another delete is running.
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return const AppCard(
        padding: EdgeInsets.all(AppSizes.xl),
        child: EmptyState(
          compact: true,
          icon: Icons.folder_open_rounded,
          title: AppStrings.noDocumentsTitle,
          message: AppStrings.noDocumentsMessage,
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < documents.length; i++) ...[
            if (i > 0)
              const Divider(indent: AppSizes.lg, endIndent: AppSizes.lg),
            DocumentTile(
              key: ValueKey(documents[i].name),
              document: documents[i],
              isDeleting: documents[i].name == deletingName,
              onDelete:
                  canDelete ? () => onDelete(documents[i].name) : null,
            ),
          ],
        ],
      ),
    );
  }
}
