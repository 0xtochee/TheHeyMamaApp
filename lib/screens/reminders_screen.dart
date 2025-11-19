import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reminder.dart';
import '../providers/reminders_provider.dart';
import '../widgets/reminder_tile.dart';
import 'add_edit_reminder_screen.dart';

/// Main reminders screen displaying medication and appointment reminders
///
/// Features:
/// - Grouped sections by reminder type (Medication, Appointment)
/// - Pixel-faithful UI matching design specifications
/// - Floating action button to add new reminders
/// - Edit/delete functionality per reminder
/// - Toggle completion status
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key, this.embedInParent = false});

  /// When true, returns only the inner content without Scaffold or FAB.
  final bool embedInParent;

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch reminders when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RemindersProvider>().fetchReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = SafeArea(
      child: Column(
        children: [
          // Custom app bar
          _buildAppBar(context),

          // Reminders list
          Expanded(
            child: Consumer<RemindersProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF0D79FF),
                      ),
                    ),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Color(0xFFE53935),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading reminders',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            provider.error!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            provider.clearError();
                            provider.fetchReminders();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D79FF),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return _buildRemindersList(provider);
              },
            ),
          ),
        ],
      ),
    );

    if (widget.embedInParent) {
      return bodyContent;
    }

    // Default: standalone scaffold with FAB
    return Scaffold(
      backgroundColor: Colors.white,
      body: bodyContent,
      // Floating Add button
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Build custom app bar
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF2B3B4A),
              ),
            ),
          ),

          // Title
          const Expanded(
            child: Text(
              'Reminders',
              textAlign: TextAlign.center,
              style: TextStyle(
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

  /// Build reminders list content
  Widget _buildRemindersList(RemindersProvider provider) {
    final medicationReminders =
        provider.remindersByType(ReminderType.medication);
    final appointmentReminders =
        provider.remindersByType(ReminderType.appointment);

    // Check if any reminders exist
    if (medicationReminders.isEmpty && appointmentReminders.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Medication section
          if (medicationReminders.isNotEmpty) ...[
            _buildSectionHeader('Medication'),
            const SizedBox(height: 12),
            ...medicationReminders.map(
              (reminder) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReminderTile(reminder, provider),
              ),
            ),
            const SizedBox(height: 16),
          ] else
            _buildEmptySection('Medication'),

          const SizedBox(height: 12),

          // Appointment section
          if (appointmentReminders.isNotEmpty) ...[
            _buildSectionHeader('Appointment'),
            const SizedBox(height: 12),
            ...appointmentReminders.map(
              (reminder) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReminderTile(reminder, provider),
              ),
            ),
          ] else
            _buildEmptySection('Appointment'),

          // Bottom padding for FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Color(0xFF2B3B4A),
      ),
    );
  }

  /// Build empty section placeholder
  Widget _buildEmptySection(String sectionName) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            'No $sectionName reminders',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F97AA),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _navigateToAddReminder(
              sectionName == 'Medication'
                  ? ReminderType.medication
                  : ReminderType.appointment,
            ),
            child: const Text(
              'Add',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF0D79FF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state when no reminders exist
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F6),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.notifications_none,
                size: 40,
                color: Color(0xFF7F97AA),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No reminders yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2B3B4A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add reminders for medications and appointments to stay on track',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7F97AA),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddReminder(null),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D79FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Reminder',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual reminder tile
  Widget _buildReminderTile(Reminder reminder, RemindersProvider provider) {
    return ReminderTile(
      reminder: reminder,
      onTap: () => _navigateToEditReminder(reminder),
      onLongPress: () => _showDeleteConfirmation(reminder, provider),
      onToggleComplete: () async {
        await provider.toggleComplete(reminder.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                reminder.isCompleted
                    ? 'Reminder marked as incomplete'
                    : 'Reminder completed',
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      onDelete: () async {
        await provider.deleteReminder(reminder.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reminder deleted'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D79FF),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D79FF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToAddReminder(null),
          borderRadius: BorderRadius.circular(28),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Add Reminder',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to add reminder screen
  Future<void> _navigateToAddReminder(ReminderType? initialType) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditReminderScreen(
          initialType: initialType,
        ),
      ),
    );

    // Refresh if a reminder was added
    if (result == true && mounted) {
      context.read<RemindersProvider>().fetchReminders();
    }
  }

  /// Navigate to edit reminder screen
  Future<void> _navigateToEditReminder(Reminder reminder) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditReminderScreen(
          reminder: reminder,
        ),
      ),
    );

    // Refresh if reminder was updated
    if (result == true && mounted) {
      context.read<RemindersProvider>().fetchReminders();
    }
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(
    Reminder reminder,
    RemindersProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE53935),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await provider.deleteReminder(reminder.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder deleted'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
