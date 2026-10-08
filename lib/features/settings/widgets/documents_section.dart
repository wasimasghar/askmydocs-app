import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../bloc/documents_bloc.dart';
import 'document_list.dart';

/// Picks what to show for the document list: loading, error with retry,
/// or the list itself (which has its own empty state).
///
/// Once documents are loaded they stay visible during a refresh or after a
/// failed refresh; those errors appear as a SnackBar instead.
class DocumentsSection extends StatelessWidget {
  const DocumentsSection({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onDelete,
  });

  final DocumentsState state;
  final VoidCallback onRetry;
  final ValueChanged<String> onDelete;

  static const double _placeholderHeight = 280;

  @override
  Widget build(BuildContext context) {
    final hasNothingYet = state.documents.isEmpty;

    if (hasNothingYet && state.status == DocumentsStatus.error) {
      return AppCard(
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: _placeholderHeight + AppSizes.xxxl,
          child: ErrorView(
            message: state.errorMessage ?? AppStrings.loadDocumentsError,
            onRetry: onRetry,
          ),
        ),
      );
    }

    if (hasNothingYet &&
        (state.isLoading || state.status == DocumentsStatus.initial)) {
      return const AppCard(
        child: SizedBox(
          height: _placeholderHeight,
          child: LoadingView(message: AppStrings.loadingDocuments),
        ),
      );
    }

    return DocumentList(
      documents: state.documents,
      deletingName: state.deletingName,
      canDelete: !state.isBusy,
      onDelete: onDelete,
    );
  }
}
