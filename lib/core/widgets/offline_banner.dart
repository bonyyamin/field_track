import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Offline status banner component displayed when connection is offline.
class OfflineBanner extends StatelessWidget {
  final String title;
  final String message;
  final bool isVisible;

  const OfflineBanner({
    super.key,
    this.title = "You're offline",
    this.message = 'Changes are saved on this device',
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.pendingBgDark : AppColors.pendingBgLight;
    final textColor = isDark ? AppColors.pendingTextDark : AppColors.pendingTextLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: textColor,
                    fontSize: 13,
                  ),
                ),
                Text(
                  message,
                  style: AppTextStyles.cardSubtitle.copyWith(
                    color: textColor.withValues(alpha: 0.85),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
