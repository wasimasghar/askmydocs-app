part of 'documents_bloc.dart';

/// Lifecycle of loading the document list.
enum DocumentsStatus { initial, loading, success, error }

/// Everything the Settings UI needs to render.
final class DocumentsState extends Equatable {
  const DocumentsState({
    this.status = DocumentsStatus.initial,
    this.documents = const [],
    this.isUploading = false,
    this.uploadingFileName,
    this.deletingName,
    this.indexedChunks = 0,
    this.errorMessage,
    this.successMessage,
  });

  final DocumentsStatus status;
  final List<DocumentModel> documents;
  final bool isUploading;

  /// Name of the file being uploaded.
  final String? uploadingFileName;

  /// Name of the document being deleted; only that tile shows a spinner.
  final String? deletingName;
  final int indexedChunks;

  /// Latest error, as text from the server's `detail` where available.
  /// Shown as a full error view when nothing is loaded, otherwise a SnackBar.
  final String? errorMessage;

  /// Set right after a successful upload or delete, for a SnackBar.
  final String? successMessage;

  bool get isLoading => status == DocumentsStatus.loading;

  /// The backend counts as online unless the last load failed.
  bool get isServerOnline => status != DocumentsStatus.error;

  /// An upload or delete is running; other changes wait for it.
  bool get isBusy => isUploading || deletingName != null;

  bool get hasReachedLimit => documents.length >= AppLimits.maxDocuments;

  bool get canUpload => !isBusy && !hasReachedLimit;

  /// Returns a copy.
  ///
  /// - [errorMessage] and [successMessage] are one-shot: cleared unless
  ///   passed again.
  /// - [uploadingFileName] is cleared when the upload finishes.
  /// - [deletingName] is a getter so it can be set back to null:
  ///   `deletingName: () => null`.
  DocumentsState copyWith({
    DocumentsStatus? status,
    List<DocumentModel>? documents,
    bool? isUploading,
    String? uploadingFileName,
    String? Function()? deletingName,
    int? indexedChunks,
    String? errorMessage,
    String? successMessage,
  }) {
    final uploading = isUploading ?? this.isUploading;
    return DocumentsState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      isUploading: uploading,
      uploadingFileName:
          uploading ? uploadingFileName ?? this.uploadingFileName : null,
      deletingName: deletingName != null ? deletingName() : this.deletingName,
      indexedChunks: indexedChunks ?? this.indexedChunks,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        documents,
        isUploading,
        uploadingFileName,
        deletingName,
        indexedChunks,
        errorMessage,
        successMessage,
      ];
}
