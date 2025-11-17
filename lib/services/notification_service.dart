import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/reminder.dart';
import '../models/appointment.dart';

/// Service for managing local notifications and alerts
///
/// This service handles:
/// - Notification channel setup
/// - Alert scheduling and display
/// - Permission management
/// - Urgent health alerts (e.g., abnormal BP readings)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  factory NotificationService() => _instance;

  NotificationService._internal();

  /// Initialize the notification service
  /// Should be called once during app startup
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone data
      tz_data.initializeTimeZones();

      // Set local timezone (fallback to UTC if location not found)
      try {
        final locationName = DateTime.now().timeZoneName;
        tz.setLocalLocation(tz.getLocation(locationName));
      } catch (e) {
        // Fallback to a common timezone or UTC
        debugPrint('Could not set timezone from system, using UTC: $e');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;

      // Request permissions after initialization
      await requestPermissions();
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
      throw Exception('Notification initialization failed: $e');
    }
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    try {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      return result ?? true; // Android doesn't require runtime permissions
    } catch (e) {
      debugPrint('Failed to request notification permissions: $e');
      return false;
    }
  }

  /// Show an immediate notification
  ///
  /// Parameters:
  /// - [id]: Unique notification ID
  /// - [title]: Notification title
  /// - [body]: Notification message body
  /// - [payload]: Optional data to pass with notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      if (!_initialized) await initialize();

      const androidDetails = AndroidNotificationDetails(
        'pregnancy_vitals_channel',
        'Pregnancy Vitals',
        channelDescription: 'Notifications for pregnancy vital readings',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(id, title, body, details, payload: payload);
    } catch (e) {
      debugPrint('Failed to show notification: $e');
      throw Exception('Notification display failed: $e');
    }
  }

  /// Show an urgent health alert notification
  ///
  /// Used for abnormal readings that require immediate attention
  ///
  /// Parameters:
  /// - [title]: Alert title (e.g., "High Blood Pressure")
  /// - [body]: Alert message
  Future<void> showUrgentAlert({
    required String title,
    required String body,
  }) async {
    try {
      if (!_initialized) await initialize();

      const androidDetails = AndroidNotificationDetails(
        'pregnancy_alerts_channel',
        'Pregnancy Alerts',
        channelDescription: 'Urgent health alerts for pregnancy monitoring',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        // Red color for urgent alerts
        color: Color(0xFFE53935),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.critical,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Use a fixed ID for urgent alerts so they replace each other
      await _notifications.show(
        9999,
        title,
        body,
        details,
        payload: 'urgent_alert',
      );
    } catch (e) {
      debugPrint('Failed to show urgent alert: $e');
      throw Exception('Urgent alert failed: $e');
    }
  }

  /// Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (e) {
      debugPrint('Failed to cancel notification $id: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Failed to cancel all notifications: $e');
    }
  }

  /// Handle notification tap events
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen based on payload
    // This will be implemented when adding navigation/routing
  }

  /// Get list of pending notifications (Android)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Failed to get pending notifications: $e');
      return [];
    }
  }

  // ==================== REMINDER NOTIFICATION METHODS ====================

  /// Schedule a notification for a reminder at a specific date and time
  ///
  /// Parameters:
  /// - [reminder]: Reminder object containing notification details
  ///
  /// Returns: true if scheduling was successful, false otherwise
  Future<bool> scheduleReminderNotification(Reminder reminder) async {
    try {
      if (!_initialized) {
        debugPrint('NotificationService not initialized, initializing now...');
        await initialize();
      }

      // Don't schedule if already completed and not recurring
      if (reminder.isCompleted && reminder.recurring == RecurringPattern.none) {
        debugPrint('Reminder ${reminder.id} is completed and not recurring, skipping schedule');
        return false;
      }

      // Don't schedule if date is in the past (unless recurring)
      if (reminder.dateTime.isBefore(DateTime.now()) &&
          reminder.recurring == RecurringPattern.none) {
        debugPrint('Reminder ${reminder.id} is in the past (${reminder.dateTime}), skipping schedule');
        return false;
      }

      final notificationId = reminder.notificationId ?? reminder.id.hashCode;

      const androidDetails = AndroidNotificationDetails(
        'pregnancy_reminders_channel',
        'Pregnancy Reminders',
        channelDescription: 'Reminders for medications and appointments',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Handle recurring reminders
      if (reminder.recurring != RecurringPattern.none) {
        debugPrint('Scheduling recurring ${reminder.recurring.name} reminder ${reminder.id}');
        return await _scheduleRecurringNotification(
          notificationId,
          reminder,
          details,
        );
      }

      // Schedule one-time notification
      final scheduledDate = tz.TZDateTime.from(reminder.dateTime, tz.local);
      final now = tz.TZDateTime.now(tz.local);

      debugPrint('Scheduling notification $notificationId for reminder ${reminder.id}');
      debugPrint('  Current time: $now');
      debugPrint('  Scheduled for: $scheduledDate');
      debugPrint('  Time until notification: ${scheduledDate.difference(now)}');

      await _notifications.zonedSchedule(
        notificationId,
        _getReminderTitle(reminder),
        _getReminderBody(reminder),
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'reminder:${reminder.id}',
      );

      debugPrint('Successfully scheduled notification $notificationId');
      return true;
    } catch (e) {
      debugPrint('Failed to schedule reminder notification for ${reminder.id}: $e');
      debugPrint('Error stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Schedule a recurring notification
  Future<bool> _scheduleRecurringNotification(
    int notificationId,
    Reminder reminder,
    NotificationDetails details,
  ) async {
    try {
      // Return false if not recurring
      if (reminder.recurring == RecurringPattern.none) {
        return false;
      }

      // For recurring reminders, schedule from the reminder's time
      final scheduledDate = tz.TZDateTime.from(reminder.dateTime, tz.local);

      await _notifications.zonedSchedule(
        notificationId,
        _getReminderTitle(reminder),
        _getReminderBody(reminder),
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: _getDateTimeComponents(reminder.recurring),
        payload: 'reminder:${reminder.id}',
      );

      debugPrint('Scheduled recurring (${reminder.recurring.name}) notification for reminder ${reminder.id}');
      return true;
    } catch (e) {
      debugPrint('Failed to schedule recurring notification: $e');
      return false;
    }
  }

  /// Get date time components for recurring notifications
  DateTimeComponents _getDateTimeComponents(RecurringPattern pattern) {
    switch (pattern) {
      case RecurringPattern.daily:
        return DateTimeComponents.time;
      case RecurringPattern.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case RecurringPattern.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      default:
        return DateTimeComponents.time;
    }
  }

  /// Get notification title based on reminder type
  String _getReminderTitle(Reminder reminder) {
    switch (reminder.type) {
      case ReminderType.medication:
        return 'Medication Reminder';
      case ReminderType.appointment:
        return 'Appointment Reminder';
      case ReminderType.other:
        return 'Reminder';
    }
  }

  /// Get notification body text
  String _getReminderBody(Reminder reminder) {
    return reminder.title;
  }

  /// Cancel a scheduled reminder notification
  ///
  /// Parameters:
  /// - [notificationId]: ID of the notification to cancel
  Future<void> cancelReminderNotification(int notificationId) async {
    try {
      await _notifications.cancel(notificationId);
      debugPrint('Cancelled reminder notification $notificationId');
    } catch (e) {
      debugPrint('Failed to cancel reminder notification $notificationId: $e');
    }
  }

  /// Reschedule all active reminders
  ///
  /// Useful after app restart or when reminders are modified
  ///
  /// Parameters:
  /// - [reminders]: List of active reminders to reschedule
  Future<void> rescheduleAllReminders(List<Reminder> reminders) async {
    try {
      // Cancel all existing reminder notifications first
      await cancelAllNotifications();

      int successCount = 0;
      for (final reminder in reminders) {
        if (reminder.shouldShow) {
          final success = await scheduleReminderNotification(reminder);
          if (success) successCount++;
        }
      }

      debugPrint('Rescheduled $successCount out of ${reminders.length} reminders');
    } catch (e) {
      debugPrint('Failed to reschedule reminders: $e');
    }
  }

  // ==================== APPOINTMENT NOTIFICATION METHODS ====================

  /// Schedule a notification for an appointment reminder
  ///
  /// Schedules a notification to be shown at the specified time before the appointment.
  ///
  /// Parameters:
  /// - [appointment]: Appointment object containing notification details
  /// - [notificationId]: Unique ID for the notification (typically appointment.id.hashCode)
  ///
  /// Returns: true if scheduling was successful, false otherwise
  Future<bool> scheduleAppointmentNotification(
    Appointment appointment,
    int notificationId,
  ) async {
    try {
      if (!_initialized) await initialize();

      // Don't schedule if no reminder is set
      if (appointment.reminderMinutesBefore <= 0) {
        debugPrint('Appointment ${appointment.id} has no reminder set, skipping schedule');
        return false;
      }

      // Calculate reminder time
      final reminderTime = appointment.reminderDateTime;

      // Don't schedule if reminder time is in the past
      if (reminderTime.isBefore(DateTime.now())) {
        debugPrint('Appointment ${appointment.id} reminder time is in the past, skipping schedule');
        return false;
      }

      const androidDetails = AndroidNotificationDetails(
        'pregnancy_appointments_channel',
        'Appointment Reminders',
        channelDescription: 'Reminders for medical appointments',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF0D79FF),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule notification at reminder time
      final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

      await _notifications.zonedSchedule(
        notificationId,
        'Upcoming Appointment',
        'You have an appointment with ${appointment.doctorName} in ${appointment.reminderMinutesBefore} minutes',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'appointment:${appointment.id}',
      );

      debugPrint('Scheduled appointment notification $notificationId for ${appointment.id} at $scheduledDate');
      return true;
    } catch (e) {
      debugPrint('Failed to schedule appointment notification: $e');
      return false;
    }
  }

  /// Cancel a scheduled appointment notification
  ///
  /// Parameters:
  /// - [notificationId]: ID of the notification to cancel
  Future<void> cancelAppointmentNotification(int notificationId) async {
    try {
      await _notifications.cancel(notificationId);
      debugPrint('Cancelled appointment notification $notificationId');
    } catch (e) {
      debugPrint('Failed to cancel appointment notification $notificationId: $e');
    }
  }

  /// Reschedule all appointment notifications
  ///
  /// Useful after app restart or when appointments are modified
  ///
  /// Parameters:
  /// - [appointments]: List of appointments to reschedule notifications for
  Future<void> rescheduleAllAppointmentNotifications(
    List<Appointment> appointments,
  ) async {
    try {
      int successCount = 0;
      for (final appointment in appointments) {
        // Only schedule for future appointments with reminders
        if (appointment.isFuture && appointment.reminderMinutesBefore > 0) {
          final notificationId = appointment.id.hashCode;
          final success = await scheduleAppointmentNotification(
            appointment,
            notificationId,
          );
          if (success) successCount++;
        }
      }

      debugPrint('Rescheduled $successCount out of ${appointments.length} appointment notifications');
    } catch (e) {
      debugPrint('Failed to reschedule appointment notifications: $e');
    }
  }
}
