import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_limits.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/document_model.dart';
import '../../../data/repositories/document_repository.dart';
import '../../../data/repositories/repository_exception.dart';

part 'documents_event.dart';
part 'documents_state.dart';

/// Loads the document list and handles PDF upload and delete.
///
/// After every successful upload or delete the list and chunk count are
/// reloaded from the server, so the screen always matches the backend.
class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  DocumentsBloc({required DocumentRepository documentRepository})
      : _documentRepository = documentRepository,
        super(const DocumentsState()) {
    on<DocumentsRequested>(_onRequested);
    on<DocumentUploadRequested>(_onUploadRequested);
    on<DocumentDeleteRequested>(_onDeleteRequested);
  }

  final DocumentRepository _documentRepository;

  Future<void> _onRequested(
    DocumentsRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: DocumentsStatus.loading));

    try {
      final (documents, chunks) = await _fetch();
      emit(state.copyWith(
        status: DocumentsStatus.success,
        documents: documents,
        indexedChunks: chunks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DocumentsStatus.error,
        errorMessage: _messageFor(e),
      ));
    }
  }

  Future<void> _onUploadRequested(
    DocumentUploadRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    if (state.isBusy) return;
    emit(state.copyWith(isUploading: true, uploadingFileName: event.fileName));

    final DocumentModel uploaded;
    try {
      uploaded =
          await _documentRepository.uploadPdf(event.fileName, event.bytes);
    } catch (e) {
      emit(state.copyWith(isUploading: false, errorMessage: _messageFor(e)));
      return;
    }

    await _reloadAfterChange(
      emit,
      successMessage: AppStrings.uploaded(uploaded.name),
      fallback: [
        ...state.documents.where((d) => d.name != uploaded.name),
        uploaded,
      ],
    );
  }

  Future<void> _onDeleteRequested(
    DocumentDeleteRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    if (state.isBusy) return;
    emit(state.copyWith(deletingName: () => event.name));

    try {
      await _documentRepository.deleteDocument(event.name);
    } catch (e) {
      emit(state.copyWith(
        deletingName: () => null,
        errorMessage: _messageFor(e),
      ));
      // E.g. "Document not found.": the list may be stale, so refresh it.
      await _quietReload(emit);
      return;
    }

    await _reloadAfterChange(
      emit,
      successMessage: AppStrings.deleted(event.name),
      fallback: state.documents.where((d) => d.name != event.name).toList(),
    );
  }

  /// Reloads list and chunk count after a successful change. If the reload
  /// itself fails, the change still succeeded, so [fallback] is shown.
  Future<void> _reloadAfterChange(
    Emitter<DocumentsState> emit, {
    required String successMessage,
    required List<DocumentModel> fallback,
  }) async {
    List<DocumentModel> documents = fallback;
    int? chunks;
    try {
      (documents, chunks) = await _fetch();
    } catch (_) {
      // Keep the locally updated list; the chunk count stays as it was.
    }
    emit(state.copyWith(
      status: DocumentsStatus.success,
      documents: documents,
      indexedChunks: chunks,
      isUploading: false,
      deletingName: () => null,
      successMessage: successMessage,
    ));
  }

  /// Refreshes the list without surfacing a second error.
  Future<void> _quietReload(Emitter<DocumentsState> emit) async {
    try {
      final (documents, chunks) = await _fetch();
      emit(state.copyWith(documents: documents, indexedChunks: chunks));
    } catch (_) {}
  }

  Future<(List<DocumentModel>, int)> _fetch() async {
    final documents = await _documentRepository.getDocuments();
    final chunks = await _documentRepository.getIndexedChunks();
    return (documents, chunks);
  }

  static String _messageFor(Object error) =>
      error is RepositoryException ? error.message : AppStrings.genericError;
}
