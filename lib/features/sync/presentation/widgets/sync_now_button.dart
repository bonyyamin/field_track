import 'package:flutter/material.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';

/// Primary action button for manually triggering sync matching Figma design (SCREEN 08).
class SyncNowButton extends StatelessWidget {
  final bool isLoading;
  final bool enabled;
  final VoidCallback onPressed;

  const SyncNowButton({
    super.key,
    required this.isLoading,
    this.enabled = true,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final btnBg = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final textColor = isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: (isLoading || !enabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnBg,
          foregroundColor: textColor,
          disabledBackgroundColor: btnBg.withValues(alpha: 0.5),
          disabledForegroundColor: textColor.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sync_rounded,
                    size: 20,
                    color: textColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Sync now',
                    style: AppTextStyles.button.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
