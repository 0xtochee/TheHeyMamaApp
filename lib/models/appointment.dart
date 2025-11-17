/// Model class for medical appointments
///
/// Represents a scheduled appointment with a doctor.
class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final DateTime dateTime;
  final String notes;
  final int reminderMinutesBefore;
  final DateTime createdAt;
  final bool isConfirmed;

  const Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.dateTime,
    this.notes = '',
    this.reminderMinutesBefore = 0,
    required this.createdAt,
    this.isConfirmed = false,
  });

  /// Create copy with updated fields
  Appointment copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    DateTime? dateTime,
    String? notes,
    int? reminderMinutesBefore,
    DateTime? createdAt,
    bool? isConfirmed,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      createdAt: createdAt ?? this.createdAt,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'datetime': dateTime.millisecondsSinceEpoch,
      'notes': notes,
      'reminderMinutes': reminderMinutesBefore,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isConfirmed': isConfirmed ? 1 : 0,
    };
  }

  /// Create from Map (from database)
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as String,
      doctorId: map['doctorId'] as String,
      doctorName: map['doctorName'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['datetime'] as int),
      notes: map['notes'] as String? ?? '',
      reminderMinutesBefore: map['reminderMinutes'] as int? ?? 0,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      isConfirmed: (map['isConfirmed'] as int?) == 1,
    );
  }

  /// Get DateTime for reminder notification
  DateTime get reminderDateTime {
    return dateTime.subtract(Duration(minutes: reminderMinutesBefore));
  }

  /// Check if appointment is in the future
  bool get isFuture {
    return dateTime.isAfter(DateTime.now());
  }

  /// Check if appointment is today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate =
        DateTime(dateTime.year, dateTime.month, dateTime.day);
    return today == appointmentDate;
  }

  /// Check if appointment is past
  bool get isPast {
    return dateTime.isBefore(DateTime.now());
  }

  /// Get reminder label
  String get reminderLabel {
    if (reminderMinutesBefore == 0) return 'None';
    if (reminderMinutesBefore == 15) return '15 minutes before';
    if (reminderMinutesBefore == 60) return '1 hour before';
    if (reminderMinutesBefore == 1440) return '1 day before';
    return '$reminderMinutesBefore minutes before';
  }

  /// Validate appointment data
  bool validate() {
    if (doctorId.trim().isEmpty) return false;
    if (doctorName.trim().isEmpty) return false;
    // Don't allow appointments in the past (more than 1 minute ago)
    if (dateTime.isBefore(DateTime.now().subtract(const Duration(minutes: 1)))) {
      return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'Appointment(id: $id, doctor: $doctorName, dateTime: $dateTime, reminder: $reminderLabel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
