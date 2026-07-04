import 'package:flutter/material.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';
import 'package:field_tracker/core/widgets/status_badge.dart';
import '../../domain/entities/pending_change_display_item.dart';

/// Single pending change item card matching Figma design specification (SCREEN 08).
class PendingChangeTile extends StatelessWidget {
  final PendingChangeDisplayItem item;

  const PendingChangeTile({
    super.key,
    required this.item,
  });

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour == 0 ? 12 : (local.hour > 12 ? local.hour - 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final iconBoxBg = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final actionText = item.isCompleted ? 'Marked done' : 'Marked incomplete';
    final timeStr = _formatTime(item.updatedAt);
    final subtitleStr = '$actionText · $timeStr';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          // Rounded icon container box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBoxBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.iconData,
              color: textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Title & Status details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitleStr,
                  style: AppTextStyles.cardSubtitle.copyWith(
                    color: textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Pending Status Badge
          StatusBadge.pending(context),
        ],
      ),
    );
  }
}