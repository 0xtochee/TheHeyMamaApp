import 'package:flutter/material.dart';

/// Card widget for displaying health alerts
///
/// Shows an alert with title, headline, message, optional image,
/// and optional action button for urgent notifications.
class AlertCard extends StatelessWidget {
  final String title;
  final String headline;
  final String message;
  final String? imagePath;
  final bool hasAction;
  final VoidCallback? onActionPressed;
  final VoidCallback? onDismiss;

  const AlertCard({
    super.key,
    required this.title,
    required this.headline,
    required this.message,
    this.imagePath,
    this.hasAction = false,
    this.onActionPressed,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade100.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and dismiss button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                if (onDismiss != null)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: onDismiss,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      tooltip: 'Dismiss alert',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Main content row with text and optional image
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Headline
                      Text(
                        headline,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2332),
                          letterSpacing: -0.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                      const SizedBox(height: 10),
                      // Message
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Optional image
                if (imagePath != null) ...[
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      imagePath!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback icon if asset is missing
                        return Icon(
                          Icons.warning_amber_rounded,
                          size: 50,
                          color: Colors.orange.shade400,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
            // Optional action button
            if (hasAction && onActionPressed != null) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onActionPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: const Color(0xFF1976D2).withOpacity(0.3),
                  ),
                  child: const Text(
                    'Contact Doctor',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
