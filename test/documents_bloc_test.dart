import 'package:ask_my_docs/data/models/document_model.dart';
import 'package:ask_my_docs/data/repositories/document_repository.dart';
import 'package:ask_my_docs/data/repositories/repository_exception.dart';
import 'package:ask_my_docs/features/settings/bloc/documents_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory repository that answers instantly and counts reloads.
class _FakeDocumentRepository implements DocumentRepository {
  bool failLoad = false;
  String? uploadError;
  String? deleteError;
  int loadCount = 0;

  final List<DocumentModel> documents = [
    const DocumentModel(name: 'a.pdf', pages: 2, chunks: 10),
  ];

  @override
  Future<List<DocumentModel>> getDocuments() async {
    loadCount++;
    if (failLoad) throw const RepositoryException('offline');
    return List.of(documents);
  }

  @override
  Future<DocumentModel> uploadPdf(String fileName, List<int> bytes) async {
    if (uploadError != null) throw RepositoryException(uploadError!);
    final doc = DocumentModel(name: fileName, pages: 1, chunks: 5);
    documents.add(doc);
    return doc;
  }

  @override
  Future<void> deleteDocument(String name) async {
    if (deleteError != null) throw RepositoryException(deleteError!);
    documents.removeWhere((d) => d.name == name);
  }

  @override
  Future<int> getIndexedChunks() async =>
      documents.fold<int>(0, (sum, d) => sum + d.chunks);
}

void main() {
  late _FakeDocumentRepository repository;
  late DocumentsBloc bloc;

  setUp(() {
    repository = _FakeDocumentRepository();
    bloc = DocumentsBloc(documentRepository: repository);
  });

  tearDown(() => bloc.close());

  Future<DocumentsState> loadAndWait() {
    final done = bloc.stream.firstWhere((s) => !s.isLoading);
    bloc.add(const DocumentsRequested());
    return done;
  }

  /// Adds [event] and returns the first idle state after it went busy.
  /// Subscribes before adding, so no state can be missed.
  Future<DocumentsState> addAndWaitUntilIdle(DocumentsEvent event) {
    var sawBusy = false;
    final done = bloc.stream.firstWhere((s) {
      if (s.isBusy) sawBusy = true;
      return sawBusy && !s.isBusy;
    });
    bloc.add(event);
    return done;
  }

  test('loads documents and chunk count', () async {
    final state = await loadAndWait();
    expect(state.status, DocumentsStatus.success);
    expect(state.documents, hasLength(1));
    expect(state.indexedChunks, 10);
  });

  test('load failure sets error status and message', () async {
    repository.failLoad = true;
    final state = await loadAndWait();
    expect(state.status, DocumentsStatus.error);
    expect(state.errorMessage, 'offline');
    expect(state.isServerOnline, isFalse);
  });

  test('upload shows progress, then reloads list and chunks', () async {
    await loadAndWait();
    final loadsBefore = repository.loadCount;

    final states = expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<DocumentsState>(
          (s) => s.isUploading && s.uploadingFileName == 'b.pdf',
        ),
        predicate<DocumentsState>(
          (s) =>
              !s.isUploading &&
              s.uploadingFileName == null &&
              s.documents.map((d) => d.name).join(',') == 'a.pdf,b.pdf' &&
              s.indexedChunks == 15 &&
              s.successMessage == 'b.pdf uploaded and indexed',
        ),
      ]),
    );
    bloc.add(const DocumentUploadRequested(fileName: 'b.pdf', bytes: [1]));
    await states;
    expect(repository.loadCount, loadsBefore + 1);
  });

  test('upload error shows the server detail and keeps the list', () async {
    await loadAndWait();
    repository.uploadError = 'You can keep up to 3 PDFs. Delete one first.';

    final state = await addAndWaitUntilIdle(
      const DocumentUploadRequested(fileName: 'b.pdf', bytes: [1]),
    );

    expect(state.errorMessage, 'You can keep up to 3 PDFs. Delete one first.');
    expect(state.documents, hasLength(1));
    expect(state.status, DocumentsStatus.success);
  });

  test('delete marks only that tile, then reloads', () async {
    await loadAndWait();

    final states = expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<DocumentsState>((s) => s.deletingName == 'a.pdf'),
        predicate<DocumentsState>(
          (s) =>
              s.deletingName == null &&
              s.documents.isEmpty &&
              s.indexedChunks == 0 &&
              s.successMessage == 'a.pdf deleted',
        ),
      ]),
    );
    bloc.add(const DocumentDeleteRequested('a.pdf'));
    await states;
  });

  test('delete error shows the detail and clears the spinner', () async {
    await loadAndWait();
    repository.deleteError = 'Document not found.';

    final state =
        await addAndWaitUntilIdle(const DocumentDeleteRequested('a.pdf'));

    expect(state.deletingName, isNull);
    expect(state.errorMessage, 'Document not found.');
  });

  test('limit: canUpload is false with 3 documents', () async {
    repository.documents.addAll(const [
      DocumentModel(name: 'b.pdf', pages: 1, chunks: 1),
      DocumentModel(name: 'c.pdf', pages: 1, chunks: 1),
    ]);
    final state = await loadAndWait();
    expect(state.hasReachedLimit, isTrue);
    expect(state.canUpload, isFalse);
  });
}
