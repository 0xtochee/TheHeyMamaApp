import 'package:flutter_test/flutter_test.dart';
import 'package:pregnancy_dashboard/providers/vitals_provider.dart';
import 'package:pregnancy_dashboard/services/local_db.dart';

void main() {
  group('VitalsProvider Tests', () {
    late VitalsProvider provider;

    setUp(() {
      provider = VitalsProvider();
    });

    test('should initialize with default values', () {
      expect(provider.userName, 'Mary');
      expect(provider.pregnancyWeeks, 24);
      expect(provider.alerts, isEmpty);
      expect(provider.isLoading, false);
    });

    test('should update user information', () {
      provider.updateUserInfo(name: 'Sarah', weeks: 30);

      expect(provider.userName, 'Sarah');
      expect(provider.pregnancyWeeks, 30);
    });

    test('should set blood pressure thresholds', () {
      provider.setBpThreshold(systolic: 150, diastolic: 95);

      expect(provider.bpSystolicThreshold, 150);
      expect(provider.bpDiastolicThreshold, 95);
    });

    test('should set heart rate thresholds', () {
      provider.setHeartRateThreshold(min: 55, max: 110);

      expect(provider.heartRateMinThreshold, 55);
      expect(provider.heartRateMaxThreshold, 110);
    });

    test('should clear all alerts', () async {
      await provider.initialize();

      // Add some alerts by adding abnormal readings
      await provider.addBloodPressureReading(systolic: 160, diastolic: 100);

      expect(provider.alerts.isNotEmpty, true);

      provider.clearAlerts();
      expect(provider.alerts, isEmpty);
    });

    test('should remove specific alert by index', () async {
      await provider.initialize();

      // Add multiple abnormal readings to generate alerts
      await provider.addBloodPressureReading(systolic: 160, diastolic: 100);
      await provider.addHeartRateReading(bpm: 110);

      final initialCount = provider.alerts.length;
      expect(initialCount, greaterThan(0));

      provider.removeAlert(0);
      expect(provider.alerts.length, initialCount - 1);
    });

    test('should add blood pressure reading and update latest value', () async {
      await provider.initialize();

      await provider.addBloodPressureReading(systolic: 120, diastolic: 80);

      expect(provider.latestBloodPressure, isNotNull);
      expect(provider.latestBloodPressure!.value, '120/80');
      expect(provider.latestBloodPressure!.type, 'blood_pressure');
    });

    test('should add heart rate reading and update latest value', () async {
      await provider.initialize();

      await provider.addHeartRateReading(bpm: 75);

      expect(provider.latestHeartRate, isNotNull);
      expect(provider.latestHeartRate!.value, '75');
      expect(provider.latestHeartRate!.type, 'heart_rate');
    });

    test('should generate alert for high blood pressure', () async {
      await provider.initialize();
      provider.clearAlerts();

      await provider.addBloodPressureReading(systolic: 160, diastolic: 100);

      expect(provider.alerts.isNotEmpty, true);
      expect(provider.alerts.first.headline, contains('High Blood Pressure'));
    });

    test('should generate alert for low blood pressure', () async {
      await provider.initialize();

      final record = VitalRecord(
        timestamp: DateTime.now(),
        systolic: 85,
        diastolic: 55,
      );

      await provider.addVitalRecord(record);

      expect(provider.alerts.isNotEmpty, true);
      expect(provider.alerts.any((alert) => alert.headline.contains('Low Blood Pressure')), true);
    });

    test('should generate alert for abnormal heart rate', () async {
      await provider.initialize();
      provider.clearAlerts();

      await provider.addHeartRateReading(bpm: 110);

      expect(provider.alerts.isNotEmpty, true);
      expect(provider.alerts.first.headline, contains('Heart Rate'));
    });

    test('should add complete vital record successfully', () async {
      await provider.initialize();

      final record = VitalRecord(
        timestamp: DateTime.now(),
        weightKg: 75.5,
        systolic: 120,
        diastolic: 80,
        heartRate: 75,
      );

      final result = await provider.addVitalRecord(record);

      expect(result, true);
      expect(provider.latestBloodPressure?.value, '120/80');
      expect(provider.latestHeartRate?.value, '75');
    });

    test('should get all vital records', () async {
      await provider.initialize();

      // Add some records
      final record1 = VitalRecord(
        timestamp: DateTime.now(),
        systolic: 120,
        diastolic: 80,
        heartRate: 75,
      );

      final record2 = VitalRecord(
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        systolic: 125,
        diastolic: 82,
        heartRate: 78,
      );

      await provider.addVitalRecord(record1);
      await provider.addVitalRecord(record2);

      final records = await provider.getAllVitalRecords(limit: 10);
      expect(records.length, greaterThanOrEqualTo(2));
    });

    test('should get latest vital record', () async {
      await provider.initialize();

      final record = VitalRecord(
        timestamp: DateTime.now(),
        weightKg: 70.0,
        systolic: 120,
        diastolic: 80,
        heartRate: 75,
      );

      await provider.addVitalRecord(record);

      final latest = await provider.getLatestVitalRecord();
      expect(latest, isNotNull);
      expect(latest?.systolic, 120);
      expect(latest?.diastolic, 80);
    });
  });

  group('VitalsProvider Alert Logic Tests', () {
    late VitalsProvider provider;

    setUp(() {
      provider = VitalsProvider();
    });

    test('should not generate alert for normal blood pressure', () async {
      await provider.initialize();
      provider.clearAlerts();

      await provider.addBloodPressureReading(systolic: 120, diastolic: 80);

      expect(provider.alerts, isEmpty);
    });

    test('should not generate alert for normal heart rate', () async {
      await provider.initialize();
      provider.clearAlerts();

      await provider.addHeartRateReading(bpm: 75);

      expect(provider.alerts, isEmpty);
    });

    test('should generate alert when systolic is at threshold', () async {
      await provider.initialize();
      provider.clearAlerts();

      await provider.addBloodPressureReading(systolic: 140, diastolic: 80);

      expect(provider.alerts.isNotEmpty, true);
    });

    test('should generate alert when diastolic is at threshold', () async {
      await provider.initialize();
      provider.clearAlerts();

      await provider.addBloodPressureReading(systolic: 120, diastolic: 90);

      expect(provider.alerts.isNotEmpty, true);
    });

    test('should check complete vital record for multiple alerts', () async {
      await provider.initialize();
      provider.clearAlerts();

      final record = VitalRecord(
        timestamp: DateTime.now(),
        systolic: 160, // High BP
        diastolic: 100, // High BP
        heartRate: 110, // High HR
      );

      await provider.addVitalRecord(record);

      // Should generate alerts for both high BP and high HR
      expect(provider.alerts.length, greaterThanOrEqualTo(1));
    });
  });
}
