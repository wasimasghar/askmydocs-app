/// Backend routes, relative to `ApiConfig.baseUrl`.
abstract final class ApiEndpoints {
  /// POST a question, get an answer with sources.
  static const String ask = '/ask';

  /// GET server status and indexed chunk count.
  static const String health = '/health';

  /// GET the list of uploaded documents.
  static const String documents = '/documents';

  /// POST a PDF as multipart/form-data (field "file").
  static const String documentsUpload = '/documents/upload';

  /// DELETE one PDF. The name is URL-encoded, so spaces and symbols are safe.
  static String documentDelete(String name) =>
      '/documents/${Uri.encodeComponent(name)}';
}
