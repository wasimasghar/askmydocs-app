import 'dart:math';

import '../../core/constants/app_limits.dart';
import '../models/document_model.dart';
import 'document_repository.dart';
import 'repository_exception.dart';

/// Fake [DocumentRepository] for UI development and tests without a server.
///
/// Keeps documents in memory, waits 1–2 seconds per call, applies the same
/// rules and messages as the real backend (PDF only, max 3 files, max
/// 10 MB, no duplicates) and fails now and then so error states can be seen.
class MockDocumentRepository implements DocumentRepository {
  MockDocumentRepository({Random? random, this.failureRate = 0.1})
      : _random = random ?? Random();

  final Random _random;

  /// Chance that any call fails with a network-style error.
  final double failureRate;

  final List<DocumentModel> _documents = [
    const DocumentModel(name: 'terms_of_service.pdf', pages: 18, chunks: 182),
    const DocumentModel(name: 'customer_handbook.pdf', pages: 24, chunks: 141),
  ];

  Future<void> _delay() => Future<void>.delayed(
        Duration(milliseconds: 1000 + _random.nextInt(1000)),
      );

  void _maybeFail() {
    if (_random.nextDouble() < failureRate) {
      throw const RepositoryException('Could not reach the server.');
    }
  }

  @override
  Future<List<DocumentModel>> getDocuments() async {
    await _delay();
    _maybeFail();
    return List.unmodifiable(_documents);
  }

  @override
  Future<DocumentModel> uploadPdf(String fileName, List<int> bytes) async {
    await _delay();
    _maybeFail();
    if (!fileName.toLowerCase().endsWith('.pdf')) {
      throw const RepositoryException('Only PDF files are allowed.');
    }
    if (_documents.length >= AppLimits.maxDocuments) {
      throw const RepositoryException(
        'You can keep up to 3 PDFs. Delete one first.',
      );
    }
    if (bytes.length > AppLimits.maxPdfBytes) {
      throw const RepositoryException('PDF must be under 10 MB.');
    }
    if (_documents.any((d) => d.name == fileName)) {
      throw RepositoryException('$fileName is already uploaded.');
    }

    // Rough fake numbers: ~50 KB per page, ~8 chunks per page.
    final pages = max(1, bytes.length ~/ 50000);
    final document = DocumentModel(
      name: fileName,
      pages: pages,
      chunks: pages * 8 + _random.nextInt(8),
    );
    _documents.add(document);
    return document;
  }

  @override
  Future<void> deleteDocument(String name) async {
    await _delay();
    _maybeFail();
    final before = _documents.length;
    _documents.removeWhere((d) => d.name == name);
    if (_documents.length == before) {
      throw const RepositoryException('Document not found.');
    }
  }

  @override
  Future<int> getIndexedChunks() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _documents
        .where((d) => d.status == DocumentStatus.indexed)
        .fold<int>(0, (sum, d) => sum + d.chunks);
  }
}
