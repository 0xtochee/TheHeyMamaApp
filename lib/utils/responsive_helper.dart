import 'package:flutter/material.dart';

/// Responsive Helper Utility
///
/// Provides consistent responsive design utilities across the app.
/// Breakpoints:
/// - Mobile: < 600px
/// - Tablet: 600px - 1000px
/// - Desktop: > 1000px
class ResponsiveHelper {
  // Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1000.0;

  // Device type detection
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Responsive padding
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 20.0;
    } else if (width < tabletBreakpoint) {
      return 32.0;
    } else {
      return 48.0;
    }
  }

  static double getVerticalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 16.0;
    } else if (width < tabletBreakpoint) {
      return 24.0;
    } else {
      return 32.0;
    }
  }

  // Responsive font sizes
  static double getTitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 20.0;
    } else if (width < tabletBreakpoint) {
      return 22.0;
    } else {
      return 24.0;
    }
  }

  static double getHeadingFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 16.0;
    } else if (width < tabletBreakpoint) {
      return 18.0;
    } else {
      return 20.0;
    }
  }

  static double getBodyFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 14.0;
    } else if (width < tabletBreakpoint) {
      return 15.0;
    } else {
      return 16.0;
    }
  }

  static double getSmallFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 12.0;
    } else if (width < tabletBreakpoint) {
      return 13.0;
    } else {
      return 14.0;
    }
  }

  // Responsive spacing
  static double getSectionSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 28.0;
    } else if (width < tabletBreakpoint) {
      return 36.0;
    } else {
      return 48.0;
    }
  }

  static double getItemSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 16.0;
    } else if (width < tabletBreakpoint) {
      return 20.0;
    } else {
      return 24.0;
    }
  }

  // Responsive sizes
  static double getButtonHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 56.0;
    } else if (width < tabletBreakpoint) {
      return 60.0;
    } else {
      return 64.0;
    }
  }

  static double getAvatarSize(BuildContext context, {bool isLarge = false}) {
    final width = MediaQuery.of(context).size.width;
    final baseSize = isLarge ? 56.0 : 48.0;

    if (width < mobileBreakpoint) {
      return baseSize;
    } else if (width < tabletBreakpoint) {
      return baseSize + 8.0;
    } else {
      return baseSize + 16.0;
    }
  }

  // Get responsive max height for scrollable lists
  static double getListMaxHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    // Use 30% of screen height for scrollable lists
    return height * 0.3;
  }

  // Get responsive container constraints
  static BoxConstraints getContainerConstraints(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return const BoxConstraints(maxWidth: double.infinity);
    } else if (width < tabletBreakpoint) {
      return const BoxConstraints(maxWidth: 800);
    } else {
      return const BoxConstraints(maxWidth: 1200);
    }
  }

  // Get responsive columns for grid layouts
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 1;
    } else if (width < tabletBreakpoint) {
      return 2;
    } else {
      return 3;
    }
  }

  // Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
}
