import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../providers/appointments_provider.dart';

/// Book Appointment Screen
///
/// Full booking flow for scheduling appointments with doctors.
/// Includes date/time selection, notes, and reminder preferences.
class BookAppointmentScreen extends StatefulWidget {
  final Doctor doctor;

  const BookAppointmentScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _reminderMinutes = 60; // Default: 1 hour before
  bool _isLoading = false;

  // Design constants
  static const Color _primaryBlue = Color(0xFF0D79FF);
  static const Color _headingText = Color(0xFF182033);
  static const Color _subtext = Color(0xFF5B6B7A);
  static const Color _errorRed = Color(0xFFE53935);
  static const double _horizontalPadding = 20.0;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Pick appointment date
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 365));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  /// Pick appointment time
  Future<void> _pickTime() async {
    final now = TimeOfDay.now();

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  /// Book the appointment
  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      _showErrorDialog('Please select both date and time for the appointment.');
      return;
    }

    // Combine date and time
    final appointmentDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Check if appointment is in the future
    if (appointmentDateTime.isBefore(DateTime.now())) {
      _showErrorDialog('Cannot book appointments in the past.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<AppointmentsProvider>(
        context,
        listen: false,
      );

      // Check if time slot is available
      if (!provider.isTimeSlotAvailable(appointmentDateTime)) {
        _showErrorDialog(
          'This time slot is not available. Please choose a different time.',
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create appointment
      final appointment = Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        doctorId: widget.doctor.id,
        doctorName: widget.doctor.name,
        dateTime: appointmentDateTime,
        notes: _notesController.text.trim(),
        reminderMinutesBefore: _reminderMinutes,
        createdAt: DateTime.now(),
        isConfirmed: false,
      );

      // Add appointment
      final success = await provider.addAppointment(appointment);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(
          provider.error ?? 'Failed to book appointment. Please try again.',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('An error occurred: $e');
    }
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _errorRed,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: _headingText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Appointment Booked!',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _headingText,
          ),
        ),
        content: Text(
          'Your appointment with ${widget.doctor.name} has been successfully booked.',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: _headingText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to directory
            },
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                  vertical: 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor Info Card
                      _buildDoctorInfoCard(),

                      const SizedBox(height: 32),

                      // Date Selection
                      _buildDateSelection(),

                      const SizedBox(height: 20),

                      // Time Selection
                      _buildTimeSelection(),

                      const SizedBox(height: 20),

                      // Reminder Selection
                      _buildReminderSelection(),

                      const SizedBox(height: 20),

                      // Notes Field
                      _buildNotesField(),

                      const SizedBox(height: 32),

                      // Book Button
                      _buildBookButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build top bar with back button and title
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE6E9EE).withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          Semantics(
            label: 'Go back',
            button: true,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: _headingText,
                ),
              ),
            ),
          ),

          // Title
          const Expanded(
            child: Text(
              'Book Appointment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: _headingText,
              ),
            ),
          ),

          // Spacer for symmetry
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  /// Build doctor info card
  Widget _buildDoctorInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                widget.doctor.initials,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _primaryBlue,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _headingText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.doctor.specialty,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _subtext,
                  ),
                ),
                if (widget.doctor.location != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.doctor.location!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _subtext,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build date selection field
  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _headingText,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFE6E9EE),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: _primaryBlue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('EEEE, MMMM d, y').format(_selectedDate!)
                        : 'Select date',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: _selectedDate != null ? _headingText : _subtext,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: _subtext,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build time selection field
  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _headingText,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickTime,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFE6E9EE),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 20,
                  color: _primaryBlue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select time',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: _selectedTime != null ? _headingText : _subtext,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: _subtext,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build reminder selection dropdown
  Widget _buildReminderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _headingText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE6E9EE),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _reminderMinutes,
              isExpanded: true,
              icon: const Icon(Icons.chevron_right, color: _subtext),
              style: GoogleFonts.inter(
                fontSize: 15,
                color: _headingText,
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('No reminder')),
                DropdownMenuItem(value: 15, child: Text('15 minutes before')),
                DropdownMenuItem(value: 30, child: Text('30 minutes before')),
                DropdownMenuItem(value: 60, child: Text('1 hour before')),
                DropdownMenuItem(value: 120, child: Text('2 hours before')),
                DropdownMenuItem(value: 1440, child: Text('1 day before')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _reminderMinutes = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Build notes field
  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _headingText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 4,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Add any notes about your appointment...',
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              color: _subtext,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE6E9EE),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE6E9EE),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: _primaryBlue,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: GoogleFonts.inter(
            fontSize: 15,
            color: _headingText,
          ),
        ),
      ],
    );
  }

  /// Build book button
  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _bookAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          disabledBackgroundColor: _primaryBlue.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Book Appointment',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
