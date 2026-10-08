import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/empty_state.dart';
import 'suggested_question_chip.dart';

/// Welcome screen for a fresh chat: illustration, intro and suggestions.
class EmptyChatView extends StatelessWidget {
  const EmptyChatView({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: EmptyState(
          icon: Icons.forum_rounded,
          title: AppStrings.emptyTitle,
          message: AppStrings.emptyMessage,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              for (final question in suggestions)
                SuggestedQuestionChip(
                  question: question,
                  onTap: () => onSuggestionTap(question),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
