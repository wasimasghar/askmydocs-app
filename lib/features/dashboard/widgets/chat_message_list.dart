import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/chat_message_model.dart';
import 'chat_error_tile.dart';
import 'chat_message_bubble.dart';
import 'typing_indicator.dart';

/// Scrollable list of chat bubbles. The last row is a typing indicator while
/// waiting, or an error tile with retry when the answer failed.
///
/// The list is reversed so it stays pinned to the newest message.
class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    this.isTyping = false,
    this.errorMessage,
    this.onRetry,
  });

  final List<ChatMessageModel> messages;
  final bool isTyping;

  /// When set, an error tile is shown after the last message.
  final String? errorMessage;
  final VoidCallback? onRetry;

  bool get _hasFooter => isTyping || errorMessage != null;

  @override
  Widget build(BuildContext context) {
    final horizontal = Responsive.pagePadding(context);
    final itemCount = messages.length + (_hasFooter ? 1 : 0);

    return ListView.separated(
      reverse: true,
      padding: EdgeInsets.fromLTRB(
        horizontal,
        AppSizes.lg,
        horizontal,
        AppSizes.sm,
      ),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSizes.lg),
      itemBuilder: (_, index) => _buildItem(itemCount - 1 - index),
    );
  }

  /// [position] counts from the oldest message (0) to the newest row.
  Widget _buildItem(int position) {
    if (position < messages.length) {
      final message = messages[position];
      return ChatMessageBubble(key: ObjectKey(message), message: message);
    }
    if (isTyping) return const TypingIndicator();
    return ChatErrorTile(message: errorMessage!, onRetry: onRetry ?? () {});
  }
}
