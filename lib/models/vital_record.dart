import 'package:flutter/material.dart';

/// Enum representing different types of vital metrics
enum MetricType {
  weight,
  bloodPressure,
  heartRate,
  sugar;

  /// Display name for the metric
  String get displayName {
    switch (this) {
      case MetricType.weight:
        return 'Weight';
      case MetricType.bloodPressure:
        return 'Blood Pressure';
      case MetricType.heartRate:
        return 'Heart Rate';
      case MetricType.sugar:
        return 'Blood Sugar';
    }
  }

  /// Short name for the metric
  String get shortName {
    switch (this) {
      case MetricType.weight:
        return 'Weight';
      case MetricType.bloodPressure:
        return 'BP';
      case MetricType.heartRate:
        return 'HR';
      case MetricType.sugar:
        return 'Sugar';
    }
  }
}

/// Enum for date range selection
enum DateRange {
  last7Days,
  last30Days,
  last90Days;

  /// Display name for the date range
  String get displayName {
    switch (this) {
      case DateRange.last7Days:
        return 'Last 7 Days';
      case DateRange.last30Days:
        return 'Last 30 Days';
      case DateRange.last90Days:
        return 'Last 90 Days';
    }
  }

  /// Number of days in the range
  int get days {
    switch (this) {
      case DateRange.last7Days:
        return 7;
      case DateRange.last30Days:
        return 30;
      case DateRange.last90Days:
        return 90;
    }
  }
}

/// Time series data point for chart visualization
class TimeSeriesPoint {
  final DateTime time;
  final double value;

  TimeSeriesPoint(this.time, this.value);

  @override
  String toString() => 'TimeSeriesPoint(time: $time, value: $value)';
}

/// Configuration for a specific metric type
class MetricConfig {
  final MetricType metric;
  final String unit;
  final double minY;
  final double maxY;
  final Color color;
  final String Function(TimeSeriesPoint) tooltipFormatter;
  final String Function(double) valueFormatter;

  MetricConfig({
    required this.metric,
    required this.unit,
    required this.minY,
    required this.maxY,
    required this.color,
    required this.tooltipFormatter,
    required this.valueFormatter,
  });

  /// Get standard configs for each metric type
  static MetricConfig forMetric(MetricType metric) {
    switch (metric) {
      case MetricType.weight:
        return MetricConfig(
          metric: metric,
          unit: 'kg',
          minY: 40.0,
          maxY: 120.0,
          color: const Color(0xFF0D79FF),
          tooltipFormatter: (point) {
            final weekday = _getWeekdayAbbr(point.time.weekday);
            return '$weekday — ${point.value.toStringAsFixed(1)} kg';
          },
          valueFormatter: (value) => '${value.toStringAsFixed(1)} kg',
        );
      case MetricType.bloodPressure:
        return MetricConfig(
          metric: metric,
          unit: 'mmHg',
          minY: 60.0,
          maxY: 160.0,
          color: const Color(0xFFFF6B6B),
          tooltipFormatter: (point) {
            final weekday = _getWeekdayAbbr(point.time.weekday);
            return '$weekday — ${point.value.toStringAsFixed(0)} mmHg';
          },
          valueFormatter: (value) => '${value.toStringAsFixed(0)} mmHg',
        );
      case MetricType.heartRate:
        return MetricConfig(
          metric: metric,
          unit: 'bpm',
          minY: 40.0,
          maxY: 140.0,
          color: const Color(0xFFFF9F43),
          tooltipFormatter: (point) {
            final weekday = _getWeekdayAbbr(point.time.weekday);
            return '$weekday — ${point.value.toStringAsFixed(0)} bpm';
          },
          valueFormatter: (value) => '${value.toStringAsFixed(0)} bpm',
        );
      case MetricType.sugar:
        return MetricConfig(
          metric: metric,
          unit: 'mg/dL',
          minY: 60.0,
          maxY: 200.0,
          color: const Color(0xFF5F27CD),
          tooltipFormatter: (point) {
            final weekday = _getWeekdayAbbr(point.time.weekday);
            return '$weekday — ${point.value.toStringAsFixed(0)} mg/dL';
          },
          valueFormatter: (value) => '${value.toStringAsFixed(0)} mg/dL',
        );
    }
  }

  static String _getWeekdayAbbr(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }
}
