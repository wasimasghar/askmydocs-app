part of 'chat_bloc.dart';

/// Lifecycle of the latest question.
enum ChatStatus { initial, loading, success, error }

/// Everything the chat UI needs to render.
final class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
  });

  final ChatStatus status;
  final List<ChatMessageModel> messages;

  /// Set only while [status] is [ChatStatus.error].
  final String? errorMessage;

  bool get isLoading => status == ChatStatus.loading;
  bool get hasError => status == ChatStatus.error;

  /// Returns a copy. [errorMessage] is not carried over: pass it to keep it.
  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessageModel>? messages,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, messages, errorMessage];
}
