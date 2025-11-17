import 'package:flutter/foundation.dart';
import '../models/reminder.dart';
import '../services/local_db.dart';
import '../services/notification_service.dart';

/// Provider for managing reminders
///
/// This provider handles:
/// - Fetching reminders from the database
/// - Adding new reminders
/// - Updating existing reminders
/// - Deleting reminders
/// - Toggling reminder completion status
/// - Scheduling and canceling notifications
class RemindersProvider extends ChangeNotifier {
  final LocalDatabase _db = LocalDatabase();
  final NotificationService _notificationService = NotificationService();

  List<Reminder> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get reminders by type
  List<Reminder> remindersByType(ReminderType type) {
    return _reminders.where((r) => r.type == type && r.shouldShow).toList();
  }

  /// Get active (non-completed or recurring) reminders
  List<Reminder> get activeReminders {
    return _reminders.where((r) => r.shouldShow).toList();
  }

  /// Get completed reminders
  List<Reminder> get completedReminders {
    return _reminders
        .where((r) => r.isCompleted && r.recurring == RecurringPattern.none)
        .toList();
  }

  /// Fetch all reminders from the database
  Future<void> fetchReminders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reminders = await _db.getReminders();
      _isLoading = false;
      notifyListeners();

      // Reschedule all active reminders to ensure notifications work after app restart
      await rescheduleAllReminders();
    } catch (e) {
      _error = 'Failed to fetch reminders: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint(_error);
    }
  }

  /// Add a new reminder
  ///
  /// Parameters:
  /// - [reminder]: Reminder to add
  ///
  /// Returns: true if successful, false otherwise
  Future<bool> addReminder(Reminder reminder) async {
    try {
      // Save to database
      final success = await _db.insertReminder(reminder);

      if (success) {
        // Add to local list
        _reminders.add(reminder);
        _reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));

        // Schedule notification
        await _notificationService.scheduleReminderNotification(reminder);

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _error = 'Failed to add reminder: $e';
      notifyListeners();
      debugPrint(_error);
      return false;
    }
  }

  /// Update an existing reminder
  ///
  /// Parameters:
  /// - [reminder]: Updated reminder object
  ///
  /// Returns: true if successful, false otherwise
  Future<bool> updateReminder(Reminder reminder) async {
    try {
      // Update in database
      final success = await _db.updateReminder(reminder);

      if (success) {
        // Update in local list
        final index = _reminders.indexWhere((r) => r.id == reminder.id);
        if (index != -1) {
          _reminders[index] = reminder;
          _reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        }

        // Cancel old notification and reschedule
        final notificationId = reminder.notificationId ?? reminder.id.hashCode;
        await _notificationService.cancelReminderNotification(notificationId);
        await _notificationService.scheduleReminderNotification(reminder);

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _error = 'Failed to update reminder: $e';
      notifyListeners();
      debugPrint(_error);
      return false;
    }
  }

  /// Delete a reminder
  ///
  /// Parameters:
  /// - [reminderId]: ID of the reminder to delete
  ///
  /// Returns: true if successful, false otherwise
  Future<bool> deleteReminder(String reminderId) async {
    try {
      // Get reminder to find notification ID
      final reminder = _reminders.firstWhere(
        (r) => r.id == reminderId,
        orElse: () => throw Exception('Reminder not found'),
      );

      // Delete from database
      final success = await _db.deleteReminder(reminderId);

      if (success) {
        // Remove from local list
        _reminders.removeWhere((r) => r.id == reminderId);

        // Cancel notification
        final notificationId = reminder.notificationId ?? reminder.id.hashCode;
        await _notificationService.cancelReminderNotification(notificationId);

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _error = 'Failed to delete reminder: $e';
      notifyListeners();
      debugPrint(_error);
      return false;
    }
  }

  /// Toggle reminder completion status
  ///
  /// Parameters:
  /// - [reminderId]: ID of the reminder to toggle
  ///
  /// Returns: true if successful, false otherwise
  Future<bool> toggleComplete(String reminderId) async {
    try {
      // Find the reminder
      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index == -1) {
        throw Exception('Reminder not found');
      }

      final reminder = _reminders[index];
      final updatedReminder = reminder.copyWith(isCompleted: !reminder.isCompleted);

      // Update in database
      final success = await _db.updateReminder(updatedReminder);

      if (success) {
        // Update in local list
        _reminders[index] = updatedReminder;

        // Handle notification scheduling
        final notificationId =
            updatedReminder.notificationId ?? updatedReminder.id.hashCode;

        if (updatedReminder.isCompleted &&
            updatedReminder.recurring == RecurringPattern.none) {
          // Cancel notification if completed and not recurring
          await _notificationService.cancelReminderNotification(notificationId);
        } else if (!updatedReminder.isCompleted && updatedReminder.isFuture) {
          // Reschedule if marked as not complete and in future
          await _notificationService
              .scheduleReminderNotification(updatedReminder);
        }

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _error = 'Failed to toggle reminder completion: $e';
      notifyListeners();
      debugPrint(_error);
      return false;
    }
  }

  /// Get a specific reminder by ID
  ///
  /// Parameters:
  /// - [reminderId]: ID of the reminder to get
  ///
  /// Returns: Reminder object or null if not found
  Reminder? getReminderById(String reminderId) {
    try {
      return _reminders.firstWhere((r) => r.id == reminderId);
    } catch (e) {
      return null;
    }
  }

  /// Reschedule all active reminders
  ///
  /// Useful after app restart or system changes
  Future<void> rescheduleAllReminders() async {
    try {
      // Cancel and reschedule each reminder's notification individually
      for (final reminder in activeReminders) {
        final notificationId = reminder.notificationId ?? reminder.id.hashCode;
        await _notificationService.cancelReminderNotification(notificationId);
        await _notificationService.scheduleReminderNotification(reminder);
      }
      debugPrint('Rescheduled ${activeReminders.length} active reminders');
    } catch (e) {
      debugPrint('Failed to reschedule all reminders: $e');
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get count of reminders by type
  int getCountByType(ReminderType type) {
    return remindersByType(type).length;
  }

  /// Get upcoming reminders (within next 24 hours)
  List<Reminder> get upcomingReminders {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    return _reminders.where((r) {
      return r.dateTime.isAfter(now) &&
          r.dateTime.isBefore(tomorrow) &&
          r.shouldShow;
    }).toList();
  }

  /// Get overdue reminders (past due and not completed)
  List<Reminder> get overdueReminders {
    final now = DateTime.now();

    return _reminders.where((r) {
      return r.dateTime.isBefore(now) &&
          !r.isCompleted &&
          r.recurring == RecurringPattern.none;
    }).toList();
  }
}
