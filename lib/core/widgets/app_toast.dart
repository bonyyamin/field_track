import 'package:flutter/material.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';

/// AppToast provides top notification banners and top floating snackbars.
class AppToast {
  static OverlayEntry? _currentEntry;

  /// Shows a notification banner sliding down from the TOP of the screen.
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    // Remove previous toast if still displaying
    _currentEntry?.remove();
    _currentEntry = null;

    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return _TopToastWidget(
          message: message,
          isError: isError,
          duration: duration,
          actionLabel: actionLabel,
          onActionPressed: onActionPressed,
          onDismiss: () {
            if (_currentEntry == overlayEntry) {
              if (overlayEntry.mounted) {
                overlayEntry.remove();
              }
              _currentEntry = null;
            }
          },
        );
      },
    );

    _currentEntry = overlayEntry;
    overlayState.insert(overlayEntry);
  }

  /// Displays a floating SnackBar at the TOP of the screen.
  static void showTopSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top + 12;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomMargin = (screenHeight - topPadding - 70).clamp(0.0, screenHeight);

    final bg = backgroundColor ??
        (isError
            ? (isDark ? AppColors.errorDark : AppColors.errorLight)
            : (isDark ? AppColors.primaryDark : AppColors.primaryLight));

    final textColor = isError
        ? Colors.white
        : (isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: duration,
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: bottomMargin,
          left: 16,
          right: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: action,
      ),
    );
  }
}

class _TopToastWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final VoidCallback onDismiss;

  const _TopToastWidget({
    required this.message,
    required this.isError,
    required this.duration,
    this.actionLabel,
    this.onActionPressed,
    required this.onDismiss,
  });

  @override
  State<_TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<_TopToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top + 8;

    final bgColor = widget.isError
        ? (isDark ? AppColors.errorDark : AppColors.errorLight)
        : (isDark ? AppColors.primaryDark : AppColors.primaryLight);

    final textColor = widget.isError
        ? Colors.white
        : (isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight);

    final iconData = widget.isError ? Icons.error_outline : Icons.check_circle_outline;

    return Positioned(
      top: topPadding,
      left: 16,
      right: 16,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(iconData, color: textColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (widget.actionLabel != null && widget.onActionPressed != null) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            widget.onActionPressed!();
                            _dismiss();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Text(
                            widget.actionLabel!,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                      IconButton(
                        icon: Icon(Icons.close, color: textColor.withValues(alpha: 0.8), size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _dismiss,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
