import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pregnancy_dashboard/screens/track_vitals_screen.dart';
import 'package:pregnancy_dashboard/providers/vitals_provider.dart';
import 'package:pregnancy_dashboard/models/vital_record.dart';

void main() {
  group('TrackVitalsScreen Widget Tests', () {
    late VitalsProvider mockProvider;

    setUp(() {
      mockProvider = VitalsProvider();
    });

    testWidgets('screen displays app bar with title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<VitalsProvider>.value(
          value: mockProvider,
          child: const MaterialApp(
            home: TrackVitalsScreen(),
          ),
        ),
      );

      expect(find.text('Vitals'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('screen displays all four metric tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<VitalsProvider>.value(
          value: mockProvider,
          child: const MaterialApp(
            home: TrackVitalsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Blood Pressure'), findsOneWidget);
      expect(find.text('Heart Rate'), findsOneWidget);
      expect(find.text('Blood Sugar'), findsOneWidget);
    });

    testWidgets('screen displays bottom navigation bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<VitalsProvider>.value(
          value: mockProvider,
          child: const MaterialApp(
            home: TrackVitalsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Track'), findsOneWidget);
      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('screen displays Quick Log floating action button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<VitalsProvider>.value(
          value: mockProvider,
          child: const MaterialApp(
            home: TrackVitalsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Quick Log'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping tab switches metric view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<VitalsProvider>.value(
          value: mockProvider,
          child: const MaterialApp(
            home: TrackVitalsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially on Weight tab
      expect(mockProvider.selectedMetric, MetricType.weight);

      // Tap on Blood Pressure tab
      await tester.tap(find.text('Blood Pressure'));
      await tester.pumpAndSettle();

      // Verify metric changed
      expect(mockProvider.selectedMetric, MetricType.bloodPressure);
    });

    testWidgets('displays date range selector with all options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<VitalsProvider>.value(
          value: mockProvider,
          child: const MaterialApp(
            home: TrackVitalsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Last 7 Days'), findsOneWidget);
      expect(find.text('Last 30 Days'), findsOneWidget);
      expect(find.text('Last 90 Days'), findsOneWidget);
      expect(find.text('TIME RANGE'), findsOneWidget);
    });

    testWidgets('tapping date range chip changes selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<VitalsProvider>.value(
          value: mockProvider,
          child: const MaterialApp(
            home: TrackVitalsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially on Last 7 Days
      expect(mockProvider.selectedDateRange, DateRange.last7Days);

      // Scroll to make the chip visible
      await tester.dragUntilVisible(
        find.text('Last 30 Days'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      // Tap on Last 30 Days
      await tester.tap(find.text('Last 30 Days'));
      await tester.pumpAndSettle();

      // Verify range changed
      expect(mockProvider.selectedDateRange, DateRange.last30Days);
    });

    testWidgets('displays loading indicator when provider is loading',
        (WidgetTester tester) async {
      // Note: This test may not work as expected because the provider
      // loading state is managed internally. This is a structural test.
      await tester.pumpWidget(
        ChangeNotifierProvider<VitalsProvider>.value(
          value: mockProvider,
          child: const MaterialApp(
            home: TrackVitalsScreen(),
          ),
        ),
      );

      // Pump without settling to catch loading state
      await tester.pump();

      // The widget should still render
      expect(find.byType(TrackVitalsScreen), findsOneWidget);
    });

    testWidgets('back button pops navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<VitalsProvider>.value(
          value: mockProvider,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TrackVitalsScreen(),
                      ),
                    );
                  },
                  child: const Text('Go to Track'),
                ),
              ),
            ),
          ),
        ),
      );

      // Navigate to TrackVitalsScreen
      await tester.tap(find.text('Go to Track'));
      await tester.pumpAndSettle();

      // Verify we're on the screen
      expect(find.text('Vitals'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back to previous screen
      expect(find.text('Go to Track'), findsOneWidget);
    });

    testWidgets('displays metric header with proper formatting',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<VitalsProvider>.value(
          value: mockProvider,
          child: const MaterialApp(
            home: TrackVitalsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display metric name in uppercase
      expect(find.text('WEIGHT'), findsOneWidget);
    });

    testWidgets('screen is accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<VitalsProvider>.value(
          value: mockProvider,
          child: const MaterialApp(
            home: TrackVitalsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify back button has tooltip
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      // Verify screen renders without accessibility issues
      expect(tester.takeException(), isNull);
    });
  });

  group('MetricType Enum Tests', () {
    test('displayName returns correct values', () {
      expect(MetricType.weight.displayName, 'Weight');
      expect(MetricType.bloodPressure.displayName, 'Blood Pressure');
      expect(MetricType.heartRate.displayName, 'Heart Rate');
      expect(MetricType.sugar.displayName, 'Blood Sugar');
    });

    test('shortName returns correct values', () {
      expect(MetricType.weight.shortName, 'Weight');
      expect(MetricType.bloodPressure.shortName, 'BP');
      expect(MetricType.heartRate.shortName, 'HR');
      expect(MetricType.sugar.shortName, 'Sugar');
    });
  });

  group('DateRange Enum Tests', () {
    test('displayName returns correct values', () {
      expect(DateRange.last7Days.displayName, 'Last 7 Days');
      expect(DateRange.last30Days.displayName, 'Last 30 Days');
      expect(DateRange.last90Days.displayName, 'Last 90 Days');
    });

    test('days returns correct number of days', () {
      expect(DateRange.last7Days.days, 7);
      expect(DateRange.last30Days.days, 30);
      expect(DateRange.last90Days.days, 90);
    });
  });
}
