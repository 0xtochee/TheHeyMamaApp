import 'package:flutter/material.dart';

/// Reusable pill-shaped button widget
///
/// Features:
/// - Full-width or custom width
/// - Pill shape with customizable radius
/// - Enabled/disabled states with appropriate styling
/// - Loading state with spinner
/// - Semantic accessibility
class PillButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? textColor;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;

  const PillButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.textColor,
    this.height,
    this.borderRadius,
    this.padding,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? const Color(0xFF0D79FF);
    final effectiveDisabledColor =
        disabledBackgroundColor ?? const Color(0xFFE6E9EE);
    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveHeight = height ?? 56.0;
    final effectiveBorderRadius = borderRadius ?? 28.0;
    final effectiveFontSize = fontSize ?? 16.0;
    final effectiveFontWeight = fontWeight ?? FontWeight.w500;

    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      height: effectiveHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          disabledBackgroundColor: effectiveDisabledColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
          ),
          elevation: isEnabled ? 2 : 0,
          padding: padding,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: effectiveFontSize,
                  fontWeight: effectiveFontWeight,
                  color: isEnabled
                      ? effectiveTextColor
                      : const Color(0xFF5B6B7A),
                ),
              ),
      ),
    );
  }
}
