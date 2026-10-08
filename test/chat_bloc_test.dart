import 'package:ask_my_docs/data/models/chat_message_model.dart';
import 'package:ask_my_docs/data/repositories/chat_repository.dart';
import 'package:ask_my_docs/data/repositories/repository_exception.dart';
import 'package:ask_my_docs/features/dashboard/bloc/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers instantly; fails while [fail] is true.
class _FakeChatRepository implements ChatRepository {
  bool fail = false;
  List<ChatMessageModel> lastHistory = const [];

  @override
  Future<ChatMessageModel> ask(
    String question,
    List<ChatMessageModel> history,
  ) async {
    lastHistory = history;
    if (fail) throw const RepositoryException('boom');
    return ChatMessageModel(
      role: MessageRole.assistant,
      content: 'answer to $question',
      createdAt: DateTime(2026),
    );
  }
}

void main() {
  late _FakeChatRepository repository;
  late ChatBloc bloc;

  setUp(() {
    repository = _FakeChatRepository();
    bloc = ChatBloc(chatRepository: repository);
  });

  tearDown(() => bloc.close());

  Future<ChatState> askAndWait(String question) {
    final done = bloc.stream.firstWhere((s) => !s.isLoading);
    bloc.add(ChatQuestionSubmitted(question));
    return done;
  }

  test('adds the question at once, then the answer', () async {
    final states = expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<ChatState>(
          (s) => s.isLoading && s.messages.single.content == 'Hi',
        ),
        predicate<ChatState>(
          (s) =>
              s.status == ChatStatus.success &&
              s.messages.last.content == 'answer to Hi',
        ),
      ]),
    );
    bloc.add(const ChatQuestionSubmitted('Hi'));
    await states;
  });

  test('error keeps the question and retry does not duplicate it', () async {
    repository.fail = true;
    final failed = await askAndWait('Hi');
    expect(failed.status, ChatStatus.error);
    expect(failed.errorMessage, 'boom');
    expect(failed.messages, hasLength(1));

    repository.fail = false;
    final done = bloc.stream.firstWhere((s) => s.status == ChatStatus.success);
    bloc.add(const ChatRetryRequested());
    final retried = await done;
    expect(retried.messages.map((m) => m.content), ['Hi', 'answer to Hi']);
  });

  test('sends at most the last 6 messages as history', () async {
    for (var i = 0; i < 5; i++) {
      await askAndWait('q$i');
    }
    expect(repository.lastHistory, hasLength(ChatBloc.historyLength));
    expect(repository.lastHistory.last.content, 'answer to q3');
  });

  test('ChatCleared empties the conversation', () async {
    await askAndWait('Hi');
    final cleared = bloc.stream.first;
    bloc.add(const ChatCleared());
    expect(await cleared, const ChatState());
  });

  test('ChatMessageModel survives a JSON round trip', () {
    final message = ChatMessageModel(
      role: MessageRole.user,
      content: 'Hello',
      createdAt: DateTime.utc(2026, 10, 8),
    );
    expect(ChatMessageModel.fromJson(message.toJson()), message);
  });
}
