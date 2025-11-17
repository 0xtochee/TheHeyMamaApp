/// UI Constants and Configuration
///
/// Centralized constants for colors, dimensions, validation limits,
/// and alert thresholds used throughout the pregnancy dashboard app.
library;

import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  // Primary colors
  static const Color primaryBlue = Color(0xFF0D79FF);
  static const Color activeBlue = Color(0xFF1E88E5);
  static const Color darkNavy = Color(0xFF182033);

  // Text colors
  static const Color headingText = Color(0xFF1A2332);
  static const Color bodyText = Color(0xFF5B6B7A);
  static const Color subtleText = Color(0xFF8A99A8);

  // UI element colors
  static const Color stroke = Color(0xFFE6E9EE);
  static const Color errorRed = Color(0xFFD84315);
  static const Color successGreen = Color(0xFF43A047);
  static const Color warningOrange = Color(0xFFFF9800);

  // Card gradients
  static const List<Color> blueGradient = [Color(0xFFE3F2FD), Color(0xFF90CAF9)];
  static const List<Color> pinkGradient = [Color(0xFFFCE4EC), Color(0xFFF8BBD0)];
  static const List<Color> greenGradient = [Color(0xFFE8F5E9), Color(0xFFC8E6C9)];
  static const List<Color> orangeGradient = [Color(0xFFFFF3E0), Color(0xFFFFE0B2)];

  // Background
  static const Color scaffoldBackground = Colors.white;
}

/// Application dimensions and spacing
class AppDimensions {
  // Spacing
  static const double horizontalPadding = 20.0;
  static const double verticalSpacing = 18.0;
  static const double cardSpacing = 16.0;

  // Border radius
  static const double cardRadius = 20.0;
  static const double inputRadius = 12.0;
  static const double buttonRadius = 28.0;

  // Input dimensions
  static const double inputHeight = 56.0;
  static const double inputPadding = 14.0;

  // Button dimensions
  static const double buttonHeight = 56.0;
  static const double minTouchTarget = 44.0;

  // Slider dimensions
  static const double sliderTrackHeight = 6.0;
  static const double sliderThumbRadius = 8.0;
}

/// Typography styles
class AppTextStyles {
  static const String fontFamily = 'Inter';

  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.headingText,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.headingText,
    letterSpacing: -0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.headingText,
  );

  // Body text
  static const TextStyle body1 = TextStyle(
    fontSize: 14,
    color: AppColors.bodyText,
    height: 1.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.bodyText,
  );

  // Labels
  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.bodyText,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.subtleText,
  );
}

/// Validation limits for vital signs
class VitalLimits {
  // Weight (kg)
  static const double weightMin = 20.0;
  static const double weightMax = 300.0;
  static const double weightDefault = 70.0;

  // Blood Pressure (mmHg)
  static const int systolicMin = 50;
  static const int systolicMax = 250;
  static const int diastolicMin = 30;
  static const int diastolicMax = 150;

  // Heart Rate (bpm)
  static const int heartRateMin = 30;
  static const int heartRateMax = 220;
  static const int heartRateDefault = 75;

  // Blood Sugar (mg/dL)
  static const int bloodSugarMin = 40;
  static const int bloodSugarMax = 400;
}

/// Alert thresholds for health monitoring
class AlertThresholds {
  // Blood Pressure thresholds
  static const int bpSystolicHigh = 140;
  static const int bpSystolicLow = 90;
  static const int bpDiastolicHigh = 90;
  static const int bpDiastolicLow = 60;

  // Heart Rate thresholds (for pregnant women)
  static const int heartRateHigh = 100;
  static const int heartRateLow = 60;

  // Weight change threshold (kg per week)
  static const double weightChangeThreshold = 2.0;

  /// Check if blood pressure is in alert range
  static bool isBPAlert(int systolic, int diastolic) {
    return systolic >= bpSystolicHigh ||
           systolic <= bpSystolicLow ||
           diastolic >= bpDiastolicHigh ||
           diastolic <= bpDiastolicLow;
  }

  /// Check if heart rate is in alert range
  static bool isHeartRateAlert(int heartRate) {
    return heartRate >= heartRateHigh || heartRate <= heartRateLow;
  }

  /// Get blood pressure status message
  static String getBPStatusMessage(int systolic, int diastolic) {
    if (systolic >= bpSystolicHigh || diastolic >= bpDiastolicHigh) {
      return 'High blood pressure detected. Please consult your doctor.';
    } else if (systolic <= bpSystolicLow || diastolic <= bpDiastolicLow) {
      return 'Low blood pressure detected. Please rest and monitor.';
    }
    return 'Blood pressure is normal.';
  }

  /// Get heart rate status message
  static String getHeartRateStatusMessage(int heartRate) {
    if (heartRate >= heartRateHigh) {
      return 'Elevated heart rate detected. Please rest and monitor.';
    } else if (heartRate <= heartRateLow) {
      return 'Low heart rate detected. Please consult your doctor if you feel unwell.';
    }
    return 'Heart rate is normal.';
  }
}

/// Animation durations
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}
