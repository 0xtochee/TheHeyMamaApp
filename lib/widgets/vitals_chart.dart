import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/vital_record.dart';

/// A highly configurable line chart widget for displaying vital signs data
///
/// Features:
/// - Smooth curved lines with gradient fill
/// - Animated transitions
/// - Touch tooltips
/// - Customizable colors, ranges, and formatting
/// - Accessibility support
class VitalsChart extends StatefulWidget {
  final List<TimeSeriesPoint> points;
  final MetricConfig config;
  final bool showArea;
  final bool enableTouch;

  const VitalsChart({
    Key? key,
    required this.points,
    required this.config,
    this.showArea = true,
    this.enableTouch = true,
  }) : super(key: key);

  @override
  State<VitalsChart> createState() => _VitalsChartState();
}

class _VitalsChartState extends State<VitalsChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    // Handle empty data case
    if (widget.points.isEmpty) {
      return _buildEmptyState();
    }

    // Handle single point case
    if (widget.points.length == 1) {
      return _buildSinglePointState();
    }

    return Semantics(
      label: 'Chart showing ${widget.config.metric.displayName} over time',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: LineChart(
          _buildChartData(),
          duration: const Duration(milliseconds: 500),
        ),
      ),
    );
  }

  LineChartData _buildChartData() {
    // Map data points to weekday positions (0=Mon, 6=Sun)
    // This ensures the X-axis always shows Mon-Sun regardless of data
    final Map<int, double> weekdayValues = {};

    for (final point in widget.points) {
      final weekdayIndex = (point.time.weekday - 1) % 7; // 0=Mon, 6=Sun
      weekdayValues[weekdayIndex] = point.value;
    }

    // Create spots only for days with data
    final spots = weekdayValues.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x)); // Sort by weekday

    // Calculate dynamic min/max with padding
    double effectiveMinY = widget.config.minY;
    double effectiveMaxY = widget.config.maxY;

    if (spots.isNotEmpty) {
      final values = spots.map((s) => s.y).toList();
      final minValue = values.reduce((a, b) => a < b ? a : b);
      final maxValue = values.reduce((a, b) => a > b ? a : b);

      // Add 10% padding to min/max
      final range = maxValue - minValue;
      final padding = range > 0 ? range * 0.1 : 5.0;
      effectiveMinY = (minValue - padding).clamp(widget.config.minY, widget.config.maxY);
      effectiveMaxY = (maxValue + padding).clamp(widget.config.minY, widget.config.maxY);
    }

    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: widget.config.color,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: widget.points.length <= 7,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 6,
                color: widget.config.color,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: widget.showArea,
            gradient: LinearGradient(
              colors: [
                widget.config.color.withOpacity(0.14),
                widget.config.color.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          shadow: Shadow(
            color: widget.config.color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              // Fixed weekday labels: 0=Mon, 1=Tue, ..., 6=Sun
              final weekdayIndex = value.toInt();
              if (weekdayIndex < 0 || weekdayIndex > 6) {
                return const SizedBox.shrink();
              }

              final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              final label = weekdays[weekdayIndex];

              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF7F97AA),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (effectiveMaxY - effectiveMinY) > 0
            ? (effectiveMaxY - effectiveMinY) / 4
            : 1.0,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xFFE5E5E5),
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6, // Fixed: 0=Mon to 6=Sun
      minY: effectiveMinY,
      maxY: effectiveMaxY,
      lineTouchData: widget.enableTouch
          ? LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: const Color(0xFF2B3B4A),
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((spot) {
                    final index = spot.x.toInt();
                    if (index < 0 || index >= widget.points.length) {
                      return null;
                    }

                    final point = widget.points[index];
                    final text = widget.config.tooltipFormatter(point);

                    return LineTooltipItem(
                      text,
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    );
                  }).toList();
                },
              ),
              getTouchedSpotIndicator: (barData, spotIndexes) {
                return spotIndexes.map((spotIndex) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: widget.config.color,
                      strokeWidth: 2,
                    ),
                    FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 8,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: widget.config.color,
                        );
                      },
                    ),
                  );
                }).toList();
              },
            )
          : LineTouchData(enabled: false),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 64,
              color: const Color(0xFFE5E5E5),
            ),
            const SizedBox(height: 16),
            Text(
              'No data yet for this period',
              style: TextStyle(
                color: const Color(0xFF7F97AA),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking to see your trends',
              style: TextStyle(
                color: const Color(0xFF7F97AA).withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSinglePointState() {
    final point = widget.points.first;
    final formattedValue = widget.config.valueFormatter(point.value);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 64,
              color: widget.config.color.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              formattedValue,
              style: TextStyle(
                color: const Color(0xFF2B3B4A),
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Need more data points to show trends',
              style: TextStyle(
                color: const Color(0xFF7F97AA),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekdayShort(int weekday) {
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
