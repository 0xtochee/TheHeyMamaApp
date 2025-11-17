import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_helper.dart';

/// My Pregnancy Screen
///
/// Displays pregnancy progress including current week, trimester,
/// baby's development information, and tips
class MyPregnancyScreen extends StatelessWidget {
  const MyPregnancyScreen({super.key});

  static const Color _primaryBlue = Color(0xFF4A90E2);
  static const Color _headingText = Color(0xFF182033);
  static const Color _subtext = Color(0xFF5B6B7A);
  static const Color _lightGrey = Color(0xFFF5F6F7);
  static const Color _progressTrack = Color(0xFFE6E9EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Pregnancy',
          style: GoogleFonts.inter(
            fontSize: ResponsiveHelper.getTitleFontSize(context),
            fontWeight: FontWeight.w600,
            color: _headingText,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getHorizontalPadding(context),
            vertical: ResponsiveHelper.getVerticalPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pregnancy illustration
              _buildPregnancyIllustration(),
              const SizedBox(height: 24),

              // Week and Trimester info
              _buildWeekInfo(),
              const SizedBox(height: 32),

              // Pregnancy Progress
              _buildProgressSection(),
              const SizedBox(height: 32),

              // Baby's development
              _buildDevelopmentSection(),
              const SizedBox(height: 32),

              // Tips section
              _buildTipsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPregnancyIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(60),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: Image.asset(
          'assets/images/my_preg_img.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.pregnant_woman_rounded,
                size: 60,
                color: const Color(0xFFFFB74D),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeekInfo() {
    return Column(
      children: [
        Text(
          'Week 12',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _headingText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '1st Trimester',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: _subtext,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pregnancy Progress',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _headingText,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 12 / 40,
            backgroundColor: _progressTrack,
            valueColor: AlwaysStoppedAnimation<Color>(_primaryBlue),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '12/40 Weeks',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: _subtext,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Estimated due date',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _subtext,
              ),
            ),
            Text(
              'Nov 24, 2025',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _headingText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Baby's size",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _subtext,
              ),
            ),
            Text(
              'Plum',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _headingText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDevelopmentSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _lightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Baby's development",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _headingText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your baby is now about the size of a plum, measuring around 2.1 inches (5.4 cm) long and weighing about 0.5 ounces (14 grams).',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _subtext,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips for you',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _headingText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Week 12',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: _subtext,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _lightGrey,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stay hydrated',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _headingText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Drink plenty of water today to support your body's increased needs and prevent dehydration.",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _subtext,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0B2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/tip_for_img.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.pregnant_woman_rounded,
                          size: 40,
                          color: const Color(0xFFFF8A65),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
