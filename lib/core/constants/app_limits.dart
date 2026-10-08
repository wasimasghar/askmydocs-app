/// Limits enforced by the backend, mirrored in the UI so users get feedback
/// before uploading. The server still checks them and its errors are shown.
abstract final class AppLimits {
  /// How many PDFs can be kept at once.
  static const int maxDocuments = 3;

  /// Largest PDF the server accepts.
  static const int maxPdfBytes = 10 * 1024 * 1024;
}
