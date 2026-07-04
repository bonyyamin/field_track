import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable primary and outline button component matching FieldTrack design.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isOutline;
  final bool isLoading;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isOutline = false,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width = double.infinity,
    this.height = 48.0,
    this.borderRadius,
  });

  const AppButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width = double.infinity,
    this.height = 48.0,
    this.borderRadius,
  }) : isOutline = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBg = isOutline
        ? Colors.transparent
        : (backgroundColor ??
            (isDark ? AppColors.primaryButtonDark : AppColors.primaryButtonLight));

    final defaultFg = isOutline
        ? (textColor ?? (isDark ? AppColors.primaryDark : AppColors.primaryLight))
        : (textColor ?? (isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight));

    final shape = RoundedRectangleBorder(
      borderRadius: borderRadius ?? BorderRadius.circular(10),
      side: isOutline
          ? BorderSide(
              color: backgroundColor ??
                  (isDark ? AppColors.primaryDark : AppColors.primaryLight),
              width: 1.5,
            )
          : BorderSide.none,
    );

    final childContent = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(defaultFg),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTextStyles.button.copyWith(color: defaultFg),
              ),
            ],
          );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: defaultBg,
          foregroundColor: defaultFg,
          elevation: 0,
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: isLoading ? null : onPressed,
        child: childContent,
      ),
    );
  }
}