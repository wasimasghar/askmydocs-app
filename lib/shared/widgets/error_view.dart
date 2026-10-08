import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import 'empty_state.dart';
import 'primary_button.dart';

/// Centered error message with an optional "Try again" button.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: EmptyState(
          icon: Icons.cloud_off_rounded,
          title: AppStrings.errorTitle,
          message: message,
          child: onRetry == null
              ? null
              : PrimaryButton(
                  label: AppStrings.retry,
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                ),
        ),
      ),
    );
  }
}
