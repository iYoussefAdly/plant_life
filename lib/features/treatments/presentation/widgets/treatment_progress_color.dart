import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

Color treatmentProgressColor(double progress) {
  if (progress >= 1.0) return AppColors.success;
  if (progress >= 0.5) return AppColors.primary;
  if (progress > 0) return AppColors.warning;
  return AppColors.textHint;
}
