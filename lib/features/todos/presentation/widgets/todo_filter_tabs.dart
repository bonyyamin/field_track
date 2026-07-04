import 'package:flutter/material.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';
import '../bloc/todo_event.dart';

/// Pill filter selector tabs ("All", "Pending", "Completed") matching design.
class TodoFilterTabs extends StatelessWidget {
  final TodoFilter current;
  final ValueChanged<TodoFilter> onChanged;

  const TodoFilterTabs({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeBg = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final activeText = isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight;

    final inactiveBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final inactiveBorder = isDark ? AppColors.borderDark : AppColors.borderLight;
    final inactiveText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Row(
      children: TodoFilter.values.map((filter) {
        final isSelected = filter == current;

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => onChanged(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? activeBg : inactiveBg,
                borderRadius: BorderRadius.circular(24),
                border: isSelected
                    ? null
                    : Border.all(color: inactiveBorder, width: 1.0),
              ),
              child: Text(
                filter.label,
                style: AppTextStyles.status.copyWith(
                  color: isSelected ? activeText : inactiveText,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}