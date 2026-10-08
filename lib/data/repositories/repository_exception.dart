/// Error thrown by repositories with a message that is safe to show users.
class RepositoryException implements Exception {
  const RepositoryException(this.message);

  final String message;

  @override
  String toString() => 'RepositoryException: $message';
}
