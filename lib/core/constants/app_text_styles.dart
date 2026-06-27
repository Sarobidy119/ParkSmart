import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  // Approximation of the HTML Tailwind typography scales.
  // All text styles should use Inter.

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 13,
    height: 20.8 / 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.02,
    color: AppColors.textPrimary,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 10,
    height: 12 / 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Auth button label sizes in HTML sometimes use h2.
  static const TextStyle micro = TextStyle(
    fontSize: 9,
    height: 12 / 9,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}

