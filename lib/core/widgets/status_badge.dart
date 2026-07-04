import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable status chip/pill badge for Pending/Completed/Active/Inactive states.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  /// Factory constructor for Pending status (Orange/Amber).
  factory StatusBadge.pending(BuildContext context, {String label = 'Pending'}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StatusBadge(
      label: label,
      backgroundColor: isDark ? AppColors.pendingBgDark : AppColors.pendingBgLight,
      textColor: isDark ? AppColors.pendingTextDark : AppColors.pendingTextLight,
    );
  }

  /// Factory constructor for Completed status (Green).
  factory StatusBadge.completed(BuildContext context, {String label = 'Completed'}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StatusBadge(
      label: label,
      backgroundColor: isDark ? AppColors.successBgDark : AppColors.successBgLight,
      textColor: isDark ? AppColors.successTextDark : AppColors.successTextLight,
    );
  }

  /// Factory constructor for Active status (Green).
  factory StatusBadge.active(BuildContext context, {String label = 'Active'}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StatusBadge(
      label: label,
      backgroundColor: isDark ? AppColors.successBgDark : AppColors.successBgLight,
      textColor: isDark ? AppColors.successTextDark : AppColors.successTextLight,
    );
  }

  /// Factory constructor for Inactive status (Grey).
  factory StatusBadge.inactive(BuildContext context, {String label = 'Inactive'}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StatusBadge(
      label: label,
      backgroundColor: isDark ? AppColors.inactiveBgDark : AppColors.inactiveBgLight,
      textColor: isDark ? AppColors.inactiveTextDark : AppColors.inactiveTextLight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.status.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}