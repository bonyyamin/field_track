import 'package:flutter/material.dart';
import 'package:field_tracker/core/theme/app_colors.dart';

class MapPlaceholderWidget extends StatelessWidget {
  final double radiusM;

  const MapPlaceholderWidget({
    super.key,
    this.radiusM = 150,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mapBg = isDark ? AppColors.surfaceDark : AppColors.surfaceVariantLight;
    final gridLineColor = isDark ? AppColors.borderDark.withValues(alpha: 0.5) : AppColors.borderLight;
    final circleFill = isDark ? AppColors.primaryContainerDark.withValues(alpha: 0.4) : AppColors.primaryContainerLight.withValues(alpha: 0.6);
    final circleBorder = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: mapBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Custom painter for subtle grid lines
            CustomPaint(
              size: Size.infinite,
              painter: _GridPainter(gridLineColor),
            ),
            // Geofence radius circle visualization
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: (radiusM / 1000.0 * 60 + 70).clamp(60.0, 140.0),
              height: (radiusM / 1000.0 * 60 + 70).clamp(60.0, 140.0),
              decoration: BoxDecoration(
                color: circleFill,
                shape: BoxShape.circle,
                border: Border.all(color: circleBorder, width: 1.5),
              ),
            ),
            // Centre Pin Icon
            Icon(
              Icons.location_on,
              color: circleBorder,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color lineColor;

  _GridPainter(this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    // Draw horizontal & vertical reference grid lines
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.35, 0),
      Offset(size.width * 0.35, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}
