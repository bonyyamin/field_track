import 'package:flutter/material.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';

/// Reusable form field widget matching the FieldTrack Figma design.
///
/// - Labelled above the field.
/// - Leading icon in a subtle tint.
/// - Optional trailing icon (e.g., eye toggle for passwords).
/// - Shows a thin glowing border when focused (no shadow).
class AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final dynamic prefixIcon; // Can be IconData or String (for asset image)
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    const glowColor = AppColors.primaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.fieldLabel.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: AppTextStyles.inputText.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            // Use a custom InputBorder that draws the glow effect.
            // Flutter paints InputBorder ONLY around the input box —
            // never around the error text below it.
            focusedBorder: const _GlowInputBorder(color: glowColor),
            focusedErrorBorder: const _GlowInputBorder(color: glowColor),
            prefixIcon: prefixIcon is IconData
                ? Icon(prefixIcon as IconData, size: 18, color: iconColor)
                : Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Image.asset(
                      prefixIcon as String,
                      width: 18,
                      height: 18,
                      color: iconColor,
                    ),
                  ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

/// Custom [InputBorder] that renders a thin glowing stroke.
///
/// Because Flutter paints [InputBorder] only around the input box itself
/// (never around the helper/error text), this approach avoids the
/// double-border and misplaced-border issues that wrapping containers cause.
class _GlowInputBorder extends InputBorder {
  final Color color;

  const _GlowInputBorder({required this.color})
      : super(borderSide: BorderSide.none);

  static const _radius = Radius.circular(10);

  @override
  bool get isOutline => true;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(1.5);

  @override
  _GlowInputBorder copyWith({BorderSide? borderSide}) => this;

  @override
  ShapeBorder scale(double t) => this;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(RRect.fromRectAndRadius(rect, _radius));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(RRect.fromRectAndRadius(rect, _radius));

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.75),
      _radius,
    );

    // Soft glow — blur applied only to the stroke, not a filled shadow.
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
    );

    // Crisp solid border line on top.
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }
}
