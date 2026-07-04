import 'package:flutter/material.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';
import '../../domain/entities/location_entity.dart';

class LocationCard extends StatelessWidget {
  final LocationEntity location;
  final VoidCallback onTap;

  const LocationCard({
    super.key,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final containerBg = isDark ? AppColors.primaryContainerDark : AppColors.primaryContainerLight;
    final iconColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final pillBg = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;
    final pillTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final activeBg = isDark ? AppColors.successBgDark : AppColors.successBgLight;
    final activeText = isDark ? AppColors.successTextDark : AppColors.successTextLight;

    final inactiveBg = isDark ? AppColors.inactiveBgDark : AppColors.inactiveBgLight;
    final inactiveText = isDark ? AppColors.inactiveTextDark : AppColors.inactiveTextLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: containerBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Main info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.locationName,
                        style: AppTextStyles.h4.copyWith(
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.my_location,
                            size: 14,
                            color: subtitleColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${location.latitude}, ${location.longitude}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: subtitleColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Pills row: Radius & Active/Inactive
                      Row(
                        children: [
                          // Radius pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: pillBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${location.radiusM.toInt()} m radius',
                              style: AppTextStyles.caption.copyWith(
                                color: pillTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Active status pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: location.isActive ? activeBg : inactiveBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              location.isActive ? 'Active' : 'Inactive',
                              style: AppTextStyles.caption.copyWith(
                                color: location.isActive ? activeText : inactiveText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Right Chevron
                Icon(
                  Icons.chevron_right,
                  color: subtitleColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}