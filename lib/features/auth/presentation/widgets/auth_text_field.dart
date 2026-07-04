import 'package:flutter/material.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';

/// Reusable form field widget matching the FieldTrack Figma design.
///
/// - Labelled above the field.
/// - Leading icon in a subtle tint.
/// - Optional trailing icon (e.g., eye toggle for passwords).
/// - Inherits InputDecorationTheme from [AppTheme].
class AuthTextField extends StatefulWidget {
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
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _isFocused = _focusNode.hasFocus;
  }

  @override
  void didUpdateWidget(AuthTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChange);
      _isFocused = _focusNode.hasFocus;
    }
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final errorColor = isDark ? AppColors.errorDark : AppColors.errorLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.fieldLabel.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              if (_isFocused)
                BoxShadow(
                  color: (_hasError ? errorColor : primaryColor).withValues(
                    alpha: 0.2,
                  ),
                  blurRadius: 8.0,
                  spreadRadius: 2.0,
                ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            style: AppTextStyles.inputText.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            validator: (value) {
              if (widget.validator != null) {
                final error = widget.validator!(value);
                final hasError = error != null;
                if (_hasError != hasError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _hasError = hasError;
                      });
                    }
                  });
                }
                return error;
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon is IconData
                  ? Icon(widget.prefixIcon as IconData, size: 18, color: iconColor)
                  : Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Image.asset(
                        widget.prefixIcon as String,
                        width: 18,
                        height: 18,
                        color: iconColor,
                      ),
                    ),
              suffixIcon: widget.suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
