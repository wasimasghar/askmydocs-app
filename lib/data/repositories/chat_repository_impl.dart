import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/chat_message_model.dart';
import '../models/source_model.dart';
import 'api_call_guard.dart';
import 'chat_repository.dart';

/// [ChatRepository] backed by `POST /ask`.
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._client);

  final ApiClient _client;

  /// Never send more than this many previous messages.
  static const int maxHistory = 6;

  @override
  Future<ChatMessageModel> ask(
    String question,
    List<ChatMessageModel> history,
  ) {
    return guardApiCall(() async {
      final json = await _client.post(
        ApiEndpoints.ask,
        data: {
          'question': question,
          'history': [
            for (final message in _recent(history))
              {'role': message.role.name, 'content': message.content},
          ],
        },
      ) as Map<String, dynamic>;

      return ChatMessageModel(
        role: MessageRole.assistant,
        content: json['answer'] as String,
        sources: (json['sources'] as List<dynamic>? ?? const [])
            .map((e) => SourceModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.now(),
      );
    });
  }

  static List<ChatMessageModel> _recent(List<ChatMessageModel> history) =>
      history.length <= maxHistory
          ? history
          : history.sublist(history.length - maxHistory);
}
