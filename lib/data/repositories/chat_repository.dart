import '../models/chat_message_model.dart';

/// Answers questions about the uploaded documents.
abstract class ChatRepository {
  /// Sends [question] with recent [history] and returns the assistant reply.
  /// Throws a `RepositoryException` on failure.
  Future<ChatMessageModel> ask(
    String question,
    List<ChatMessageModel> history,
  );
}
