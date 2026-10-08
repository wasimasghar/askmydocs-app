import '../../core/network/api_exception.dart';
import 'repository_exception.dart';

const String _unexpectedResponse =
    'The server sent an unexpected response. Please try again.';

/// Runs [call] and converts every failure into a [RepositoryException],
/// which is what the blocs understand.
///
/// - [ApiException] → its friendly message, or [messageFor] when that
///   returns a non-null override (e.g. for a 404).
/// - Malformed JSON (`TypeError`/`FormatException` while parsing) → a
///   generic "unexpected response" message.
Future<T> guardApiCall<T>(
  Future<T> Function() call, {
  String? Function(ApiException error)? messageFor,
}) async {
  try {
    return await call();
  } on ApiException catch (e) {
    throw RepositoryException(messageFor?.call(e) ?? e.message);
  } on RepositoryException {
    rethrow;
  } on TypeError {
    throw const RepositoryException(_unexpectedResponse);
  } on FormatException {
    throw const RepositoryException(_unexpectedResponse);
  }
}
