import 'package:flutter/material.dart';
import '../services/local_db.dart';

/// Utility to add sample vitals data for testing
///
/// Call this from your app to populate sample data:
/// ```dart
/// await addSampleVitalsData();
/// ```
Future<void> addSampleVitalsData() async {
  final db = LocalDatabase();

  // Add sample data for the last 7 days
  final now = DateTime.now();

  final sampleData = [
    // 7 days ago
    VitalRecord(
      timestamp: now.subtract(const Duration(days: 6)),
      weightKg: 68.5,
      systolic: 115,
      diastolic: 75,
      heartRate: 72,
      bloodSugar: 92,
    ),
    // 6 days ago
    VitalRecord(
      timestamp: now.subtract(const Duration(days: 5)),
      weightKg: 69.0,
      systolic: 118,
      diastolic: 76,
      heartRate: 74,
      bloodSugar: 95,
    ),
    // 5 days ago
    VitalRecord(
      timestamp: now.subtract(const Duration(days: 4)),
      weightKg: 68.8,
      systolic: 120,
      diastolic: 78,
      heartRate: 76,
      bloodSugar: 88,
    ),
    // 4 days ago
    VitalRecord(
      timestamp: now.subtract(const Duration(days: 3)),
      weightKg: 69.5,
      systolic: 122,
      diastolic: 80,
      heartRate: 75,
      bloodSugar: 90,
    ),
    // 3 days ago
    VitalRecord(
      timestamp: now.subtract(const Duration(days: 2)),
      weightKg: 69.8,
      systolic: 119,
      diastolic: 77,
      heartRate: 73,
      bloodSugar: 93,
    ),
    // 2 days ago
    VitalRecord(
      timestamp: now.subtract(const Duration(days: 1)),
      weightKg: 70.2,
      systolic: 121,
      diastolic: 79,
      heartRate: 77,
      bloodSugar: 91,
    ),
    // Today
    VitalRecord(
      timestamp: now,
      weightKg: 70.5,
      systolic: 123,
      diastolic: 81,
      heartRate: 78,
      bloodSugar: 94,
    ),
  ];

  debugPrint('[SampleData] Adding ${sampleData.length} sample records...');

  for (var i = 0; i < sampleData.length; i++) {
    final record = sampleData[i];
    try {
      final id = await db.insertVitalRecord(record);
      debugPrint('[SampleData] Added record ${i + 1}/${sampleData.length}: ID=$id, Weight=${record.weightKg}kg, BP=${record.systolic}/${record.diastolic}');
    } catch (e) {
      debugPrint('[SampleData] Failed to add record ${i + 1}: $e');
    }
  }

  debugPrint('[SampleData] ✅ Sample data added successfully!');
  debugPrint('[SampleData] Navigate to Track screen to see the charts.');
}

/// Widget to add a debug button for adding sample data
class AddSampleDataButton extends StatelessWidget {
  const AddSampleDataButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          await addSampleVitalsData();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Sample data added! Go to Track screen to see charts.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      icon: const Icon(Icons.data_array),
      label: const Text('Add Sample Data'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
    );
  }
}
