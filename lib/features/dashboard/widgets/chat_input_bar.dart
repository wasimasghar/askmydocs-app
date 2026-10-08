import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

/// Floating rounded input with a send button.
/// Enter sends (web/desktop); Shift+Enter inserts a new line.
/// While [canSend] is false (e.g. waiting for an answer) the user can keep
/// typing but cannot send.
/// Stateful only to own its text controller and focus node.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key, required this.onSend, this.canSend = true});

  /// Called with the trimmed text when the user sends a message.
  final ValueChanged<String> onSend;

  /// False while a previous question is still being answered.
  final bool canSend;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  late final _focusNode = FocusNode(onKeyEvent: _handleKey);

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Enter without Shift sends instead of adding a line break.
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    final isEnter = event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (event is KeyDownEvent &&
        isEnter &&
        !HardwareKeyboard.instance.isShiftPressed) {
      _send();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.canSend) return;
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = Responsive.pagePadding(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, AppSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(context),
            const SizedBox(height: AppSizes.sm),
            Text(
              AppStrings.inputDisclaimer,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.only(left: AppSizes.sm, right: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg + 4),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: AppColors.softShadow(Theme.of(context).brightness),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.send,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _send(),
              decoration: const InputDecoration(
                hintText: AppStrings.inputHint,
                filled: false,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.lg,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: _buildSendButton(),
          ),
        ],
      ),
    );
  }

  /// Enabled only when there is text to send.
  Widget _buildSendButton() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) => IconButton.filled(
        tooltip: AppStrings.send,
        icon: const Icon(Icons.arrow_upward_rounded),
        onPressed:
            value.text.trim().isEmpty || !widget.canSend ? null : _send,
      ),
    );
  }
}
