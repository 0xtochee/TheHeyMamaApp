import 'package:flutter/material.dart';
import '../models/reminder.dart';

/// Reusable widget for displaying a reminder item in a list
///
/// Features:
/// - Icon container with light grey background
/// - Title and time display
/// - Status icon (check/clock) based on completion
/// - Tap to edit, long-press to delete
/// - Swipe-right to toggle complete (if provided)
class ReminderTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;

  const ReminderTile({
    super.key,
    required this.reminder,
    this.onTap,
    this.onLongPress,
    this.onToggleComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('reminder_${reminder.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        // Show confirmation dialog for delete
        if (onDelete != null) {
          return await _showDeleteDialog(context);
        }
        return false;
      },
      onDismissed: (direction) {
        onDelete?.call();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Leading icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  reminder.icon,
                  color: const Color(0xFF7F97AA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Title and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      reminder.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF2B3B4A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimeOnly(reminder.dateTime),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7F97AA),
                      ),
                    ),
                  ],
                ),
              ),

              // Status/Action icon
              GestureDetector(
                onTap: onToggleComplete ?? onTap,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    reminder.isCompleted
                        ? Icons.check_circle
                        : Icons.access_time,
                    color: reminder.isCompleted
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF7F97AA),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Format time only (e.g., "8:00 AM")
  String _formatTimeOnly(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  Future<bool?> _showDeleteDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Reminder'),
          content: const Text('Are you sure you want to delete this reminder?'),
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
        );
      },
    );
  }
}
