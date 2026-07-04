import 'package:flutter/material.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';

class LocationSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const LocationSearchBar({
    super.key,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final hintColor = isDark ? AppColors.textHintDark : AppColors.textHintLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.bodyMedium.copyWith(color: textColor),
        decoration: InputDecoration(
          hintText: 'Search locations',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: hintColor),
          prefixIcon: Icon(
            Icons.search,
            color: hintColor,
            size: 20,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        ),
      ),
    );
  }
}