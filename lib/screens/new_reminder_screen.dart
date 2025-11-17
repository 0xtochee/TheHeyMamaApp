import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../providers/reminders_provider.dart';
import '../services/notification_service.dart';
import '../widgets/segmented_choice.dart';
import '../widgets/rounded_text_field.dart';
import '../widgets/pill_button.dart';
import '../utils/responsive_helper.dart';

/// New Reminder Screen - Pixel-perfect modal for creating/editing reminders
///
/// Features:
/// - Create new reminders or edit existing ones
/// - Segmented type selection (Medication, Appointment, Custom)
/// - Time picker integration
/// - Frequency selection
/// - Notifications toggle
/// - Form validation
/// - Accessible design
class NewReminderScreen extends StatefulWidget {
  final Reminder? initial;

  const NewReminderScreen({
    super.key,
    this.initial,
  });

  @override
  State<NewReminderScreen> createState() => _NewReminderScreenState();
}

class _NewReminderScreenState extends State<NewReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();

  int _selectedTypeIndex = 0; // 0: Medication, 1: Appointment, 2: Custom/Other
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;
  RecurringPattern _selectedFrequency = RecurringPattern.none;
  bool _notificationsEnabled = true;
  bool _isLoading = false;

  final List<String> _typeOptions = ['Medication', 'Appointment', 'Custom'];

  @override
  void initState() {
    super.initState();

    // Initialize with existing reminder data if editing
    if (widget.initial != null) {
      _titleController.text = widget.initial!.title;
      _selectedDate = widget.initial!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.initial!.dateTime);
      _timeController.text = _formatTime(_selectedTime!);
      _selectedFrequency = widget.initial!.recurring;
      _notificationsEnabled = widget.initial!.notificationId != null;

      // Map ReminderType to index
      switch (widget.initial!.type) {
        case ReminderType.medication:
          _selectedTypeIndex = 0;
          break;
        case ReminderType.appointment:
          _selectedTypeIndex = 1;
          break;
        case ReminderType.other:
          _selectedTypeIndex = 2;
          break;
      }
    } else {
      // Default to today's date
      _selectedDate = DateTime.now();
      // Default notifications ON for medication, OFF for others
      _notificationsEnabled = _selectedTypeIndex == 0;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard on background tap
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Custom header
              _buildHeader(context, isEditing),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getHorizontalPadding(context),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // Reminder Type Section
                        _buildSectionLabel('Reminder Type'),
                        const SizedBox(height: 12),
                        SegmentedChoice(
                          options: _typeOptions,
                          selectedIndex: _selectedTypeIndex,
                          onChanged: (index) {
                            setState(() {
                              _selectedTypeIndex = index;
                              // Auto-enable notifications for medication
                              if (index == 0 && !_notificationsEnabled) {
                                _notificationsEnabled = true;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Title Field
                        RoundedTextField(
                          controller: _titleController,
                          hintText: 'Enter reminder title',
                          semanticLabel: 'Reminder title',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Title is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Title must be at least 2 characters';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 18),

                        // Time Field
                        RoundedTextField(
                          controller: _timeController,
                          hintText: 'Select time',
                          semanticLabel: 'Select reminder time',
                          readOnly: true,
                          onTap: _selectTime,
                          suffixIcon: const Icon(
                            Icons.access_time,
                            color: Color(0xFF5B6B7A),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Time is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Frequency Field (Dropdown)
                        _buildFrequencyDropdown(),
                        const SizedBox(height: 24),

                        // Notifications Toggle
                        _buildNotificationsToggle(),
                        const SizedBox(height: 32),

                        // Save Button
                        PillButton(
                          text: isEditing ? 'Update Reminder' : 'Save',
                          onPressed: _isLoading ? null : _saveReminder,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build custom header with close button and title
  Widget _buildHeader(BuildContext context, bool isEditing) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getHorizontalPadding(context),
        vertical: 16,
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
          // Close button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Semantics(
              label: 'Close',
              button: true,
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.close,
                  size: 24,
                  color: Color(0xFF182033),
                ),
              ),
            ),
          ),

          // Title
          Expanded(
            child: Text(
              isEditing ? 'Edit Reminder' : 'New Reminder',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveHelper.getTitleFontSize(context),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF182033),
              ),
            ),
          ),

          // Spacer for symmetry
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  /// Build section label
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF182033),
      ),
    );
  }

  /// Build frequency dropdown
  Widget _buildFrequencyDropdown() {
    return DropdownButtonFormField<RecurringPattern>(
      value: _selectedFrequency,
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedFrequency = value);
        }
      },
      decoration: InputDecoration(
        hintText: 'Frequency',
        hintStyle: const TextStyle(
          color: Color(0xFF5B6B7A),
          fontSize: 16,
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
            color: Color(0xFF1E88E5),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF182033),
      ),
      dropdownColor: Colors.white,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF5B6B7A)),
      items: RecurringPattern.values.map((pattern) {
        return DropdownMenuItem(
          value: pattern,
          child: Text(pattern.displayName),
        );
      }).toList(),
    );
  }

  /// Build notifications toggle
  Widget _buildNotificationsToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF182033),
          ),
        ),
        Semantics(
          label: 'Enable notifications',
          hint: _notificationsEnabled ? 'On' : 'Off',
          child: Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
            activeColor: const Color(0xFF1E88E5),
          ),
        ),
      ],
    );
  }

  /// Select time using time picker
  Future<void> _selectTime() async {
    final initialTime = _selectedTime ?? TimeOfDay.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E88E5),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = _formatTime(picked);
      });
    }
  }

  /// Format time for display
  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat.jm().format(dateTime); // e.g., "9:00 AM"
  }

  /// Get ReminderType from selected index
  ReminderType _getReminderType() {
    switch (_selectedTypeIndex) {
      case 0:
        return ReminderType.medication;
      case 1:
        return ReminderType.appointment;
      case 2:
      default:
        return ReminderType.other;
    }
  }

  /// Save reminder
  Future<void> _saveReminder() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Ensure time is selected
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time'),
          backgroundColor: Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Combine date and time
      final now = DateTime.now();
      final dateTime = DateTime(
        _selectedDate?.year ?? now.year,
        _selectedDate?.month ?? now.month,
        _selectedDate?.day ?? now.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Build reminder object
      final reminder = Reminder(
        id: widget.initial?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        type: _getReminderType(),
        dateTime: dateTime,
        recurring: _selectedFrequency,
        isCompleted: widget.initial?.isCompleted ?? false,
        notes: '',
        iconKey: widget.initial?.iconKey ?? 'default',
        notificationId: _notificationsEnabled
            ? (widget.initial?.notificationId ?? dateTime.millisecondsSinceEpoch)
            : null,
      );

      final provider = context.read<RemindersProvider>();

      // Save to database
      bool success;
      if (widget.initial != null) {
        success = await provider.updateReminder(reminder);
      } else {
        success = await provider.addReminder(reminder);
      }

      // Schedule notification if enabled
      if (success && _notificationsEnabled) {
        await NotificationService().scheduleReminderNotification(reminder);
      }

      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.initial != null
                    ? 'Reminder updated'
                    : 'Reminder saved',
              ),
              backgroundColor: const Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );

          // Return with result
          Navigator.of(context).pop(reminder);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save reminder'),
              backgroundColor: Color(0xFFE53935),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
