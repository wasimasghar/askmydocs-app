import '../models/document_model.dart';

/// Manages the PDFs in the knowledge base.
///
/// All methods throw a `RepositoryException` with a user-facing message
/// on failure.
abstract class DocumentRepository {
  /// All uploaded documents.
  Future<List<DocumentModel>> getDocuments();

  /// Uploads a PDF and returns it once indexed.
  Future<DocumentModel> uploadPdf(String fileName, List<int> bytes);

  /// Deletes a PDF and its chunks from the index.
  Future<void> deleteDocument(String name);

  /// Total number of chunks in the index.
  Future<int> getIndexedChunks();
}
