import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/chat_message_model.dart';
import 'assistant_avatar.dart';
import 'sources_section.dart';

/// One chat message. User messages sit on the right in a primary gradient;
/// assistant messages sit on the left on a surface card, with sources below.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessageModel message;

  /// Decoration shared by assistant bubbles and the typing indicator.
  static BoxDecoration assistantDecoration(BuildContext context) {
    return BoxDecoration(
      color: AppTheme.cardColor(context),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppSizes.radius),
        topRight: Radius.circular(AppSizes.radius),
        bottomRight: Radius.circular(AppSizes.radius),
        bottomLeft: Radius.circular(AppSizes.xs),
      ),
      border: Border.all(
        color: Theme.of(context).colorScheme.outlineVariant.withValues(
              alpha: 0.5,
            ),
      ),
      boxShadow: AppColors.softShadow(Theme.of(context).brightness),
    );
  }

  static const BoxDecoration _userDecoration = BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(AppSizes.radius),
      topRight: Radius.circular(AppSizes.radius),
      bottomLeft: Radius.circular(AppSizes.radius),
      bottomRight: Radius.circular(AppSizes.xs),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return LayoutBuilder(
      builder: (context, constraints) => Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const AssistantAvatar(),
            const SizedBox(width: AppSizes.sm),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * AppSizes.bubbleMaxWidthFactor,
              ),
              child: _buildBubble(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final isUser = message.isUser;
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: isUser ? Colors.white : null,
        );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.md,
      ),
      decoration: isUser ? _userDecoration : assistantDecoration(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(message.content, style: textStyle),
          if (message.sources.isNotEmpty)
            SourcesSection(sources: message.sources),
        ],
      ),
    );
  }
}
