import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Educational Tips & Videos Screen
///
/// Displays pregnancy health education courses with:
/// - Progress tracking
/// - Course completion status
/// - Duration and lesson counts
/// - Category tags
class EducationalTipsScreen extends StatelessWidget {
  const EducationalTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2332)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Educational Tips & Videos',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A2332),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Summary Card
            _buildProgressSummary(),
            const SizedBox(height: 24),

            // Course List
            _buildCourseCard(
              context: context,
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFF66BB6A),
              iconBackground: const Color(0xFFE8F5E9),
              title: 'Understanding Preeclampsia',
              description:
                  'Learn about the warning signs, risk factors, and prevention of preeclampsia',
              duration: '15 mins',
              lessonsCount: 5,
              progress: 1.0,
              status: 'Completed',
              statusColor: const Color(0xFF66BB6A),
              tags: ['Beginner', 'Health Conditions'],
            ),
            const SizedBox(height: 16),

            _buildCourseCard(
              context: context,
              icon: Icons.favorite_outline,
              iconColor: const Color(0xFF42A5F5),
              iconBackground: const Color(0xFFE3F2FD),
              title: 'Blood Pressure Monitoring',
              description:
                  'How to properly measure and track your blood pressure during pregnancy',
              duration: '12 mins',
              lessonsCount: 5,
              progress: 0.4,
              status: 'Pending',
              statusColor: const Color(0xFFFF9800),
              tags: ['Beginner', 'Self-Care'],
            ),
            const SizedBox(height: 16),

            _buildCourseCard(
              context: context,
              icon: Icons.restaurant_outlined,
              iconColor: const Color(0xFF66BB6A),
              iconBackground: const Color(0xFFE8F5E9),
              title: 'Healthy Pregnancy Nutrition',
              description:
                  'Essential nutrients and food for a healthy pregnancy in Nigerian context',
              duration: '20 mins',
              lessonsCount: 6,
              progress: 0.0,
              status: 'Not Started',
              statusColor: Colors.grey,
              tags: ['Beginner', 'Nutrition'],
            ),
          ],
        ),
      ),
    );
  }

  /// Build progress summary card
  Widget _buildProgressSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildProgressItem('2/5', 'Completed', const Color(0xFF42A5F5)),
          _buildProgressItem('45 min', 'Time Learned', const Color(0xFF66BB6A)),
          _buildProgressItem('85%', 'Score', const Color(0xFFFF9800)),
        ],
      ),
    );
  }

  /// Build individual progress item
  Widget _buildProgressItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Build individual course card
  Widget _buildCourseCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String description,
    required String duration,
    required int lessonsCount,
    required double progress,
    required String status,
    required Color statusColor,
    required List<String> tags,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and status
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A2332),
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Duration and lessons
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                duration,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 24),
              Text(
                '$lessonsCount lessons',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A2332),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2332),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE9ECEF),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to course detail/player
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Starting course: $title'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF42A5F5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    progress > 0 ? 'Continue' : 'Start Course',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
