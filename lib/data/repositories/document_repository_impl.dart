import 'package:dio/dio.dart' show DioMediaType;

import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/document_model.dart';
import 'api_call_guard.dart';
import 'document_repository.dart';
import 'repository_exception.dart';

/// [DocumentRepository] backed by `/health`, `/documents`,
/// `/documents/upload` and `DELETE /documents/{name}`.
///
/// Server errors (e.g. "You can keep up to 3 PDFs. Delete one first.")
/// reach the user through the response's `detail` field.
///
/// For older servers without the `/documents` routes:
/// - a 404 on the list is treated as "no documents" (the server is still
///   online, so the screen should not show an error);
/// - a 404/405 with no specific detail on upload becomes a clear
///   "not available yet" message.
class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl(this._client);

  final ApiClient _client;

  static const String uploadUnavailable =
      'Upload is not available on the server yet';

  @override
  Future<List<DocumentModel>> getDocuments() {
    return guardApiCall(() async {
      final json = await _fetchDocumentList();
      return json
          .map((e) => _documentFrom(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<DocumentModel> uploadPdf(String fileName, List<int> bytes) {
    return guardApiCall(() async {
      final json = await _client.postMultipart(
        ApiEndpoints.documentsUpload,
        fileName: fileName,
        bytes: bytes,
        contentType: DioMediaType('application', 'pdf'),
        receiveTimeout: ApiConfig.uploadReceiveTimeout,
      ) as Map<String, dynamic>;
      return _documentFrom(json);
    }, messageFor: _uploadMessage);
  }

  @override
  Future<void> deleteDocument(String name) {
    return guardApiCall(() async {
      await _client.delete(ApiEndpoints.documentDelete(name));
    });
  }

  @override
  Future<int> getIndexedChunks() {
    return guardApiCall(() async {
      final json =
          await _client.get(ApiEndpoints.health) as Map<String, dynamic>;
      if (json['status'] != 'ok') {
        throw const RepositoryException('The server is not ready yet.');
      }
      return (json['chunks'] as num?)?.toInt() ?? 0;
    });
  }

  /// The API omits `status`; anything it lists is already indexed.
  static DocumentModel _documentFrom(Map<String, dynamic> json) =>
      DocumentModel.fromJson({'status': 'indexed', ...json});

  /// A missing route answers 404/405 with FastAPI's generic detail; real
  /// upload errors carry their own message, which is kept.
  static String? _uploadMessage(ApiException e) {
    final routeMissing = e.statusCode == 404 || e.statusCode == 405;
    final genericDetail =
        e.message == 'Not Found' || e.message == 'Method Not Allowed';
    return routeMissing && genericDetail ? uploadUnavailable : null;
  }

  /// GET /documents, treating "route not there yet" (404) as an empty list.
  Future<List<dynamic>> _fetchDocumentList() async {
    try {
      return await _client.get(ApiEndpoints.documents) as List<dynamic>;
    } on ApiException catch (e) {
      if (e.isNotFound) return const [];
      rethrow;
    }
  }
}
