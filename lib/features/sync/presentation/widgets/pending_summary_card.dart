import 'package:flutter/material.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';

/// Summary card displaying total pending changes count and last synced time matching Figma design (SCREEN 08).
class PendingSummaryCard extends StatelessWidget {
  final int count;
  final DateTime? lastSyncedAt;

  const PendingSummaryCard({
    super.key,
    required this.count,
    this.lastSyncedAt,
  });

  String _formatLastSynced(DateTime? dateTime) {
    if (dateTime == null) return 'Not synced yet';

    final local = dateTime.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(local.year, local.month, local.day);

    final hour = local.hour == 0 ? 12 : (local.hour > 12 ? local.hour - 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    if (itemDate == today) {
      return 'Last synced today, $timeStr';
    } else if (itemDate == today.subtract(const Duration(days: 1))) {
      return 'Last synced yesterday, $timeStr';
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final monthStr = months[local.month - 1];
      return 'Last synced $monthStr ${local.day}, $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final containerBg = isDark ? AppColors.primaryContainerDark : AppColors.primaryContainerLight;
    final iconColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final pendingText = count == 1 ? '1 change pending' : '$count changes pending';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          // Circular sync icon container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: containerBg,
            ),
            child: Icon(
              Icons.sync_rounded,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pendingText,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatLastSynced(lastSyncedAt),
                  style: AppTextStyles.cardSubtitle.copyWith(
                    color: textSecondary,
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
