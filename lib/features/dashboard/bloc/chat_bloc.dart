import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/repository_exception.dart';

part 'chat_event.dart';
part 'chat_state.dart';

/// Holds the conversation and talks to the [ChatRepository].
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(const ChatState()) {
    on<ChatQuestionSubmitted>(_onQuestionSubmitted);
    on<ChatRetryRequested>(_onRetryRequested);
    on<ChatCleared>(_onCleared);
  }

  final ChatRepository _chatRepository;

  /// How many previous messages are sent along as context.
  static const int historyLength = 6;

  /// Bumped on "New chat" so late answers to an old chat are ignored.
  int _conversationId = 0;

  Future<void> _onQuestionSubmitted(
    ChatQuestionSubmitted event,
    Emitter<ChatState> emit,
  ) async {
    final question = event.question.trim();
    if (question.isEmpty || state.isLoading) return;

    final history = _lastMessages(state.messages);
    emit(state.copyWith(
      status: ChatStatus.loading,
      messages: [...state.messages, ChatMessageModel.user(question)],
    ));
    await _ask(question, history, emit);
  }

  Future<void> _onRetryRequested(
    ChatRetryRequested event,
    Emitter<ChatState> emit,
  ) async {
    final messages = state.messages;
    if (!state.hasError || messages.isEmpty || !messages.last.isUser) return;

    final question = messages.last.content;
    final history = _lastMessages(messages.sublist(0, messages.length - 1));
    emit(state.copyWith(status: ChatStatus.loading));
    await _ask(question, history, emit);
  }

  void _onCleared(ChatCleared event, Emitter<ChatState> emit) {
    _conversationId++;
    emit(const ChatState());
  }

  /// Calls the repository and appends the answer (or records the error).
  Future<void> _ask(
    String question,
    List<ChatMessageModel> history,
    Emitter<ChatState> emit,
  ) async {
    final conversationId = _conversationId;
    try {
      final answer = await _chatRepository.ask(question, history);
      if (conversationId != _conversationId) return;
      emit(state.copyWith(
        status: ChatStatus.success,
        messages: [...state.messages, answer],
      ));
    } on RepositoryException catch (e) {
      if (conversationId != _conversationId) return;
      emit(state.copyWith(status: ChatStatus.error, errorMessage: e.message));
    } catch (_) {
      if (conversationId != _conversationId) return;
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: AppStrings.genericError,
      ));
    }
  }

  static List<ChatMessageModel> _lastMessages(List<ChatMessageModel> all) =>
      all.length <= historyLength
          ? List.of(all)
          : all.sublist(all.length - historyLength);
}
