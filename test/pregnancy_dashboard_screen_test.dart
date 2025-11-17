import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pregnancy_dashboard/providers/vitals_provider.dart';
import 'package:pregnancy_dashboard/screens/pregnancy_dashboard_screen.dart';
import 'package:pregnancy_dashboard/widgets/vital_card.dart';
import 'package:pregnancy_dashboard/widgets/alert_card.dart';
import 'package:pregnancy_dashboard/widgets/daily_tip_card.dart';

/// Comprehensive widget tests for PregnancyDashboardScreen
///
/// Tests cover:
/// - Greeting and pregnancy week display
/// - Vital cards rendering and interaction
/// - Alert cards display
/// - Daily tip card
/// - Floating action button
/// - Bottom navigation
void main() {
  group('PregnancyDashboardScreen Widget Tests', () {
    late VitalsProvider vitalsProvider;

    setUp(() {
      vitalsProvider = VitalsProvider();
    });

    /// Helper function to wrap widget with necessary providers
    Widget createTestWidget(Widget child) {
      return ChangeNotifierProvider<VitalsProvider>.value(
        value: vitalsProvider,
        child: MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets('displays greeting with user name', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PregnancyDashboardScreen()));
      await tester.pumpAndSettle();

      // Check for greeting text with default user name
      expect(find.textContaining('Hello, Mary'), findsOneWidget);
    });

    testWidgets('displays pregnancy week information', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PregnancyDashboardScreen()));
      await tester.pumpAndSettle();

      // Check for pregnancy week text
      expect(find.textContaining('24 weeks pregnant'), findsOneWidget);
    });

    testWidgets('displays blood pressure vital card', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PregnancyDashboardScreen()));
      await tester.pumpAndSettle();

      // Check for blood pressure label
      expect(find.text('Blood Pressure'), findsOneWidget);
      // Check for blood pressure value (default)
      expect(find.textContaining('mmHg'), findsOneWidget);
    });

    testWidgets('displays heart rate vital card', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PregnancyDashboardScreen()));
      await tester.pumpAndSettle();

      // Check for heart rate label
      expect(find.text('Heart Rate'), findsOneWidget);
      // Check for heart rate value
      expect(find.textContaining('bpm'), findsOneWidget);
    });

    testWidgets('displays daily tip card', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PregnancyDashboardScreen()));
      await tester.pumpAndSettle();

      // Check for daily tip title
      expect(find.text('Nutrition Tip'), findsOneWidget);
      // Check for tip content
      expect(find.textContaining('Stay hydrated'), findsOneWidget);
    });

    testWidgets('displays log vital button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PregnancyDashboardScreen()));
      await tester.pumpAndSettle();

      // Check for log vital button
      expect(find.text('Log vital'), findsOneWidget);
    });

    testWidgets('displays bottom navigation with 4 items', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PregnancyDashboardScreen()));
      await tester.pumpAndSettle();

      // Check for bottom navigation items
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Track'), findsOneWidget);
      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('log vital button shows dialog when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PregnancyDashboardScreen()));
      await tester.pumpAndSettle();

      // Tap the log vital button
      await tester.tap(find.text('Log vital'));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Log Vital'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('bottom navigation changes selection on tap', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PregnancyDashboardScreen()));
      await tester.pumpAndSettle();

      // Find the Track navigation item
      final trackNav = find.text('Track');
      expect(trackNav, findsOneWidget);

      // Tap the Track navigation item
      await tester.tap(trackNav);
      await tester.pumpAndSettle();

      // Verify snackbar or navigation occurred
      // (In this case, a snackbar is shown as placeholder)
      expect(find.textContaining('Navigate to Track'), findsOneWidget);
    });

    testWidgets('displays alert card when alerts exist', (WidgetTester tester) async {
      // Add a test alert to the provider
      await vitalsProvider.addBloodPressureReading(systolic: 150, diastolic: 95);

      await tester.pumpWidget(createTestWidget(const PregnancyDashboardScreen()));
      await tester.pumpAndSettle();

      // Check for alert card
      expect(find.text('Abnormal Reading'), findsOneWidget);
      expect(find.text('High Blood Pressure'), findsOneWidget);
    });

    testWidgets('vital card is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PregnancyDashboardScreen()));
      await tester.pumpAndSettle();

      // Tap the blood pressure card
      await tester.tap(find.text('Blood Pressure'));
      await tester.pumpAndSettle();

      // Verify snackbar appears
      expect(find.textContaining('Navigate to blood_pressure'), findsOneWidget);
    });
  });

  group('VitalCard Widget Tests', () {
    testWidgets('displays icon, value, and label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalCard(
              iconPath: 'assets/images/bp_device.png',
              value: '120/80 mmHg',
              label: 'Blood Pressure',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('120/80 mmHg'), findsOneWidget);
      expect(find.text('Blood Pressure'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalCard(
              iconPath: 'assets/images/bp_device.png',
              value: '120/80 mmHg',
              label: 'Blood Pressure',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VitalCard));
      expect(tapped, isTrue);
    });
  });

  group('AlertCard Widget Tests', () {
    testWidgets('displays title, headline, and message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertCard(
              title: 'Abnormal Reading',
              headline: 'High Blood Pressure',
              message: 'Your blood pressure is elevated.',
              hasAction: false,
            ),
          ),
        ),
      );

      expect(find.text('Abnormal Reading'), findsOneWidget);
      expect(find.text('High Blood Pressure'), findsOneWidget);
      expect(find.text('Your blood pressure is elevated.'), findsOneWidget);
    });

    testWidgets('displays action button when hasAction is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertCard(
              title: 'Abnormal Reading',
              headline: 'High Blood Pressure',
              message: 'Your blood pressure is elevated.',
              hasAction: true,
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Contact Doctor'), findsOneWidget);
    });

    testWidgets('triggers onDismiss callback when dismiss is tapped', (WidgetTester tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertCard(
              title: 'Abnormal Reading',
              headline: 'High Blood Pressure',
              message: 'Your blood pressure is elevated.',
              hasAction: false,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });
  });

  group('DailyTipCard Widget Tests', () {
    testWidgets('displays title and content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DailyTipCard(
              title: 'Nutrition Tip',
              content: 'Stay hydrated throughout the day.',
            ),
          ),
        ),
      );

      expect(find.text('Nutrition Tip'), findsOneWidget);
      expect(find.text('Stay hydrated throughout the day.'), findsOneWidget);
    });
  });

  group('VitalsProvider Tests', () {
    test('initializes with default values', () {
      final provider = VitalsProvider();

      expect(provider.userName, equals('Mary'));
      expect(provider.pregnancyWeeks, equals(24));
      expect(provider.latestBloodPressure, isNull);
      expect(provider.latestHeartRate, isNull);
      expect(provider.alerts, isEmpty);
    });

    test('updates user information', () {
      final provider = VitalsProvider();

      provider.updateUserInfo(name: 'Jane', weeks: 30);

      expect(provider.userName, equals('Jane'));
      expect(provider.pregnancyWeeks, equals(30));
    });

    test('adds blood pressure reading', () async {
      final provider = VitalsProvider();

      await provider.addBloodPressureReading(systolic: 120, diastolic: 80);

      expect(provider.latestBloodPressure, isNotNull);
      expect(provider.latestBloodPressure!.value, equals('120/80'));
      expect(provider.latestBloodPressure!.type, equals('blood_pressure'));
    });

    test('adds heart rate reading', () async {
      final provider = VitalsProvider();

      await provider.addHeartRateReading(bpm: 75);

      expect(provider.latestHeartRate, isNotNull);
      expect(provider.latestHeartRate!.value, equals('75'));
      expect(provider.latestHeartRate!.type, equals('heart_rate'));
    });

    test('generates alert for high blood pressure', () async {
      final provider = VitalsProvider();

      await provider.addBloodPressureReading(systolic: 150, diastolic: 95);

      expect(provider.alerts, isNotEmpty);
      expect(provider.alerts.first.headline, equals('High Blood Pressure'));
    });

    test('sets blood pressure threshold', () {
      final provider = VitalsProvider();

      provider.setBpThreshold(systolic: 130, diastolic: 85);

      expect(provider.bpSystolicThreshold, equals(130));
      expect(provider.bpDiastolicThreshold, equals(85));
    });

    test('sets heart rate threshold', () {
      final provider = VitalsProvider();

      provider.setHeartRateThreshold(min: 50, max: 110);

      expect(provider.heartRateMinThreshold, equals(50));
      expect(provider.heartRateMaxThreshold, equals(110));
    });

    test('clears all alerts', () async {
      final provider = VitalsProvider();

      await provider.addBloodPressureReading(systolic: 150, diastolic: 95);
      expect(provider.alerts, isNotEmpty);

      provider.clearAlerts();
      expect(provider.alerts, isEmpty);
    });

    test('removes specific alert', () async {
      final provider = VitalsProvider();

      await provider.addBloodPressureReading(systolic: 150, diastolic: 95);
      expect(provider.alerts.length, equals(1));

      provider.removeAlert(0);
      expect(provider.alerts, isEmpty);
    });
  });
}
