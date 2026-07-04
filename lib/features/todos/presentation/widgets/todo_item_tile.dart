import 'package:flutter/material.dart';
import 'package:field_tracker/core/storage/database_tables.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';
import 'package:field_tracker/core/widgets/status_badge.dart';
import '../../domain/entities/todo_entity.dart';

/// Task list item card matching Figma design specification.
class TodoItemTile extends StatelessWidget {
  final TodoEntity todo;
  final ValueChanged<bool> onChanged;

  const TodoItemTile({
    super.key,
    required this.todo,
    required this.onChanged,
  });

  String _formatTime(DateTime? dateTime, {required bool isCompleted}) {
    if (dateTime == null) {
      return isCompleted ? 'Done 9:30 AM' : 'Due 10:00 AM';
    }
    final local = dateTime.toLocal();
    final hour = local.hour == 0 ? 12 : (local.hour > 12 ? local.hour - 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';
    return isCompleted ? 'Done $timeStr' : 'Due $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final successColor = isDark ? AppColors.successTextDark : AppColors.successTextLight;

    final isDone = todo.isCompleted;
    final timeLabel = _formatTime(
      isDone ? todo.updatedAt : todo.dueAt,
      isCompleted: isDone,
    );

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom circular checkbox matching Figma design
          GestureDetector(
            onTap: () => onChanged(!isDone),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? successColor : Colors.transparent,
                border: isDone
                    ? null
                    : Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        width: 2.0,
                      ),
              ),
              child: isDone
                  ? const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 14),

          // Main Task Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: isDone ? textSecondary : textPrimary,
                    fontWeight: isDone ? FontWeight.w500 : FontWeight.w700,
                    decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                    fontSize: 15,
                  ),
                ),
                if (todo.description != null && todo.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    todo.description!,
                    style: AppTextStyles.cardSubtitle.copyWith(
                      color: textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Bottom row: Time + Status Badge + Unsynced indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 15,
                          color: textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          timeLabel,
                          style: AppTextStyles.cardSubtitle.copyWith(
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (todo.syncStatus == SyncStatus.pending) ...[
                          Tooltip(
                            message: 'Pending local change',
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.cloud_upload_outlined,
                                size: 16,
                                color: isDark
                                    ? AppColors.pendingTextDark
                                    : AppColors.pendingTextLight,
                              ),
                            ),
                          ),
                        ],
                        isDone
                            ? StatusBadge.completed(context)
                            : StatusBadge.pending(context),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}