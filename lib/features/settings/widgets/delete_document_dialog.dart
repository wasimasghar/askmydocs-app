import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

/// Asks "Delete my_file.pdf? Its chunks will be removed from search."
/// Use [DeleteDocumentDialog.confirm]; it resolves to true only on "Delete".
class DeleteDocumentDialog extends StatelessWidget {
  const DeleteDocumentDialog({super.key, required this.fileName});

  final String fileName;

  /// Shows the dialog and returns whether the user confirmed.
  static Future<bool> confirm(BuildContext context, String fileName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteDocumentDialog(fileName: fileName),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
      title: const Text(AppStrings.deleteDialogTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.dialogMaxWidth),
        child: Text(AppStrings.deleteDialogMessage(fileName)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(AppStrings.delete),
        ),
      ],
    );
  }
}
