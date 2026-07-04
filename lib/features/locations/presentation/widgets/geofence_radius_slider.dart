import 'package:flutter/material.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';

class GeofenceRadiusSlider extends StatelessWidget {
  final double radiusM;
  final ValueChanged<double> onChanged;

  const GeofenceRadiusSlider({
    super.key,
    required this.radiusM,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final labelColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final inactiveTrackColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Geofence radius',
              style: AppTextStyles.bodyMedium.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${radiusM.round()} m',
              style: AppTextStyles.h4.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: primaryColor,
            inactiveTrackColor: inactiveTrackColor,
            thumbColor: primaryColor,
            overlayColor: primaryColor.withValues(alpha: 0.15),
            trackHeight: 6.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
          ),
          child: Slider(
            value: radiusM.clamp(20.0, 1000.0),
            min: 20.0,
            max: 1000.0,
            divisions: 98, // 10m increments from 20 to 1000
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}