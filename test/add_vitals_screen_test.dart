import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pregnancy_dashboard/screens/add_vitals_screen.dart';
import 'package:pregnancy_dashboard/providers/vitals_provider.dart';
import 'package:pregnancy_dashboard/widgets/rounded_text_field.dart';

void main() {
  group('AddVitalsScreen Widget Tests', () {
    late VitalsProvider mockProvider;

    setUp(() {
      mockProvider = VitalsProvider();
    });

    Widget createTestWidget({Widget? child}) {
      return ChangeNotifierProvider<VitalsProvider>.value(
        value: mockProvider,
        child: MaterialApp(
          home: child ?? const AddVitalsScreen(),
        ),
      );
    }

    testWidgets('should render all required form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify header
      expect(find.text('Log Vitals'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Verify sections
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Blood Pressure'), findsOneWidget);
      expect(find.text('Heart Rate'), findsOneWidget);
      expect(find.text('Date & Time'), findsOneWidget);

      // Verify form fields
      expect(find.byType(NumericTextField), findsNWidgets(4)); // Weight, Systolic, Diastolic, Heart Rate
      expect(find.byType(Slider), findsNWidgets(2)); // Weight and Heart Rate sliders

      // Verify save button
      expect(find.text('Save Vitals'), findsOneWidget);
    });

    testWidgets('should close screen when close button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Screen should be popped
      expect(find.byType(AddVitalsScreen), findsNothing);
    });

    testWidgets('weight slider and text field should sync bidirectionally', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find weight text field
      final weightFields = find.byType(NumericTextField);
      final weightField = weightFields.first;

      // Initially should have default value (70kg)
      final initialController = tester.widget<NumericTextField>(weightField).controller;
      expect(initialController?.text, '70');

      // Change slider value
      final slider = find.byType(Slider).first;
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Text field should update (value will change based on drag)
      // Note: Exact value depends on slider position, just verify it changed
      expect(initialController?.text, isNot('70'));

      // Now change text field
      await tester.enterText(weightField, '85');
      await tester.pumpAndSettle();

      // Slider should update to match
      final sliderWidget = tester.widget<Slider>(slider);
      expect(sliderWidget.value.round(), 85);
    });

    testWidgets('heart rate slider and text field should sync bidirectionally', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find heart rate text field (4th numeric field)
      final hrField = find.byType(NumericTextField).at(3);
      final hrSlider = find.byType(Slider).at(1);

      // Change text field
      await tester.enterText(hrField, '90');
      await tester.pumpAndSettle();

      // Slider should update
      final sliderWidget = tester.widget<Slider>(hrSlider);
      expect(sliderWidget.value.round(), 90);
    });

    testWidgets('should show validation errors when form is submitted empty', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap save button without filling form
      await tester.tap(find.text('Save Vitals'));
      await tester.pumpAndSettle();

      // Should show error snackbar
      expect(find.text('Please correct the errors in the form'), findsOneWidget);
    });

    testWidgets('date picker should update date field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find and tap date field
      final dateField = find.byIcon(Icons.calendar_today);
      await tester.tap(dateField);
      await tester.pumpAndSettle();

      // Date picker should be shown
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // Tap OK button (confirm current date)
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Date field should be populated
      final dateTextFields = tester.widgetList<TextFormField>(find.byType(TextFormField));
      final dateTextField = dateTextFields.toList()[4]; // Date field is 5th
      expect(dateTextField.controller?.text, isNotEmpty);
    });

    testWidgets('time picker should update time field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find and tap time field
      final timeField = find.byIcon(Icons.access_time);
      await tester.tap(timeField);
      await tester.pumpAndSettle();

      // Time picker should be shown
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // Tap OK button
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Time field should be populated
      final timeTextFields = tester.widgetList<TextFormField>(find.byType(TextFormField));
      final timeTextField = timeTextFields.toList()[5]; // Time field is 6th
      expect(timeTextField.controller?.text, isNotEmpty);
    });

    testWidgets('should dismiss keyboard when tapping outside fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Focus on a text field
      final weightField = find.byType(NumericTextField).first;
      await tester.tap(weightField);
      await tester.pumpAndSettle();

      // Tap outside (on the scaffold)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Focus should be removed (keyboard dismissed)
      expect(FocusManager.instance.primaryFocus?.hasFocus, isFalse);
    });

    testWidgets('should validate blood pressure values within limits', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final formKey = find.byType(Form);
      expect(formKey, findsOneWidget);

      // Enter invalid systolic (too high)
      final systolicField = find.byType(NumericTextField).at(1);
      await tester.enterText(systolicField, '300');

      // Trigger validation
      await tester.tap(find.text('Save Vitals'));
      await tester.pumpAndSettle();

      // Should show error
      expect(find.textContaining('at most'), findsWidgets);
    });

    testWidgets('should show loading indicator when saving', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Fill in required fields
      await tester.enterText(find.byType(NumericTextField).at(0), '70'); // Weight
      await tester.enterText(find.byType(NumericTextField).at(1), '120'); // Systolic
      await tester.enterText(find.byType(NumericTextField).at(2), '80'); // Diastolic
      await tester.enterText(find.byType(NumericTextField).at(3), '75'); // Heart Rate

      // Tap save button
      await tester.tap(find.text('Save Vitals'));
      await tester.pump(); // Start the async operation

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('AddVitalsScreen Integration Tests', () {
    testWidgets('should save vitals and close screen on success', (WidgetTester tester) async {
      final provider = VitalsProvider();
      await provider.initialize();

      await tester.pumpWidget(
        ChangeNotifierProvider<VitalsProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: AddVitalsScreen(),
          ),
        ),
      );

      // Fill in all required fields
      await tester.enterText(find.byType(NumericTextField).at(0), '75'); // Weight
      await tester.enterText(find.byType(NumericTextField).at(1), '125'); // Systolic
      await tester.enterText(find.byType(NumericTextField).at(2), '82'); // Diastolic
      await tester.enterText(find.byType(NumericTextField).at(3), '78'); // Heart Rate

      // Tap save button
      await tester.tap(find.text('Save Vitals'));
      await tester.pumpAndSettle();

      // Should show success snackbar
      expect(find.text('Vitals saved successfully!'), findsOneWidget);

      // Screen should be closed
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byType(AddVitalsScreen), findsNothing);
    });
  });
}
