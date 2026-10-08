import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import 'assistant_avatar.dart';
import 'chat_message_bubble.dart';

/// Three bouncing dots in an assistant bubble ("assistant is typing").
/// Stateful only to own its looping animation.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  static const _dotCount = 3;
  static const _dotSize = 8.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.assistantTyping,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const AssistantAvatar(),
          const SizedBox(width: AppSizes.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.lg,
              vertical: AppSizes.lg,
            ),
            decoration: ChatMessageBubble.assistantDecoration(context),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_dotCount, _buildDot),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Each dot runs the same bounce, offset in time by its index.
  Widget _buildDot(int index) {
    final phase = (_controller.value - index * 0.2) % 1.0;
    final wave = math.sin(phase * math.pi); // 0 → 1 → 0
    final color = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(left: index == 0 ? 0 : AppSizes.xs + 2),
      child: Transform.translate(
        offset: Offset(0, -4 * wave),
        child: Container(
          width: _dotSize,
          height: _dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.35 + 0.65 * wave),
          ),
        ),
      ),
    );
  }
}
