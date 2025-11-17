import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header widget displaying metric name, current value, and trend
///
/// Shows:
/// - Metric label (small, left-aligned)
/// - Large current value (bold, prominent)
/// - Trend indicator with percentage and time range
class MetricHeader extends StatelessWidget {
  final String metricName;
  final String currentValue;
  final String? trendText;
  final double? trendPercentage;
  final Color valueColor;

  const MetricHeader({
    Key? key,
    required this.metricName,
    required this.currentValue,
    this.trendText,
    this.trendPercentage,
    this.valueColor = const Color(0xFF2B3B4A),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metric label
          Text(
            metricName.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF7F97AA),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Current value
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currentValue,
                style: GoogleFonts.inter(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 12),

              // Trend indicator
              if (trendText != null || trendPercentage != null)
                _buildTrendIndicator(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final isPositive = trendPercentage != null && trendPercentage! > 0;
    final isNegative = trendPercentage != null && trendPercentage! < 0;

    // Determine color based on trend
    Color trendColor;
    IconData? trendIcon;

    if (isPositive) {
      trendColor = const Color(0xFF27AE60); // Green
      trendIcon = Icons.arrow_upward;
    } else if (isNegative) {
      trendColor = const Color(0xFFEB5757); // Red
      trendIcon = Icons.arrow_downward;
    } else {
      trendColor = const Color(0xFF7F97AA); // Neutral
      trendIcon = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trendIcon != null) ...[
            Icon(
              trendIcon,
              size: 14,
              color: trendColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            trendText ?? '',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }
}
