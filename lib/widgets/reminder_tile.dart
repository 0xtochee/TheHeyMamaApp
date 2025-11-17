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
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFF1F4F6),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Leading icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  reminder.icon,
                  color: const Color(0xFF7F97AA),
                  size: 24,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2B3B4A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          reminder.formattedTime,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7F97AA),
                          ),
                        ),
                        if (reminder.recurring != RecurringPattern.none) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              reminder.recurring.displayName,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF0D79FF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Status icon (check or clock)
              GestureDetector(
                onTap: onToggleComplete,
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: reminder.isCompleted
                        ? const Icon(
                            Icons.check_circle,
                            key: ValueKey('completed'),
                            color: Color(0xFF0D79FF),
                            size: 28,
                            semanticLabel: 'Completed',
                          )
                        : const Icon(
                            Icons.radio_button_unchecked,
                            key: ValueKey('pending'),
                            color: Color(0xFF7F97AA),
                            size: 28,
                            semanticLabel: 'Pending',
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
