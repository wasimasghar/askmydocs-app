import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Tinted rounded square holding a PDF icon.
class PdfIconBadge extends StatelessWidget {
  const PdfIconBadge({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.pdfRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(
        Icons.picture_as_pdf_rounded,
        color: AppColors.pdfRed,
        size: size * 0.52,
      ),
    );
  }
}
