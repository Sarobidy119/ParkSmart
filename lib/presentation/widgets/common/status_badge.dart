import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

enum StatusBadgeType { free, inProgress, full, confirmed }

class StatusBadge extends StatelessWidget {
  final StatusBadgeType type;
  final String text;

  const StatusBadge({
    super.key,
    required this.type,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case StatusBadgeType.free:
        bg = AppColors.primaryLight;
        fg = AppColors.primaryDark;
        break;
      case StatusBadgeType.inProgress:
        bg = AppColors.primaryLight;
        fg = AppColors.primaryDark;
        break;
      case StatusBadgeType.full:
        bg = AppColors.redLight;
        fg = AppColors.red;
        break;
      case StatusBadgeType.confirmed:
        bg = AppColors.primaryLight;
        fg = AppColors.primaryDark;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: AppTextStyles.badge.copyWith(color: fg)),
    );
  }
}

