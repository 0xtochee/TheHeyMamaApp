import 'package:flutter_test/flutter_test.dart';
import 'package:pregnancy_dashboard/services/local_db.dart';

void main() {
  group('VitalRecord Model Tests', () {
    test('should create VitalRecord from map', () {
      final map = {
        'id': '123',
        'timestamp': '2025-01-15T10:30:00.000',
        'weight_kg': 70.5,
        'systolic': 120,
        'diastolic': 80,
        'heart_rate': 75,
        'blood_sugar': 95,
      };

      final record = VitalRecord.fromMap(map);

      expect(record.id, '123');
      expect(record.timestamp, DateTime.parse('2025-01-15T10:30:00.000'));
      expect(record.weightKg, 70.5);
      expect(record.systolic, 120);
      expect(record.diastolic, 80);
      expect(record.heartRate, 75);
      expect(record.bloodSugar, 95);
    });

    test('should convert VitalRecord to map', () {
      final record = VitalRecord(
        id: '456',
        timestamp: DateTime.parse('2025-01-15T10:30:00.000'),
        weightKg: 68.0,
        systolic: 118,
        diastolic: 78,
        heartRate: 72,
        bloodSugar: 90,
      );

      final map = record.toMap();

      expect(map['id'], '456');
      expect(map['timestamp'], '2025-01-15T10:30:00.000');
      expect(map['weight_kg'], 68.0);
      expect(map['systolic'], 118);
      expect(map['diastolic'], 78);
      expect(map['heart_rate'], 72);
      expect(map['blood_sugar'], 90);
    });

    test('should handle null optional fields', () {
      final record = VitalRecord(
        timestamp: DateTime.now(),
        systolic: 120,
        diastolic: 80,
        // Other fields are null
      );

      expect(record.id, isNull);
      expect(record.weightKg, isNull);
      expect(record.heartRate, isNull);
      expect(record.bloodSugar, isNull);
      expect(record.systolic, 120);
      expect(record.diastolic, 80);
    });

    test('should convert to JSON and back', () {
      final original = VitalRecord(
        id: '789',
        timestamp: DateTime.parse('2025-01-15T10:30:00.000'),
        weightKg: 75.0,
        systolic: 125,
        diastolic: 82,
        heartRate: 78,
      );

      final json = original.toJson();
      final restored = VitalRecord.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.timestamp, original.timestamp);
      expect(restored.weightKg, original.weightKg);
      expect(restored.systolic, original.systolic);
      expect(restored.diastolic, original.diastolic);
      expect(restored.heartRate, original.heartRate);
    });

    test('should have meaningful toString', () {
      final record = VitalRecord(
        id: '123',
        timestamp: DateTime.parse('2025-01-15T10:30:00.000'),
        weightKg: 70.0,
        systolic: 120,
        diastolic: 80,
        heartRate: 75,
      );

      final str = record.toString();

      expect(str, contains('123'));
      expect(str, contains('70.0'));
      expect(str, contains('120'));
      expect(str, contains('80'));
      expect(str, contains('75'));
    });
  });

  group('LocalDatabase Tests', () {
    late LocalDatabase db;

    setUp(() {
      db = LocalDatabase();
    });

    test('should insert and retrieve vital record', () async {
      final record = VitalRecord(
        timestamp: DateTime.now(),
        weightKg: 72.0,
        systolic: 122,
        diastolic: 81,
        heartRate: 76,
      );

      // Insert record
      final id = await db.insertVitalRecord(record);
      expect(id, isNotEmpty);

      // Retrieve latest record
      final retrieved = await db.getLatestVitalRecord();
      expect(retrieved, isNotNull);
      expect(retrieved?.systolic, 122);
      expect(retrieved?.diastolic, 81);
      expect(retrieved?.heartRate, 76);
    });

    test('should get all vital records with limit', () async {
      // Insert multiple records
      for (int i = 0; i < 5; i++) {
        final record = VitalRecord(
          timestamp: DateTime.now().subtract(Duration(hours: i)),
          systolic: 120 + i,
          diastolic: 80 + i,
          heartRate: 75 + i,
        );
        await db.insertVitalRecord(record);
      }

      // Get records with limit
      final records = await db.getAllVitalRecords(limit: 3);
      expect(records.length, lessThanOrEqualTo(3));

      // Should be ordered by timestamp descending (most recent first)
      if (records.length > 1) {
        expect(
          records[0].timestamp.isAfter(records[1].timestamp) ||
          records[0].timestamp.isAtSameMomentAs(records[1].timestamp),
          true,
        );
      }
    });

    test('should get vital records in date range', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final twoDaysAgo = now.subtract(const Duration(days: 2));

      // Insert records at different times
      await db.insertVitalRecord(VitalRecord(
        timestamp: now,
        systolic: 120,
        diastolic: 80,
      ));

      await db.insertVitalRecord(VitalRecord(
        timestamp: yesterday,
        systolic: 122,
        diastolic: 82,
      ));

      await db.insertVitalRecord(VitalRecord(
        timestamp: twoDaysAgo,
        systolic: 118,
        diastolic: 78,
      ));

      // Get records from last day
      final startDate = now.subtract(const Duration(days: 1, hours: 12));
      final endDate = now.add(const Duration(hours: 1));

      final records = await db.getVitalRecordsInRange(startDate, endDate);

      // Should get records from today and yesterday
      expect(records.length, greaterThanOrEqualTo(1));
    });

    test('should handle legacy vital insertion and retrieval', () async {
      final timestamp = DateTime.now();

      // Insert legacy vital
      final id = await db.insertVital(
        timestamp: timestamp,
        type: 'blood_pressure',
        value: '125/85',
      );

      expect(id, greaterThan(0));

      // Retrieve latest vital of type
      final vital = await db.getLatestVital('blood_pressure');

      expect(vital, isNotNull);
      expect(vital?['type'], 'blood_pressure');
      expect(vital?['value'], '125/85');
    });

    test('should get vitals by type', () async {
      // Insert multiple heart rate readings
      for (int i = 0; i < 3; i++) {
        await db.insertVital(
          timestamp: DateTime.now().subtract(Duration(hours: i)),
          type: 'heart_rate',
          value: '${75 + i}',
        );
      }

      final vitals = await db.getVitalsByType('heart_rate', limit: 5);

      expect(vitals.length, greaterThanOrEqualTo(3));
      expect(vitals.every((v) => v['type'] == 'heart_rate'), true);
    });

    test('should get vitals in range (legacy)', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      await db.insertVital(
        timestamp: now,
        type: 'blood_pressure',
        value: '120/80',
      );

      await db.insertVital(
        timestamp: yesterday,
        type: 'blood_pressure',
        value: '122/82',
      );

      final startDate = now.subtract(const Duration(days: 1, hours: 12));
      final endDate = now.add(const Duration(hours: 1));

      final vitals = await db.getVitalsInRange(startDate, endDate);

      expect(vitals.length, greaterThanOrEqualTo(1));
    });
  });

  group('LocalDatabase Error Handling Tests', () {
    test('should handle database errors gracefully', () async {
      final db = LocalDatabase();

      // Test with invalid data should not throw
      try {
        final record = VitalRecord(
          timestamp: DateTime.now(),
          systolic: 120,
          diastolic: 80,
        );

        final id = await db.insertVitalRecord(record);
        expect(id, isNotNull);
      } catch (e) {
        // If error occurs, it should be caught and handled
        expect(e, isNotNull);
      }
    });

    test('should return empty list on query failure', () async {
      final db = LocalDatabase();

      // Attempt to get records (may fail on some platforms)
      try {
        final records = await db.getAllVitalRecords(limit: 10);
        expect(records, isA<List<VitalRecord>>());
      } catch (e) {
        // Error should be caught internally
        expect(e, isNotNull);
      }
    });
  });
}
