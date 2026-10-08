import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/empty_chat_view.dart';

/// Chat screen. Composes the app bar, the conversation (driven by
/// [ChatBloc]) and the input bar.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ChatBloc>();
    void ask(String question) => bloc.add(ChatQuestionSubmitted(question));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: DashboardAppBar(onNewChat: () => bloc.add(const ChatCleared())),
      body: BlocListener<ChatBloc, ChatState>(
        listenWhen: (previous, current) =>
            current.hasError && !previous.hasError,
        listener: (context, state) => AppSnackBar.showError(
          context,
          state.errorMessage ?? AppStrings.genericError,
        ),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) => state.messages.isEmpty
                    ? EmptyChatView(
                        suggestions: AppStrings.suggestedQuestions,
                        onSuggestionTap: ask,
                      )
                    : ChatMessageList(
                        messages: state.messages,
                        isTyping: state.isLoading,
                        errorMessage: state.hasError
                            ? state.errorMessage ?? AppStrings.genericError
                            : null,
                        onRetry: () => bloc.add(const ChatRetryRequested()),
                      ),
              ),
            ),
            BlocSelector<ChatBloc, ChatState, bool>(
              selector: (state) => !state.isLoading,
              builder: (context, canSend) =>
                  ChatInputBar(onSend: ask, canSend: canSend),
            ),
          ],
        ),
      ),
    );
  }
}
