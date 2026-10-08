part of 'chat_bloc.dart';

/// Base class for everything the chat UI can ask the [ChatBloc] to do.
sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// The user sent a question (typed or from a suggestion chip).
final class ChatQuestionSubmitted extends ChatEvent {
  const ChatQuestionSubmitted(this.question);

  final String question;

  @override
  List<Object?> get props => [question];
}

/// The user tapped "Try again" after a failed answer.
/// Re-asks the last question without adding it twice.
final class ChatRetryRequested extends ChatEvent {
  const ChatRetryRequested();
}

/// The user started a new chat.
final class ChatCleared extends ChatEvent {
  const ChatCleared();
}
