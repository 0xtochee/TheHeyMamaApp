import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/secure_storage.dart';
import '../utils/responsive_helper.dart';

/// Settings & Account Screen
///
/// Main settings hub with sections for Personal Information,
/// Notifications, Privacy & Security, and Help & Support
class SettingsAccountScreen extends StatelessWidget {
  const SettingsAccountScreen({super.key});

  static const Color _primaryBlue = Color(0xFF4A90E2);
  static const Color _headingText = Color(0xFF182033);
  static const Color _subtext = Color(0xFF5B6B7A);
  static const Color _errorRed = Color(0xFFE53935);

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
          'Settings & Account',
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
              // Personal Information Section
              _buildSectionTitle('Personal Information'),
              const SizedBox(height: 12),
              _buildMenuItem(
                context: context,
                icon: Icons.person_outline,
                title: 'Personal Info',
                subtitle: 'Edit your personal details',
                onTap: () => Navigator.pushNamed(context, '/personal-info'),
              ),
              const SizedBox(height: 8),
              _buildMenuItem(
                context: context,
                icon: Icons.pregnant_woman_outlined,
                title: 'Pregnancy Details',
                subtitle: 'Update your pregnancy details',
                onTap: () => Navigator.pushNamed(context, '/my-pregnancy'),
              ),

              const SizedBox(height: 24),

              // Notifications Section
              _buildSectionTitle('Notifications'),
              const SizedBox(height: 12),
              _buildMenuItemWithSwitch(
                context: context,
                icon: Icons.notifications_none_outlined,
                title: 'Push Notifications',
                subtitle: 'Enable or disable push notifications',
                value: false,
                onChanged: (value) {
                  // TODO: Implement push notification toggle
                },
              ),
              const SizedBox(height: 8),
              _buildMenuItem(
                context: context,
                icon: Icons.access_time_outlined,
                title: 'Reminder Timings',
                subtitle: 'Set reminder timings for appointments',
                onTap: () {
                  // TODO: Navigate to reminder timings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reminder timings coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Privacy & Security Section
              _buildSectionTitle('Privacy & Security'),
              const SizedBox(height: 12),
              _buildMenuItem(
                context: context,
                icon: Icons.lock_outline,
                title: 'Reset Password',
                subtitle: 'Change your password',
                onTap: () {
                  // TODO: Navigate to reset password
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reset password coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildMenuItem(
                context: context,
                icon: Icons.verified_user_outlined,
                title: 'Data Permissions',
                subtitle: 'Manage data permissions',
                onTap: () => Navigator.pushNamed(context, '/data-permissions'),
              ),

              const SizedBox(height: 24),

              // Help & Support Section
              _buildSectionTitle('Help & Support'),
              const SizedBox(height: 12),
              _buildMenuItem(
                context: context,
                icon: Icons.help_outline,
                title: 'FAQ',
                subtitle: 'Frequently asked questions',
                onTap: () {
                  // TODO: Navigate to FAQ
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('FAQ coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildMenuItem(
                context: context,
                icon: Icons.mail_outline,
                title: 'Contact Support',
                subtitle: 'Contact us via email or phone',
                onTap: () {
                  // TODO: Navigate to contact support
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contact support coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Logout Button
              _buildLogoutButton(context),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _headingText,
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: _primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _headingText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _subtext,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _subtext,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemWithSwitch({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: _primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _headingText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _subtext,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.getButtonHeight(context),
      child: ElevatedButton(
        onPressed: () => _handleLogout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF3E0),
          foregroundColor: const Color(0xFFE65100),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          'Logout',
          style: GoogleFonts.inter(
            fontSize: ResponsiveHelper.getHeadingFontSize(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _headingText,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: _headingText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _subtext,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _errorRed,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await SecureStorage.instance.clearAuthData();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/sign-in',
          (route) => false,
        );
      }
    }
  }
}
