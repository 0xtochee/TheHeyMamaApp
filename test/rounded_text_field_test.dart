import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregnancy_dashboard/widgets/rounded_text_field.dart';

void main() {
  group('RoundedTextField Widget Tests', () {
    testWidgets('should render with basic properties', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoundedTextField(
              controller: controller,
              labelText: 'Test Label',
              hintText: 'Test Hint',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);

      controller.dispose();
    });

    testWidgets('should validate input when validator is provided', (WidgetTester tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: RoundedTextField(
                controller: controller,
                labelText: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Trigger validation without entering text
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('should call onChanged when text changes', (WidgetTester tester) async {
      final controller = TextEditingController();
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoundedTextField(
              controller: controller,
              labelText: 'Test',
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test input');
      expect(changedValue, 'test input');

      controller.dispose();
    });

    testWidgets('should be disabled when enabled is false', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoundedTextField(
              controller: controller,
              labelText: 'Disabled Field',
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, false);

      controller.dispose();
    });
  });

  group('NumericTextField Widget Tests', () {
    testWidgets('should validate numeric input', (WidgetTester tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: NumericTextField(
                controller: controller,
                labelText: 'Age',
                minValue: 0,
                maxValue: 150,
              ),
            ),
          ),
        ),
      );

      // Test with invalid input (empty)
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('This field is required'), findsOneWidget);

      // Test with valid input
      await tester.enterText(find.byType(TextFormField), '25');
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('This field is required'), findsNothing);

      controller.dispose();
    });

    testWidgets('should enforce min and max values', (WidgetTester tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: NumericTextField(
                controller: controller,
                labelText: 'Weight',
                minValue: 20,
                maxValue: 300,
              ),
            ),
          ),
        ),
      );

      // Test below minimum
      await tester.enterText(find.byType(TextFormField), '10');
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.textContaining('at least'), findsOneWidget);

      // Test above maximum
      await tester.enterText(find.byType(TextFormField), '500');
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.textContaining('at most'), findsOneWidget);

      // Test valid value
      await tester.enterText(find.byType(TextFormField), '70');
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.textContaining('at least'), findsNothing);
      expect(find.textContaining('at most'), findsNothing);

      controller.dispose();
    });

    testWidgets('should display unit when provided', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericTextField(
              controller: controller,
              labelText: 'Weight',
              unit: 'kg',
            ),
          ),
        ),
      );

      expect(find.text('kg'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('should only allow decimal input when allowDecimals is true', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericTextField(
              controller: controller,
              labelText: 'Weight',
              allowDecimals: true,
            ),
          ),
        ),
      );

      // Enter decimal value
      await tester.enterText(find.byType(TextFormField), '70.5');
      expect(controller.text, '70.5');

      controller.dispose();
    });
  });
}
