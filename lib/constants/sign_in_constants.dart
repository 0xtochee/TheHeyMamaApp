import 'package:flutter/material.dart';

/// UI constants for the Sign In screen
///
/// Contains all colors, spacing, radii, and typography values
/// to ensure pixel-perfect implementation matching the design.
class SignInConstants {
  // Colors
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color accentBlue = Color(0xFF0D79FF);
  static const Color pageBackgroundBlue = Color(0xFFBEE3FF);

  static const Color cardBackground = Colors.white;

  static const Color textDark = Color(0xFF182033);
  static const Color textMuted = Color(0xFF7B8594);
  static const Color textLabel = Color(0xFF5B6B7A);
  static const Color textPlaceholder = Color(0xFF9AA6B3);

  static const Color borderStroke = Color(0xFFE6E9EE);
  static const Color borderFocused = Color(0xFF1E88E5);

  static const Color errorColor = Color(0xFFD84315);

  static const Color socialIconBg = Color(0xFFF5F6F7);

  // Border Radius
  static const double cardBorderRadius = 28.0;
  static const double inputBorderRadius = 12.0;
  static const double buttonBorderRadius = 28.0;
  static const double socialIconRadius = 24.0;

  // Spacing
  static const double cardHorizontalMargin = 16.0;
  static const double cardTopPadding = 48.0;
  static const double cardBottomPadding = 32.0;
  static const double cardSidePadding = 24.0;

  static const double inputSpacing = 20.0;
  static const double sectionSpacing = 24.0;
  static const double smallSpacing = 12.0;

  // Input Field Dimensions
  static const double inputVerticalPadding = 14.0;
  static const double inputHorizontalPadding = 16.0;
  static const double inputBorderWidth = 1.0;

  // Button Dimensions
  static const double buttonHeight = 56.0;
  static const double minTouchTarget = 44.0;

  // Checkbox
  static const double checkboxSize = 22.0;

  // Logo
  static const double logoSize = 72.0;

  // Social Icons
  static const double socialIconSize = 48.0;
  static const double socialIconSpacing = 24.0;

  // Typography Sizes
  static const double titleFontSize = 30.0;
  static const double subtitleFontSize = 15.0;
  static const double labelFontSize = 13.0;
  static const double inputFontSize = 15.0;
  static const double buttonFontSize = 16.0;
  static const double dividerTextSize = 14.0;

  // Font Weights
  static const FontWeight titleWeight = FontWeight.w700;
  static const FontWeight subtitleWeight = FontWeight.w400;
  static const FontWeight labelWeight = FontWeight.w500;
  static const FontWeight buttonWeight = FontWeight.w600;
}
