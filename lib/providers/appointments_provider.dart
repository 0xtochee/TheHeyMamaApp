import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../services/local_db.dart';
import '../services/notification_service.dart';

/// Provider for managing medical appointments
///
/// Handles appointment state, persistence, and notification scheduling.
class AppointmentsProvider extends ChangeNotifier {
  final LocalDatabase _database = LocalDatabase();
  final NotificationService _notifications = NotificationService();

  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get upcoming appointments (future appointments only)
  List<Appointment> get upcomingAppointments {
    return _appointments.where((apt) => apt.isFuture).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Get past appointments
  List<Appointment> get pastAppointments {
    return _appointments.where((apt) => apt.isPast).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  /// Get today's appointments
  List<Appointment> get todaysAppointments {
    return _appointments.where((apt) => apt.isToday).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Get confirmed appointments
  List<Appointment> get confirmedAppointments {
    return _appointments.where((apt) => apt.isConfirmed).toList();
  }

  /// Get unconfirmed appointments
  List<Appointment> get unconfirmedAppointments {
    return _appointments.where((apt) => !apt.isConfirmed).toList();
  }

  /// Fetch all appointments from database
  Future<void> fetchAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appointments = await _database.getAppointments();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load appointments: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching appointments: $e');
    }
  }

  /// Add a new appointment
  ///
  /// Returns true if successful, false otherwise.
  /// Schedules notification if reminder is set (reminderMinutesBefore > 0).
  Future<bool> addAppointment(Appointment appointment) async {
    // Validate appointment
    if (!appointment.validate()) {
      _error = 'Invalid appointment data';
      notifyListeners();
      return false;
    }

    try {
      // Save to database
      final success = await _database.insertAppointment(appointment);
      if (!success) {
        _error = 'Failed to save appointment';
        notifyListeners();
        return false;
      }

      // Schedule notification if reminder is set
      if (appointment.reminderMinutesBefore > 0) {
        await _scheduleAppointmentNotification(appointment);
      }

      // Update local list
      _appointments.add(appointment);
      _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      _error = null;
      notifyListeners();

      return true;
    } catch (e) {
      _error = 'Error adding appointment: $e';
      notifyListeners();
      debugPrint('Error adding appointment: $e');
      return false;
    }
  }

  /// Update an existing appointment
  ///
  /// Returns true if successful, false otherwise.
  /// Reschedules notification if reminder settings changed.
  Future<bool> updateAppointment(Appointment appointment) async {
    // Validate appointment
    if (!appointment.validate()) {
      _error = 'Invalid appointment data';
      notifyListeners();
      return false;
    }

    try {
      // Update in database
      final success = await _database.updateAppointment(appointment);
      if (!success) {
        _error = 'Failed to update appointment';
        notifyListeners();
        return false;
      }

      // Cancel old notification and schedule new one
      final oldAppointment = _appointments.firstWhere(
        (apt) => apt.id == appointment.id,
        orElse: () => appointment,
      );

      if (oldAppointment.reminderMinutesBefore > 0) {
        await _cancelAppointmentNotification(appointment.id);
      }

      if (appointment.reminderMinutesBefore > 0) {
        await _scheduleAppointmentNotification(appointment);
      }

      // Update local list
      final index = _appointments.indexWhere((apt) => apt.id == appointment.id);
      if (index != -1) {
        _appointments[index] = appointment;
        _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      }

      _error = null;
      notifyListeners();

      return true;
    } catch (e) {
      _error = 'Error updating appointment: $e';
      notifyListeners();
      debugPrint('Error updating appointment: $e');
      return false;
    }
  }

  /// Delete an appointment
  ///
  /// Returns true if successful, false otherwise.
  /// Cancels any scheduled notification.
  Future<bool> deleteAppointment(String appointmentId) async {
    try {
      // Delete from database
      final success = await _database.deleteAppointment(appointmentId);
      if (!success) {
        _error = 'Failed to delete appointment';
        notifyListeners();
        return false;
      }

      // Cancel notification
      await _cancelAppointmentNotification(appointmentId);

      // Remove from local list
      _appointments.removeWhere((apt) => apt.id == appointmentId);
      _error = null;
      notifyListeners();

      return true;
    } catch (e) {
      _error = 'Error deleting appointment: $e';
      notifyListeners();
      debugPrint('Error deleting appointment: $e');
      return false;
    }
  }

  /// Toggle appointment confirmation status
  Future<bool> toggleConfirmation(String appointmentId) async {
    try {
      final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
      if (index == -1) {
        _error = 'Appointment not found';
        notifyListeners();
        return false;
      }

      final appointment = _appointments[index];
      final updated = appointment.copyWith(isConfirmed: !appointment.isConfirmed);

      return await updateAppointment(updated);
    } catch (e) {
      _error = 'Error toggling confirmation: $e';
      notifyListeners();
      debugPrint('Error toggling confirmation: $e');
      return false;
    }
  }

  /// Get appointment by ID
  Appointment? getAppointmentById(String appointmentId) {
    try {
      return _appointments.firstWhere((apt) => apt.id == appointmentId);
    } catch (e) {
      return null;
    }
  }

  /// Get appointments for a specific doctor
  List<Appointment> getAppointmentsByDoctor(String doctorId) {
    return _appointments.where((apt) => apt.doctorId == doctorId).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Get appointments for a specific date range
  List<Appointment> getAppointmentsInRange(DateTime start, DateTime end) {
    return _appointments
        .where((apt) =>
            apt.dateTime.isAfter(start) && apt.dateTime.isBefore(end))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Check if a time slot is available
  bool isTimeSlotAvailable(DateTime dateTime, {String? excludeAppointmentId}) {
    final appointments = excludeAppointmentId != null
        ? _appointments.where((apt) => apt.id != excludeAppointmentId)
        : _appointments;

    // Check for appointments within 30 minutes before or after
    return !appointments.any((apt) {
      final difference = apt.dateTime.difference(dateTime).inMinutes.abs();
      return difference < 30;
    });
  }

  /// Schedule notification for an appointment
  Future<void> _scheduleAppointmentNotification(
      Appointment appointment) async {
    if (appointment.reminderMinutesBefore <= 0) return;

    try {
      final notificationId = appointment.id.hashCode;
      final reminderTime = appointment.reminderDateTime;

      // Don't schedule if reminder time is in the past
      if (reminderTime.isBefore(DateTime.now())) {
        debugPrint(
            'Skipping notification for appointment ${appointment.id} - reminder time is in the past');
        return;
      }

      await _notifications.scheduleAppointmentNotification(
        appointment,
        notificationId,
      );

      debugPrint(
          'Scheduled notification for appointment ${appointment.id} at $reminderTime');
    } catch (e) {
      debugPrint('Error scheduling appointment notification: $e');
    }
  }

  /// Cancel notification for an appointment
  Future<void> _cancelAppointmentNotification(String appointmentId) async {
    try {
      final notificationId = appointmentId.hashCode;
      await _notifications.cancelNotification(notificationId);
      debugPrint('Cancelled notification for appointment $appointmentId');
    } catch (e) {
      debugPrint('Error cancelling appointment notification: $e');
    }
  }

  /// Reschedule all appointment notifications
  ///
  /// Useful after app restart or notification permission changes.
  Future<void> rescheduleAllAppointmentNotifications() async {
    try {
      for (final appointment in _appointments) {
        if (appointment.reminderMinutesBefore > 0 && appointment.isFuture) {
          await _scheduleAppointmentNotification(appointment);
        }
      }
      debugPrint('Rescheduled ${_appointments.length} appointment notifications');
    } catch (e) {
      debugPrint('Error rescheduling appointment notifications: $e');
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
