import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reminder.dart';
import '../providers/reminders_provider.dart';

/// Screen for adding or editing reminders
///
/// Features:
/// - Create new reminders or edit existing ones
/// - Field validation
/// - Date and time pickers
/// - Recurring pattern selection
/// - Type selection (Medication/Appointment/Other)
class AddEditReminderScreen extends StatefulWidget {
  final Reminder? reminder;
  final ReminderType? initialType;

  const AddEditReminderScreen({
    super.key,
    this.reminder,
    this.initialType,
  });

  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  late ReminderType _selectedType;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  RecurringPattern _selectedRecurring = RecurringPattern.none;
  bool _isLoading = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();

    // Initialize with existing reminder data or defaults
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _notesController.text = widget.reminder!.notes;
      _selectedType = widget.reminder!.type;
      _selectedDate = widget.reminder!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.reminder!.dateTime);
      _selectedRecurring = widget.reminder!.recurring;
    } else {
      _selectedType = widget.initialType ?? ReminderType.medication;
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reminder != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom app bar
            _buildAppBar(context, isEditing),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Type selector (Reminder Type)
                      _buildLabel('Reminder Type'),
                      const SizedBox(height: 12),
                      _buildTypeSelector(),
                      const SizedBox(height: 24),

                      // Title field
                      _buildTextField(
                        controller: _titleController,
                        hintText: 'Title',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Time selector
                      _buildTimeField(),
                      const SizedBox(height: 16),

                      // Frequency selector
                      _buildFrequencyField(),
                      const SizedBox(height: 24),

                      // Notifications toggle
                      _buildNotificationsToggle(),
                      const SizedBox(height: 32),

                      // Save button
                      _buildSaveButton(isEditing),
                      const SizedBox(height: 32),
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

  /// Build custom app bar
  Widget _buildAppBar(BuildContext context, bool isEditing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Close button (X icon)
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close,
                size: 24,
                color: Color(0xFF2B3B4A),
              ),
            ),
          ),

          // Title
          Expanded(
            child: Text(
              isEditing ? 'Edit Reminder' : 'New Reminder',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2B3B4A),
              ),
            ),
          ),

          // Spacer for symmetry
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  /// Build section label
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF2B3B4A),
      ),
    );
  }

  /// Build text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF7F97AA),
          fontSize: 16,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F6F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF2B3B4A),
      ),
    );
  }

  /// Build text area for notes
  Widget _buildTextArea({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF7F97AA),
          fontSize: 16,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F6F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF2B3B4A),
      ),
    );
  }

  /// Build type selector (Medication/Appointment/Custom)
  Widget _buildTypeSelector() {
    // Map "Other" to "Custom" for display
    final types = [ReminderType.medication, ReminderType.appointment, ReminderType.other];
    final typeLabels = ['Medication', 'Appointment', 'Custom'];

    return Row(
      children: List.generate(types.length, (index) {
        final type = types[index];
        final label = typeLabels[index];
        final isSelected = _selectedType == type;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < types.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0D79FF)
                        : const Color(0xFFE0E0E0),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF0D79FF)
                        : const Color(0xFF7F97AA),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Build time field
  Widget _buildTimeField() {
    final timeText = _formatTime(_selectedTime);

    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                timeText.isEmpty ? 'Time' : timeText,
                style: TextStyle(
                  fontSize: 16,
                  color: timeText.isEmpty
                      ? const Color(0xFF7F97AA)
                      : const Color(0xFF2B3B4A),
                ),
              ),
            ),
            const Icon(
              Icons.access_time,
              size: 20,
              color: Color(0xFF7F97AA),
            ),
          ],
        ),
      ),
    );
  }

  /// Build frequency field
  Widget _buildFrequencyField() {
    final frequencyText = _selectedRecurring.displayName;
    final hasSelection = _selectedRecurring != RecurringPattern.none;

    return GestureDetector(
      onTap: _showFrequencyPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasSelection ? frequencyText : 'Frequency',
                style: TextStyle(
                  fontSize: 16,
                  color: hasSelection
                      ? const Color(0xFF2B3B4A)
                      : const Color(0xFF7F97AA),
                ),
              ),
            ),
          ],
        ),
      ),
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
            color: Color(0xFF2B3B4A),
          ),
        ),
        Switch(
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
          },
          activeColor: const Color(0xFF0D79FF),
        ),
      ],
    );
  }

  /// Show frequency picker
  Future<void> _showFrequencyPicker() async {
    final selected = await showModalBottomSheet<RecurringPattern>(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: RecurringPattern.values.map((pattern) {
              return ListTile(
                title: Text(pattern.displayName),
                onTap: () => Navigator.pop(context, pattern),
                selected: _selectedRecurring == pattern,
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _selectedRecurring = selected);
    }
  }

  /// Build date selector
  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 20,
              color: Color(0xFF7F97AA),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formatDate(_selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2B3B4A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build time selector
  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time,
              size: 20,
              color: Color(0xFF7F97AA),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formatTime(_selectedTime),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2B3B4A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build recurring pattern selector
  Widget _buildRecurringSelector() {
    return DropdownButtonFormField<RecurringPattern>(
      value: _selectedRecurring,
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedRecurring = value);
        }
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F6F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF2B3B4A),
      ),
      dropdownColor: Colors.white,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF7F97AA)),
      items: RecurringPattern.values.map((pattern) {
        return DropdownMenuItem(
          value: pattern,
          child: Text(pattern.displayName),
        );
      }).toList(),
    );
  }

  /// Build save button
  Widget _buildSaveButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveReminder,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D79FF),
          disabledBackgroundColor: const Color(0xFF7F97AA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Save',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  /// Select date
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D79FF),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Select time
  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D79FF),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  /// Save reminder
  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Combine date and time
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final provider = context.read<RemindersProvider>();

      final reminder = Reminder(
        id: widget.reminder?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        type: _selectedType,
        dateTime: dateTime,
        recurring: _selectedRecurring,
        isCompleted: widget.reminder?.isCompleted ?? false,
        notes: _notesController.text.trim(),
        iconKey: widget.reminder?.iconKey ?? 'default',
        notificationId: widget.reminder?.notificationId,
      );

      bool success;
      if (widget.reminder != null) {
        // Update existing reminder
        success = await provider.updateReminder(reminder);
      } else {
        // Add new reminder
        success = await provider.addReminder(reminder);
      }

      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.reminder != null
                    ? 'Reminder updated successfully'
                    : 'Reminder added successfully',
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save reminder'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFFE53935),
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
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Format time for display
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
