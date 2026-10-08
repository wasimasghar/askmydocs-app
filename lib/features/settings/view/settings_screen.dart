import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_limits.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/pdf_picker.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/section_title.dart';
import '../bloc/documents_bloc.dart';
import '../widgets/delete_document_dialog.dart';
import '../widgets/documents_section.dart';
import '../widgets/server_status_card.dart';
import '../widgets/upload_pdf_card.dart';

/// Settings screen: server status, PDF upload and the document list with
/// delete, driven by [DocumentsBloc]. Documents are loaded when the tab is
/// opened (see `AppShell`).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Lets the user pick a PDF, checks its size, and hands it to the bloc.
  Future<void> _pickAndUpload(BuildContext context) async {
    final bloc = context.read<DocumentsBloc>();
    final PickedPdf? pdf;
    try {
      pdf = await PdfPicker.pick();
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.showError(context, AppStrings.filePickerError);
      }
      return;
    }
    if (pdf == null) return; // Cancelled.

    if (pdf.bytes.length > AppLimits.maxPdfBytes) {
      if (context.mounted) {
        AppSnackBar.showError(context, AppStrings.fileTooLarge);
      }
      return;
    }
    bloc.add(DocumentUploadRequested(fileName: pdf.name, bytes: pdf.bytes));
  }

  /// Confirms with the user, then asks the bloc to delete.
  Future<void> _confirmAndDelete(BuildContext context, String name) async {
    final bloc = context.read<DocumentsBloc>();
    final confirmed = await DeleteDocumentDialog.confirm(context, name);
    if (confirmed) bloc.add(DocumentDeleteRequested(name));
  }

  void _showMessages(BuildContext context, DocumentsState state) {
    final success = state.successMessage;
    if (success != null) {
      AppSnackBar.showSuccess(context, success);
      return;
    }
    final error = state.errorMessage;
    if (error == null) return;

    // A failed first load is already shown by the full error view.
    final shownByErrorView =
        state.status == DocumentsStatus.error && state.documents.isEmpty;
    if (!shownByErrorView) AppSnackBar.showError(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = Responsive.pagePadding(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        titleSpacing: horizontal,
        title: const Text(AppStrings.settingsTitle),
      ),
      body: BlocConsumer<DocumentsBloc, DocumentsState>(
        listenWhen: (previous, current) =>
            current.errorMessage != previous.errorMessage ||
            current.successMessage != previous.successMessage,
        listener: _showMessages,
        builder: (context, state) => ListView(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            AppSizes.sm,
            horizontal,
            AppSizes.xxl,
          ),
          children: [
            const SectionTitle(title: AppStrings.sectionServer),
            ServerStatusCard(
              isOnline: state.isServerOnline,
              indexedChunks: state.indexedChunks,
              isChecking: state.documents.isEmpty &&
                  (state.isLoading ||
                      state.status == DocumentsStatus.initial),
            ),
            const SizedBox(height: AppSizes.xl),
            const SectionTitle(title: AppStrings.sectionUpload),
            UploadPdfCard(
              onUpload: () => _pickAndUpload(context),
              documentCount: state.documents.length,
              maxDocuments: AppLimits.maxDocuments,
              isUploading: state.isUploading,
              uploadingFileName: state.uploadingFileName,
              // Only blocked while another upload/delete runs. The 3-PDF
              // limit is handled inside the card, and the server enforces
              // it too if the list couldn't be loaded.
              isEnabled: !state.isBusy,
            ),
            const SizedBox(height: AppSizes.xl),
            const SectionTitle(title: AppStrings.sectionDocuments),
            DocumentsSection(
              state: state,
              onRetry: () => context
                  .read<DocumentsBloc>()
                  .add(const DocumentsRequested()),
              onDelete: (name) => _confirmAndDelete(context, name),
            ),
          ],
        ),
      ),
    );
  }
}
