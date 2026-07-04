import 'package:flutter/material.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';

/// Offline status banner matching Figma design specification (SCREEN 08).
class OfflineStatusCard extends StatelessWidget {
  const OfflineStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.pendingBgDark : AppColors.pendingBgLight;
    final textColor = isDark ? AppColors.pendingTextDark : AppColors.pendingTextLight;
    final subtextColor = isDark
        ? AppColors.pendingTextDark.withValues(alpha: 0.8)
        : AppColors.pendingTextLight.withValues(alpha: 0.85);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 24,
            color: textColor,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're offline",
                  style: AppTextStyles.cardTitle.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Changes are saved on this device',
                  style: AppTextStyles.cardSubtitle.copyWith(
                    color: subtextColor,
                    fontSize: 13,
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
