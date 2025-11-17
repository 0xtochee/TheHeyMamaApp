# AddVitalsScreen Integration Guide

This guide demonstrates how to integrate and use the `AddVitalsScreen` feature in your Flutter pregnancy monitoring app.

## Table of Contents

- [Overview](#overview)
- [Navigation](#navigation)
- [Provider Configuration](#provider-configuration)
- [Persistence Layer](#persistence-layer)
- [Customization](#customization)
- [Testing](#testing)

## Overview

The `AddVitalsScreen` is a production-ready screen for logging comprehensive vital sign readings including:

- **Weight** (with interactive slider, 20-300 kg range)
- **Blood Pressure** (systolic/diastolic with validation)
- **Heart Rate** (with interactive slider, 30-220 bpm range)
- **Date & Time** (with built-in pickers)

### Key Features

- ✅ Form validation with inline error messages
- ✅ 2-way binding between sliders and text fields
- ✅ Automatic alert generation for abnormal readings
- ✅ Accessibility support (semantic labels, min touch targets)
- ✅ Keyboard dismissal on tap outside
- ✅ SQLite persistence with SharedPreferences fallback
- ✅ Loading states and error handling

## Navigation

### Basic Navigation

Navigate to the AddVitalsScreen from anywhere in your app:

```dart
// Navigate to AddVitalsScreen
final result = await Navigator.pushNamed(context, '/add-vitals');

// Check if vitals were saved
if (result != null && result is VitalRecord) {
  print('Saved vital record: ${result.toString()}');
  // Refresh your UI or perform other actions
}
```

### Programmatic Navigation with Initial Values

You can pre-populate the screen with existing values for editing:

```dart
import 'package:pregnancy_dashboard/screens/add_vitals_screen.dart';
import 'package:pregnancy_dashboard/services/local_db.dart';

// Navigate with initial values
final initialRecord = VitalRecord(
  timestamp: DateTime.now(),
  weightKg: 70.0,
  systolic: 120,
  diastolic: 80,
  heartRate: 75,
);

final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AddVitalsScreen(
      initialValues: initialRecord,
    ),
  ),
);
```

### Integration in Dashboard

Example integration in your dashboard's "Log Vital" button:

```dart
import 'package:provider/provider.dart';
import 'package:pregnancy_dashboard/providers/vitals_provider.dart';

ElevatedButton(
  onPressed: () async {
    // Navigate to AddVitalsScreen
    final result = await Navigator.pushNamed(context, '/add-vitals');

    // Refresh vitals if saved successfully
    if (result != null && mounted) {
      context.read<VitalsProvider>().loadLatestVitals();
    }
  },
  child: const Text('Log Vitals'),
)
```

## Provider Configuration

### Alert Threshold Configuration

Customize alert thresholds for your specific use case:

```dart
import 'package:provider/provider.dart';
import 'package:pregnancy_dashboard/providers/vitals_provider.dart';

// In your widget or initialization code
final provider = context.read<VitalsProvider>();

// Configure blood pressure thresholds
provider.setBpThreshold(
  systolic: 140,  // Alert if systolic >= 140 mmHg
  diastolic: 90,  // Alert if diastolic >= 90 mmHg
);

// Configure heart rate thresholds
provider.setHeartRateThreshold(
  min: 60,  // Alert if heart rate <= 60 bpm
  max: 100, // Alert if heart rate >= 100 bpm
);
```

### Using Constants

Alternatively, use predefined constants from `lib/constants/ui_constants.dart`:

```dart
import 'package:pregnancy_dashboard/constants/ui_constants.dart';

// Access alert thresholds
print('BP Systolic High: ${AlertThresholds.bpSystolicHigh}');
print('HR High: ${AlertThresholds.heartRateHigh}');

// Check if reading is in alert range
final isAlert = AlertThresholds.isBPAlert(145, 95);
print('Is BP alert: $isAlert');

// Get status message
final message = AlertThresholds.getBPStatusMessage(145, 95);
print('BP Status: $message');
```

### Accessing Vital Records

```dart
import 'package:pregnancy_dashboard/providers/vitals_provider.dart';

// Get latest vital record
final provider = context.read<VitalsProvider>();
final latest = await provider.getLatestVitalRecord();

if (latest != null) {
  print('Weight: ${latest.weightKg} kg');
  print('BP: ${latest.systolic}/${latest.diastolic} mmHg');
  print('HR: ${latest.heartRate} bpm');
}

// Get all vital records (last 100)
final records = await provider.getAllVitalRecords(limit: 100);
print('Total records: ${records.length}');
```

## Persistence Layer

### Direct Database Access

For advanced use cases, access the database directly:

```dart
import 'package:pregnancy_dashboard/services/local_db.dart';

final db = LocalDatabase();

// Insert a vital record
final record = VitalRecord(
  timestamp: DateTime.now(),
  weightKg: 72.5,
  systolic: 125,
  diastolic: 82,
  heartRate: 78,
  bloodSugar: 95, // Optional blood sugar field
);

final recordId = await db.insertVitalRecord(record);
print('Saved with ID: $recordId');

// Query records in a date range
final startDate = DateTime.now().subtract(const Duration(days: 7));
final endDate = DateTime.now();

final weeklyRecords = await db.getVitalRecordsInRange(startDate, endDate);
print('Records this week: ${weeklyRecords.length}');
```

### Fallback Persistence

The database automatically falls back to SharedPreferences if SQLite fails (e.g., on web platforms):

```dart
// No special handling needed - fallback is automatic
// Both methods work identically from your perspective

final record = VitalRecord(/* ... */);
await db.insertVitalRecord(record); // Auto-handles SQLite or SharedPreferences
```

### Legacy Compatibility

Support for legacy single-value vitals:

```dart
final db = LocalDatabase();

// Insert legacy blood pressure reading
await db.insertVital(
  timestamp: DateTime.now(),
  type: 'blood_pressure',
  value: '120/80',
);

// Get latest legacy reading
final latest = await db.getLatestVital('blood_pressure');
print('Latest BP: ${latest?['value']}');
```

## Customization

### UI Constants

Customize colors, dimensions, and validation limits in `lib/constants/ui_constants.dart`:

```dart
// Example: Adjust weight limits for your region
class VitalLimits {
  static const double weightMin = 30.0;  // Changed from 20.0
  static const double weightMax = 250.0; // Changed from 300.0

  // Other limits remain the same...
}

// Example: Customize colors
class AppColors {
  static const Color primaryBlue = Color(0xFF0066CC); // Your brand color
  // ...
}
```

### Custom Validation

Add custom validation to the RoundedTextField:

```dart
import 'package:pregnancy_dashboard/widgets/rounded_text_field.dart';

NumericTextField(
  controller: myController,
  labelText: 'Custom Field',
  minValue: 0,
  maxValue: 100,
  validator: (value) {
    // Add custom validation logic
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final num = double.tryParse(value);
    if (num != null && num < 10) {
      return 'Value must be at least 10';
    }

    return null; // Valid
  },
)
```

### Extending VitalRecord

Add custom fields to VitalRecord model in `lib/services/local_db.dart`:

```dart
class VitalRecord {
  final String? id;
  final DateTime timestamp;
  final double? weightKg;
  final int? systolic;
  final int? diastolic;
  final int? heartRate;
  final int? bloodSugar;

  // Add your custom fields
  final double? oxygenSaturation; // NEW
  final double? temperature;      // NEW

  VitalRecord({
    this.id,
    required this.timestamp,
    this.weightKg,
    this.systolic,
    this.diastolic,
    this.heartRate,
    this.bloodSugar,
    this.oxygenSaturation, // NEW
    this.temperature,      // NEW
  });

  // Update fromMap and toMap methods accordingly
  // ...
}
```

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/add_vitals_screen_test.dart

# Run with coverage
flutter test --coverage
```

### Widget Tests

Example widget test for AddVitalsScreen:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pregnancy_dashboard/screens/add_vitals_screen.dart';

testWidgets('should save vitals when form is valid', (WidgetTester tester) async {
  // Build the screen
  await tester.pumpWidget(createTestWidget());

  // Fill in form fields
  await tester.enterText(find.byType(NumericTextField).at(0), '70');
  await tester.enterText(find.byType(NumericTextField).at(1), '120');
  await tester.enterText(find.byType(NumericTextField).at(2), '80');
  await tester.enterText(find.byType(NumericTextField).at(3), '75');

  // Tap save button
  await tester.tap(find.text('Save Vitals'));
  await tester.pumpAndSettle();

  // Verify success
  expect(find.text('Vitals saved successfully!'), findsOneWidget);
});
```

### Integration Tests

Example integration test:

```dart
testWidgets('full vital logging workflow', (WidgetTester tester) async {
  // Start at dashboard
  await tester.pumpWidget(MyApp());

  // Tap log vitals button
  await tester.tap(find.text('Log Vital'));
  await tester.pumpAndSettle();

  // Verify AddVitalsScreen opened
  expect(find.text('Log Vitals'), findsOneWidget);

  // Fill and save
  // ... (fill form fields)

  await tester.tap(find.text('Save Vitals'));
  await tester.pumpAndSettle();

  // Verify back on dashboard
  expect(find.byType(PregnancyDashboardScreen), findsOneWidget);
});
```

## Best Practices

### 1. Always Check Mounted State

```dart
void _handleLogVital() async {
  final result = await Navigator.pushNamed(context, '/add-vitals');

  if (!mounted) return; // Important!

  if (result != null) {
    // Safe to use context here
    context.read<VitalsProvider>().loadLatestVitals();
  }
}
```

### 2. Handle Errors Gracefully

```dart
try {
  final record = VitalRecord(/* ... */);
  final success = await provider.addVitalRecord(record);

  if (success) {
    // Show success message
  } else {
    // Show error message
  }
} catch (e) {
  // Log error and show user-friendly message
  debugPrint('Error saving vitals: $e');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to save vitals. Please try again.')),
  );
}
```

### 3. Provide User Feedback

```dart
// Always show feedback after actions
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 12),
        Text('Vitals saved successfully!'),
      ],
    ),
    backgroundColor: AppColors.successGreen,
    duration: Duration(seconds: 2),
  ),
);
```

## Troubleshooting

### Common Issues

**Issue**: Sliders not syncing with text fields

**Solution**: Ensure controllers have listeners and setState is called:

```dart
_weightController.addListener(() {
  final value = double.tryParse(_weightController.text);
  if (value != null && value != _weight) {
    setState(() => _weight = value);
  }
});
```

**Issue**: Database errors on web platform

**Solution**: Database automatically falls back to SharedPreferences on web. No action needed.

**Issue**: Form validation not triggering

**Solution**: Ensure Form widget wraps your fields and you call `formKey.currentState!.validate()`:

```dart
if (!_formKey.currentState!.validate()) {
  return; // Don't proceed if invalid
}
```

## Additional Resources

- [Flutter Form Validation](https://docs.flutter.dev/cookbook/forms/validation)
- [Provider State Management](https://pub.dev/packages/provider)
- [SQFlite Documentation](https://pub.dev/packages/sqflite)
- [Accessibility in Flutter](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)

## Support

For issues or questions:
1. Check the test files for usage examples
2. Review the inline code documentation
3. Consult this integration guide

---

**Version**: 1.0.0
**Last Updated**: January 2025
**Compatibility**: Flutter 3.0+, Dart 3.0+
