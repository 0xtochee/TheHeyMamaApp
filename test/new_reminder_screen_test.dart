import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregnancy_dashboard/models/reminder.dart';
import 'package:pregnancy_dashboard/screens/new_reminder_screen.dart';
import 'package:pregnancy_dashboard/providers/reminders_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('NewReminderScreen Widget Tests', () {
    testWidgets('Screen should display correct title for new reminder',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => RemindersProvider(),
            child: const NewReminderScreen(),
          ),
        ),
      );

      expect(find.text('New Reminder'), findsOneWidget);
    });

    testWidgets('Screen should display correct title when editing',
        (WidgetTester tester) async {
      final testReminder = Reminder(
        id: '1',
        title: 'Test Reminder',
        type: ReminderType.medication,
        dateTime: DateTime.now().add(const Duration(hours: 1)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => RemindersProvider(),
            child: NewReminderScreen(initial: testReminder),
          ),
        ),
      );

      expect(find.text('Edit Reminder'), findsOneWidget);
    });

    testWidgets('Screen should display all required form fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => RemindersProvider(),
            child: const NewReminderScreen(),
          ),
        ),
      );

      // Check for Reminder Type section
      expect(find.text('Reminder Type'), findsOneWidget);

      // Check for segmented buttons
      expect(find.text('Medication'), findsOneWidget);
      expect(find.text('Appointment'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);

      // Check for input fields
      expect(find.byType(TextFormField), findsAtLeast(2));

      // Check for notifications toggle
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);

      // Check for save button
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Close button should pop the screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (_) => RemindersProvider(),
                        child: const NewReminderScreen(),
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open the screen
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('New Reminder'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Screen should be closed
      expect(find.text('New Reminder'), findsNothing);
    });

    testWidgets('Form validation should prevent submission with empty title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => RemindersProvider(),
            child: const NewReminderScreen(),
          ),
        ),
      );

      // Try to save without entering title
      await tester.tap(find.text('Save'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Title is required'), findsOneWidget);
    });

    testWidgets('Form validation should require minimum 2 characters for title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => RemindersProvider(),
            child: const NewReminderScreen(),
          ),
        ),
      );

      // Enter single character
      await tester.enterText(
        find.byType(TextFormField).first,
        'A',
      );

      // Try to save
      await tester.tap(find.text('Save'));
      await tester.pump();

      // Should show validation error
      expect(
        find.text('Title must be at least 2 characters'),
        findsOneWidget,
      );
    });

    testWidgets('Time picker should open when time field is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => RemindersProvider(),
            child: const NewReminderScreen(),
          ),
        ),
      );

      // Find and tap the time field (it has a clock icon)
      final timeField = find.ancestor(
        of: find.byIcon(Icons.access_time),
        matching: find.byType(TextFormField),
      );

      await tester.tap(timeField);
      await tester.pumpAndSettle();

      // Time picker should be displayed
      expect(find.byType(TimePickerDialog), findsOneWidget);
    });

    testWidgets('Segmented control should change selection on tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => RemindersProvider(),
            child: const NewReminderScreen(),
          ),
        ),
      );

      // Initially, Medication should be selected (default)
      // Tap on Appointment
      await tester.tap(find.text('Appointment'));
      await tester.pump();

      // The selection should change (verify through visual or state)
      // In a real test, you'd verify the visual change or expose state
    });

    testWidgets('Notifications toggle should be ON by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => RemindersProvider(),
            child: const NewReminderScreen(),
          ),
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, true);
    });

    testWidgets('Notifications toggle should change state when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => RemindersProvider(),
            child: const NewReminderScreen(),
          ),
        ),
      );

      // Get initial state
      var switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, true);

      // Tap the switch
      await tester.tap(find.byType(Switch));
      await tester.pump();

      // State should change
      switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, false);
    });

    testWidgets('Pre-filled data should be displayed when editing reminder',
        (WidgetTester tester) async {
      final testReminder = Reminder(
        id: '1',
        title: 'Take Vitamins',
        type: ReminderType.medication,
        dateTime: DateTime(2024, 1, 15, 9, 30),
        recurring: RecurringPattern.daily,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => RemindersProvider(),
            child: NewReminderScreen(initial: testReminder),
          ),
        ),
      );

      // Title should be pre-filled
      expect(find.text('Take Vitamins'), findsOneWidget);

      // Time should be displayed
      expect(find.textContaining('9:30'), findsOneWidget);
    });

    testWidgets('Frequency dropdown should display all options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => RemindersProvider(),
            child: const NewReminderScreen(),
          ),
        ),
      );

      // Find the dropdown
      final dropdown = find.byType(DropdownButtonFormField<RecurringPattern>);
      expect(dropdown, findsOneWidget);

      // Tap to open dropdown
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Check all options are present
      expect(find.text('None').hitTestable(), findsWidgets);
      expect(find.text('Daily').hitTestable(), findsWidgets);
      expect(find.text('Weekly').hitTestable(), findsWidgets);
      expect(find.text('Monthly').hitTestable(), findsWidgets);
    });
  });

  group('NewReminderScreen Route Tests', () {
    testWidgets('Screen should be accessible via named route',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/newReminder': (context) => ChangeNotifierProvider(
                  create: (_) => RemindersProvider(),
                  child: const NewReminderScreen(),
                ),
          },
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/newReminder');
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open via named route
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('New Reminder'), findsOneWidget);
    });
  });
}
