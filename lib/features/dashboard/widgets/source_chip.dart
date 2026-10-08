import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/source_model.dart';
import 'source_detail_sheet.dart';

/// Chip like "my_file.pdf · p.3" that opens the source text when tapped.
class SourceChip extends StatelessWidget {
  const SourceChip({super.key, required this.source});

  final SourceModel source;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(
        Icons.picture_as_pdf_rounded,
        size: 16,
        color: AppColors.pdfRed,
      ),
      label: Text(source.label),
      tooltip: AppStrings.viewSource,
      onPressed: () => SourceDetailSheet.show(context, source),
    );
  }
}
