import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_helper.dart';

/// Data Permissions Screen
///
/// Allows users to manage their data permissions including
/// health data access, location services, notifications, and analytics
class DataPermissionsScreen extends StatefulWidget {
  const DataPermissionsScreen({super.key});

  @override
  State<DataPermissionsScreen> createState() => _DataPermissionsScreenState();
}

class _DataPermissionsScreenState extends State<DataPermissionsScreen> {
  static const Color _primaryBlue = Color(0xFF4A90E2);
  static const Color _headingText = Color(0xFF182033);
  static const Color _subtext = Color(0xFF5B6B7A);

  bool _healthDataAccess = false;
  bool _locationServices = false;
  bool _notifications = false;
  bool _usageAnalytics = false;

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
          'Data Permissions',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Your Data',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _headingText,
                ),
              ),
              const SizedBox(height: 24),

              // Health Data Access
              _buildPermissionItem(
                title: 'Health Data Access',
                description:
                    'Allows the app to track your health metrics for personalized insights.',
                value: _healthDataAccess,
                onChanged: (value) {
                  setState(() {
                    _healthDataAccess = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Location Services
              _buildPermissionItem(
                title: 'Location Services',
                description:
                    'Enables location-based services like finding nearby healthcare providers.',
                value: _locationServices,
                onChanged: (value) {
                  setState(() {
                    _locationServices = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Notifications
              _buildPermissionItem(
                title: 'Notifications',
                description:
                    'Receive timely updates and reminders about appointments and health tips.',
                value: _notifications,
                onChanged: (value) {
                  setState(() {
                    _notifications = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Usage Analytics
              _buildPermissionItem(
                title: 'Usage Analytics',
                description:
                    'Helps us improve the app and personalize your experience.',
                value: _usageAnalytics,
                onChanged: (value) {
                  setState(() {
                    _usageAnalytics = value;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Privacy notice
              Text(
                'We value your privacy. Review our privacy policy to understand how we handle your data.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _subtext,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // View Privacy Policy button
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Navigate to privacy policy
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy policy coming soon'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'View Privacy Policy',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _headingText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _subtext,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: _primaryBlue,
        ),
      ],
    );
  }
}
