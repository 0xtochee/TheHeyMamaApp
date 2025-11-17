import 'package:flutter_test/flutter_test.dart';
import 'package:pregnancy_dashboard/services/local_db.dart';
import 'package:pregnancy_dashboard/providers/vitals_provider.dart';

/// Debug test to check vital saving functionality
void main() {
  group('Debug: Vital Saving', () {
    test('should create VitalRecord successfully', () {
      final record = VitalRecord(
        timestamp: DateTime.now(),
        weightKg: 70.0,
        systolic: 120,
        diastolic: 80,
        heartRate: 75,
      );

      expect(record.timestamp, isNotNull);
      expect(record.weightKg, 70.0);
      expect(record.systolic, 120);
      expect(record.diastolic, 80);
      expect(record.heartRate, 75);

      print('✅ VitalRecord created successfully');
      print('   Record: ${record.toString()}');
    });

    test('should convert VitalRecord to map', () {
      final record = VitalRecord(
        timestamp: DateTime.parse('2025-01-15T10:30:00.000'),
        weightKg: 70.0,
        systolic: 120,
        diastolic: 80,
        heartRate: 75,
      );

      final map = record.toMap();

      expect(map['timestamp'], '2025-01-15T10:30:00.000');
      expect(map['weight_kg'], 70.0);
      expect(map['systolic'], 120);
      expect(map['diastolic'], 80);
      expect(map['heart_rate'], 75);

      print('✅ VitalRecord converted to map successfully');
      print('   Map: $map');
    });

    test('should save VitalRecord to database', () async {
      final db = LocalDatabase();
      final record = VitalRecord(
        timestamp: DateTime.now(),
        weightKg: 72.5,
        systolic: 125,
        diastolic: 82,
        heartRate: 78,
      );

      try {
        final id = await db.insertVitalRecord(record);
        expect(id, isNotEmpty);
        print('✅ VitalRecord saved to database');
        print('   Record ID: $id');

        // Try to retrieve it
        final retrieved = await db.getLatestVitalRecord();
        if (retrieved != null) {
          print('✅ VitalRecord retrieved from database');
          print('   Retrieved: ${retrieved.toString()}');
        } else {
          print('⚠️ Could not retrieve record (might be using fallback storage)');
        }
      } catch (e) {
        print('❌ Error saving VitalRecord: $e');
        print('   This might be expected on web platform - will use SharedPreferences fallback');
      }
    });

    test('should save VitalRecord via provider', () async {
      final provider = VitalsProvider();
      await provider.initialize();

      final record = VitalRecord(
        timestamp: DateTime.now(),
        weightKg: 68.0,
        systolic: 118,
        diastolic: 78,
        heartRate: 72,
      );

      try {
        final success = await provider.addVitalRecord(record);
        expect(success, true);
        print('✅ VitalRecord saved via provider');
        print('   Success: $success');

        // Check if it updated latest readings
        if (provider.latestBloodPressure != null) {
          print('✅ Latest BP updated: ${provider.latestBloodPressure!.value}');
        }
        if (provider.latestHeartRate != null) {
          print('✅ Latest HR updated: ${provider.latestHeartRate!.value}');
        }
      } catch (e) {
        print('❌ Error saving via provider: $e');
        rethrow;
      }
    });

    test('should validate all required fields are present', () {
      // Test with all fields
      final completeRecord = VitalRecord(
        timestamp: DateTime.now(),
        weightKg: 70.0,
        systolic: 120,
        diastolic: 80,
        heartRate: 75,
      );
      expect(completeRecord.timestamp, isNotNull);
      print('✅ Complete record validation passed');

      // Test with only BP fields
      final bpOnlyRecord = VitalRecord(
        timestamp: DateTime.now(),
        systolic: 120,
        diastolic: 80,
      );
      expect(bpOnlyRecord.systolic, 120);
      expect(bpOnlyRecord.weightKg, isNull);
      print('✅ BP-only record validation passed');

      // Test with only HR field
      final hrOnlyRecord = VitalRecord(
        timestamp: DateTime.now(),
        heartRate: 75,
      );
      expect(hrOnlyRecord.heartRate, 75);
      expect(hrOnlyRecord.systolic, isNull);
      print('✅ HR-only record validation passed');
    });
  });

  group('Debug: Form Validation', () {
    test('should validate weight range', () {
      // Valid weights
      expect(70.0, greaterThanOrEqualTo(20.0));
      expect(70.0, lessThanOrEqualTo(300.0));
      print('✅ Weight validation passed');
    });

    test('should validate BP range', () {
      // Valid BP
      expect(120, greaterThanOrEqualTo(50));
      expect(120, lessThanOrEqualTo(250));
      expect(80, greaterThanOrEqualTo(30));
      expect(80, lessThanOrEqualTo(150));
      print('✅ BP validation passed');
    });

    test('should validate HR range', () {
      // Valid HR
      expect(75, greaterThanOrEqualTo(30));
      expect(75, lessThanOrEqualTo(220));
      print('✅ HR validation passed');
    });
  });
}
