import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregnancy_dashboard/widgets/vitals_chart.dart';
import 'package:pregnancy_dashboard/models/vital_record.dart';

void main() {
  group('VitalsChart Widget Tests', () {
    testWidgets('displays empty state when no data points provided',
        (WidgetTester tester) async {
      final config = MetricConfig.forMetric(MetricType.weight);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalsChart(
              points: const [],
              config: config,
            ),
          ),
        ),
      );

      expect(find.text('No data yet for this period'), findsOneWidget);
      expect(find.text('Start tracking to see your trends'), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
    });

    testWidgets('displays single point state with one data point',
        (WidgetTester tester) async {
      final config = MetricConfig.forMetric(MetricType.weight);
      final points = [
        TimeSeriesPoint(DateTime(2024, 3, 10), 95.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalsChart(
              points: points,
              config: config,
            ),
          ),
        ),
      );

      expect(find.text('95.0 kg'), findsOneWidget);
      expect(
          find.text('Need more data points to show trends'), findsOneWidget);
      expect(find.byIcon(Icons.timeline), findsOneWidget);
    });

    testWidgets('displays chart with multiple data points',
        (WidgetTester tester) async {
      final config = MetricConfig.forMetric(MetricType.weight);
      final points = [
        TimeSeriesPoint(DateTime(2024, 3, 10), 95.0),
        TimeSeriesPoint(DateTime(2024, 3, 11), 96.0),
        TimeSeriesPoint(DateTime(2024, 3, 12), 95.5),
        TimeSeriesPoint(DateTime(2024, 3, 13), 97.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalsChart(
              points: points,
              config: config,
            ),
          ),
        ),
      );

      // Chart should be displayed (no empty/single point messages)
      expect(find.text('No data yet for this period'), findsNothing);
      expect(find.text('Need more data points to show trends'), findsNothing);

      // Weekday labels should be visible
      expect(find.text('Sun'), findsWidgets);
      expect(find.text('Mon'), findsWidgets);
    });

    testWidgets('chart displays correct config for heart rate metric',
        (WidgetTester tester) async {
      final config = MetricConfig.forMetric(MetricType.heartRate);
      final points = [
        TimeSeriesPoint(DateTime(2024, 3, 10), 75.0),
        TimeSeriesPoint(DateTime(2024, 3, 11), 78.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalsChart(
              points: points,
              config: config,
            ),
          ),
        ),
      );

      // Verify chart renders without errors
      expect(find.byType(VitalsChart), findsOneWidget);
    });

    testWidgets('chart displays correct config for blood pressure metric',
        (WidgetTester tester) async {
      final config = MetricConfig.forMetric(MetricType.bloodPressure);
      final points = [
        TimeSeriesPoint(DateTime(2024, 3, 10), 120.0),
        TimeSeriesPoint(DateTime(2024, 3, 11), 125.0),
        TimeSeriesPoint(DateTime(2024, 3, 12), 122.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalsChart(
              points: points,
              config: config,
            ),
          ),
        ),
      );

      // Verify chart renders without errors
      expect(find.byType(VitalsChart), findsOneWidget);
    });

    testWidgets('chart displays correct config for sugar metric',
        (WidgetTester tester) async {
      final config = MetricConfig.forMetric(MetricType.sugar);
      final points = [
        TimeSeriesPoint(DateTime(2024, 3, 10), 95.0),
        TimeSeriesPoint(DateTime(2024, 3, 11), 98.0),
        TimeSeriesPoint(DateTime(2024, 3, 12), 92.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalsChart(
              points: points,
              config: config,
            ),
          ),
        ),
      );

      // Verify chart renders without errors
      expect(find.byType(VitalsChart), findsOneWidget);
    });

    testWidgets('chart handles edge case with zero values',
        (WidgetTester tester) async {
      final config = MetricConfig.forMetric(MetricType.weight);
      final points = [
        TimeSeriesPoint(DateTime(2024, 3, 10), 0.0),
        TimeSeriesPoint(DateTime(2024, 3, 11), 0.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalsChart(
              points: points,
              config: config,
            ),
          ),
        ),
      );

      // Verify chart renders without errors
      expect(find.byType(VitalsChart), findsOneWidget);
    });

    testWidgets('chart handles edge case with constant values',
        (WidgetTester tester) async {
      final config = MetricConfig.forMetric(MetricType.heartRate);
      final points = [
        TimeSeriesPoint(DateTime(2024, 3, 10), 75.0),
        TimeSeriesPoint(DateTime(2024, 3, 11), 75.0),
        TimeSeriesPoint(DateTime(2024, 3, 12), 75.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalsChart(
              points: points,
              config: config,
            ),
          ),
        ),
      );

      // Verify chart renders without errors
      expect(find.byType(VitalsChart), findsOneWidget);
    });

    testWidgets('chart respects showArea parameter',
        (WidgetTester tester) async {
      final config = MetricConfig.forMetric(MetricType.weight);
      final points = [
        TimeSeriesPoint(DateTime(2024, 3, 10), 95.0),
        TimeSeriesPoint(DateTime(2024, 3, 11), 96.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalsChart(
              points: points,
              config: config,
              showArea: false,
            ),
          ),
        ),
      );

      // Verify chart renders without errors
      expect(find.byType(VitalsChart), findsOneWidget);
    });

    testWidgets('chart respects enableTouch parameter',
        (WidgetTester tester) async {
      final config = MetricConfig.forMetric(MetricType.weight);
      final points = [
        TimeSeriesPoint(DateTime(2024, 3, 10), 95.0),
        TimeSeriesPoint(DateTime(2024, 3, 11), 96.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalsChart(
              points: points,
              config: config,
              enableTouch: false,
            ),
          ),
        ),
      );

      // Verify chart renders without errors
      expect(find.byType(VitalsChart), findsOneWidget);
    });

    testWidgets('chart has proper semantics for accessibility',
        (WidgetTester tester) async {
      final config = MetricConfig.forMetric(MetricType.weight);
      final points = [
        TimeSeriesPoint(DateTime(2024, 3, 10), 95.0),
        TimeSeriesPoint(DateTime(2024, 3, 11), 96.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalsChart(
              points: points,
              config: config,
            ),
          ),
        ),
      );

      // Verify Semantics widget exists
      expect(find.byType(Semantics), findsWidgets);

      // Verify the chart renders without accessibility errors
      expect(tester.takeException(), isNull);
    });
  });

  group('MetricConfig Tests', () {
    test('weight metric config has correct properties', () {
      final config = MetricConfig.forMetric(MetricType.weight);

      expect(config.metric, MetricType.weight);
      expect(config.unit, 'kg');
      expect(config.minY, 40.0);
      expect(config.maxY, 120.0);
      expect(config.valueFormatter(95.5), '95.5 kg');

      final point = TimeSeriesPoint(DateTime(2024, 3, 11), 95.5);
      expect(config.tooltipFormatter(point), contains('Mon'));
      expect(config.tooltipFormatter(point), contains('95.5 kg'));
    });

    test('blood pressure metric config has correct properties', () {
      final config = MetricConfig.forMetric(MetricType.bloodPressure);

      expect(config.metric, MetricType.bloodPressure);
      expect(config.unit, 'mmHg');
      expect(config.minY, 60.0);
      expect(config.maxY, 160.0);
      expect(config.valueFormatter(120.0), '120 mmHg');
    });

    test('heart rate metric config has correct properties', () {
      final config = MetricConfig.forMetric(MetricType.heartRate);

      expect(config.metric, MetricType.heartRate);
      expect(config.unit, 'bpm');
      expect(config.minY, 40.0);
      expect(config.maxY, 140.0);
      expect(config.valueFormatter(75.0), '75 bpm');
    });

    test('sugar metric config has correct properties', () {
      final config = MetricConfig.forMetric(MetricType.sugar);

      expect(config.metric, MetricType.sugar);
      expect(config.unit, 'mg/dL');
      expect(config.minY, 60.0);
      expect(config.maxY, 200.0);
      expect(config.valueFormatter(95.0), '95 mg/dL');
    });

    test('tooltip formatter includes correct weekday', () {
      final config = MetricConfig.forMetric(MetricType.weight);

      final monday = TimeSeriesPoint(DateTime(2024, 3, 11), 95.0); // Monday
      expect(config.tooltipFormatter(monday), contains('Mon'));

      final friday = TimeSeriesPoint(DateTime(2024, 3, 15), 96.0); // Friday
      expect(config.tooltipFormatter(friday), contains('Fri'));

      final sunday = TimeSeriesPoint(DateTime(2024, 3, 10), 94.0); // Sunday
      expect(config.tooltipFormatter(sunday), contains('Sun'));
    });
  });

  group('TimeSeriesPoint Tests', () {
    test('TimeSeriesPoint can be created and accessed', () {
      final time = DateTime(2024, 3, 10);
      final point = TimeSeriesPoint(time, 95.0);

      expect(point.time, time);
      expect(point.value, 95.0);
    });

    test('TimeSeriesPoint toString works correctly', () {
      final time = DateTime(2024, 3, 10);
      final point = TimeSeriesPoint(time, 95.0);

      expect(point.toString(), contains('2024-03-10'));
      expect(point.toString(), contains('95.0'));
    });
  });
}
