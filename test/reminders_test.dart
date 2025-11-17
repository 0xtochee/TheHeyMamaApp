import 'package:flutter_test/flutter_test.dart';
import 'package:pregnancy_dashboard/models/reminder.dart';
import 'package:pregnancy_dashboard/providers/reminders_provider.dart';

void main() {
  group('Reminder Model Tests', () {
    test('Reminder should be created with all required fields', () {
      final now = DateTime.now();
      final reminder = Reminder(
        id: '1',
        title: 'Take Medication',
        type: ReminderType.medication,
        dateTime: now,
        recurring: RecurringPattern.daily,
        isCompleted: false,
        notes: 'Take with food',
        iconKey: 'pill',
      );

      expect(reminder.id, '1');
      expect(reminder.title, 'Take Medication');
      expect(reminder.type, ReminderType.medication);
      expect(reminder.dateTime, now);
      expect(reminder.recurring, RecurringPattern.daily);
      expect(reminder.isCompleted, false);
      expect(reminder.notes, 'Take with food');
      expect(reminder.iconKey, 'pill');
    });

    test('Reminder should convert to and from Map correctly', () {
      final now = DateTime.now();
      final reminder = Reminder(
        id: '2',
        title: 'Doctor Appointment',
        type: ReminderType.appointment,
        dateTime: now,
        recurring: RecurringPattern.none,
        isCompleted: false,
        notes: 'Bring medical records',
      );

      final map = reminder.toMap();
      final reconstructed = Reminder.fromMap(map);

      expect(reconstructed.id, reminder.id);
      expect(reconstructed.title, reminder.title);
      expect(reconstructed.type, reminder.type);
      expect(reconstructed.dateTime.millisecondsSinceEpoch,
          reminder.dateTime.millisecondsSinceEpoch);
      expect(reconstructed.recurring, reminder.recurring);
      expect(reconstructed.isCompleted, reminder.isCompleted);
      expect(reconstructed.notes, reminder.notes);
    });

    test('Reminder.copyWith should update specified fields', () {
      final reminder = Reminder(
        id: '3',
        title: 'Original Title',
        type: ReminderType.medication,
        dateTime: DateTime.now(),
      );

      final updated = reminder.copyWith(
        title: 'Updated Title',
        isCompleted: true,
      );

      expect(updated.title, 'Updated Title');
      expect(updated.isCompleted, true);
      expect(updated.id, reminder.id);
      expect(updated.type, reminder.type);
    });

    test('Reminder validation should work correctly', () {
      final validReminder = Reminder(
        id: '4',
        title: 'Valid Reminder',
        type: ReminderType.medication,
        dateTime: DateTime.now(),
      );

      final invalidReminder = Reminder(
        id: '5',
        title: '   ',
        type: ReminderType.medication,
        dateTime: DateTime.now(),
      );

      expect(validReminder.validate(), true);
      expect(invalidReminder.validate(), false);
    });

    test('Reminder.formattedTime should return correct format', () {
      final morning = Reminder(
        id: '6',
        title: 'Morning Reminder',
        type: ReminderType.medication,
        dateTime: DateTime(2024, 1, 15, 9, 30),
      );

      final afternoon = Reminder(
        id: '7',
        title: 'Afternoon Reminder',
        type: ReminderType.medication,
        dateTime: DateTime(2024, 1, 15, 14, 45),
      );

      expect(morning.formattedTime.contains('9:30'), true);
      expect(morning.formattedTime.contains('AM'), true);
      expect(afternoon.formattedTime.contains('2:45'), true);
      expect(afternoon.formattedTime.contains('PM'), true);
    });

    test('Reminder.shouldShow should return correct value', () {
      final futureReminder = Reminder(
        id: '8',
        title: 'Future',
        type: ReminderType.medication,
        dateTime: DateTime.now().add(const Duration(hours: 1)),
        isCompleted: false,
      );

      final completedReminder = Reminder(
        id: '9',
        title: 'Completed',
        type: ReminderType.medication,
        dateTime: DateTime.now().subtract(const Duration(hours: 1)),
        isCompleted: true,
      );

      final recurringReminder = Reminder(
        id: '10',
        title: 'Recurring',
        type: ReminderType.medication,
        dateTime: DateTime.now().subtract(const Duration(hours: 1)),
        recurring: RecurringPattern.daily,
        isCompleted: true,
      );

      expect(futureReminder.shouldShow, true);
      expect(completedReminder.shouldShow, false);
      expect(recurringReminder.shouldShow, true);
    });
  });

  group('ReminderType Tests', () {
    test('ReminderType.displayName should return correct names', () {
      expect(ReminderType.medication.displayName, 'Medication');
      expect(ReminderType.appointment.displayName, 'Appointment');
      expect(ReminderType.other.displayName, 'Other');
    });

    test('ReminderType.fromString should parse correctly', () {
      expect(ReminderType.fromString('medication'), ReminderType.medication);
      expect(ReminderType.fromString('Medication'), ReminderType.medication);
      expect(ReminderType.fromString('MEDICATION'), ReminderType.medication);
      expect(ReminderType.fromString('appointment'), ReminderType.appointment);
      expect(ReminderType.fromString('unknown'), ReminderType.other);
    });
  });

  group('RecurringPattern Tests', () {
    test('RecurringPattern.displayName should return correct names', () {
      expect(RecurringPattern.none.displayName, 'None');
      expect(RecurringPattern.daily.displayName, 'Daily');
      expect(RecurringPattern.weekly.displayName, 'Weekly');
      expect(RecurringPattern.monthly.displayName, 'Monthly');
    });

    test('RecurringPattern.fromString should parse correctly', () {
      expect(RecurringPattern.fromString('daily'), RecurringPattern.daily);
      expect(RecurringPattern.fromString('Daily'), RecurringPattern.daily);
      expect(RecurringPattern.fromString('weekly'), RecurringPattern.weekly);
      expect(RecurringPattern.fromString('monthly'), RecurringPattern.monthly);
      expect(RecurringPattern.fromString(null), RecurringPattern.none);
      expect(RecurringPattern.fromString('unknown'), RecurringPattern.none);
    });
  });

  group('RemindersProvider Tests', () {
    test('RemindersProvider should initialize with empty list', () {
      final provider = RemindersProvider();

      expect(provider.reminders, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('RemindersProvider should filter reminders by type', () {
      final provider = RemindersProvider();

      // Test with empty provider
      expect(provider.remindersByType(ReminderType.medication), isEmpty);
      expect(provider.remindersByType(ReminderType.appointment), isEmpty);
    });

    test('RemindersProvider should get active reminders', () {
      final provider = RemindersProvider();

      expect(provider.activeReminders, isEmpty);
    });

    test('RemindersProvider should get completed reminders', () {
      final provider = RemindersProvider();

      expect(provider.completedReminders, isEmpty);
    });

    test('RemindersProvider should get upcoming reminders', () {
      final provider = RemindersProvider();

      expect(provider.upcomingReminders, isEmpty);
    });

    test('RemindersProvider should get overdue reminders', () {
      final provider = RemindersProvider();

      expect(provider.overdueReminders, isEmpty);
    });

    test('RemindersProvider should get count by type', () {
      final provider = RemindersProvider();

      expect(provider.getCountByType(ReminderType.medication), 0);
      expect(provider.getCountByType(ReminderType.appointment), 0);
    });

    test('RemindersProvider should clear error', () {
      final provider = RemindersProvider();

      // Simulate an error state
      provider.clearError();

      expect(provider.error, null);
    });
  });
}
