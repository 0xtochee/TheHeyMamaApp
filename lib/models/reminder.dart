import 'package:flutter/material.dart';

/// Enum for reminder types
enum ReminderType {
  medication,
  appointment,
  other;

  String get displayName {
    switch (this) {
      case ReminderType.medication:
        return 'Medication';
      case ReminderType.appointment:
        return 'Appointment';
      case ReminderType.other:
        return 'Other';
    }
  }

  static ReminderType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'medication':
        return ReminderType.medication;
      case 'appointment':
        return ReminderType.appointment;
      default:
        return ReminderType.other;
    }
  }
}

/// Enum for recurring patterns
enum RecurringPattern {
  none,
  daily,
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case RecurringPattern.none:
        return 'None';
      case RecurringPattern.daily:
        return 'Daily';
      case RecurringPattern.weekly:
        return 'Weekly';
      case RecurringPattern.monthly:
        return 'Monthly';
    }
  }

  static RecurringPattern fromString(String? value) {
    if (value == null) return RecurringPattern.none;
    switch (value.toLowerCase()) {
      case 'daily':
        return RecurringPattern.daily;
      case 'weekly':
        return RecurringPattern.weekly;
      case 'monthly':
        return RecurringPattern.monthly;
      default:
        return RecurringPattern.none;
    }
  }
}

/// Model for a reminder
class Reminder {
  final String id;
  final String title;
  final ReminderType type;
  final DateTime dateTime;
  final RecurringPattern recurring;
  final bool isCompleted;
  final String notes;
  final String iconKey;
  final int? notificationId;

  const Reminder({
    required this.id,
    required this.title,
    required this.type,
    required this.dateTime,
    this.recurring = RecurringPattern.none,
    this.isCompleted = false,
    this.notes = '',
    this.iconKey = 'default',
    this.notificationId,
  });

  /// Create a copy with updated fields
  Reminder copyWith({
    String? id,
    String? title,
    ReminderType? type,
    DateTime? dateTime,
    RecurringPattern? recurring,
    bool? isCompleted,
    String? notes,
    String? iconKey,
    int? notificationId,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      recurring: recurring ?? this.recurring,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      iconKey: iconKey ?? this.iconKey,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'datetime': dateTime.millisecondsSinceEpoch,
      'recurring': recurring == RecurringPattern.none ? null : recurring.name,
      'isCompleted': isCompleted ? 1 : 0,
      'notes': notes,
      'iconKey': iconKey,
      'notificationId': notificationId,
    };
  }

  /// Create from Map (from database)
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String,
      title: map['title'] as String,
      type: ReminderType.fromString(map['type'] as String),
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['datetime'] as int),
      recurring: RecurringPattern.fromString(map['recurring'] as String?),
      isCompleted: (map['isCompleted'] as int) == 1,
      notes: map['notes'] as String? ?? '',
      iconKey: map['iconKey'] as String? ?? 'default',
      notificationId: map['notificationId'] as int?,
    );
  }

  /// Validate reminder data
  bool validate() {
    if (title.trim().isEmpty) return false;
    return true;
  }

  /// Get icon data based on type and iconKey
  IconData get icon {
    switch (type) {
      case ReminderType.medication:
        return Icons.medication;
      case ReminderType.appointment:
        return Icons.calendar_today;
      case ReminderType.other:
        return Icons.notifications;
    }
  }

  /// Get formatted time string
  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeString = '$displayHour:${minute.toString().padLeft(2, '0')} $period';

    if (reminderDate == today) {
      return timeString;
    } else if (reminderDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow, $timeString';
    } else {
      final weekday = _getWeekdayName(dateTime.weekday);
      return '$weekday, $timeString';
    }
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  /// Check if reminder is in the future
  bool get isFuture {
    return dateTime.isAfter(DateTime.now());
  }

  /// Check if reminder should show (not completed or recurring)
  bool get shouldShow {
    if (recurring != RecurringPattern.none) return true;
    if (isCompleted) return false;
    return isFuture || dateTime.difference(DateTime.now()).inHours.abs() < 24;
  }

  @override
  String toString() {
    return 'Reminder(id: $id, title: $title, type: ${type.name}, dateTime: $dateTime, recurring: ${recurring.name}, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reminder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
