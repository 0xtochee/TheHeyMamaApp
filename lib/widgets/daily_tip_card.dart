import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

/// Card widget for displaying daily health tips
///
/// Shows a title, descriptive paragraph, and optional right-aligned image.
class DailyTipCard extends StatelessWidget {
  final String title;
  final String content;
  final String? imagePath;

  const DailyTipCard({
    super.key,
    required this.title,
    required this.content,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // Hide image on small screens
    final shouldShowImage = imagePath != null &&
        MediaQuery.of(context).size.width >= ResponsiveHelper.mobileBreakpoint;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon and Title Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.lightbulb,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2332),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Content
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            // Optional image (only on larger screens)
            if (shouldShowImage) ...[
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(12),
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
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback icon if asset is missing
                    return Icon(
                      Icons.lightbulb_outline,
                      size: 60,
                      color: Colors.green.shade400,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
