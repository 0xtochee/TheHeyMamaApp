import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/secure_storage.dart';
import '../utils/responsive_helper.dart';

/// Settings & Account Screen
///
/// Displays account settings and logout functionality
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color _primaryBlue = Color(0xFF0D79FF);
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
              // Account Section
              _buildSectionTitle('Account'),
              const SizedBox(height: 16),
              _buildSettingItem(
                context: context,
                icon: Icons.person_outline,
                title: 'Profile Information',
                subtitle: 'Update your personal details',
                onTap: () {
                  // TODO: Navigate to profile screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile settings coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildSettingItem(
                context: context,
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () {
                  // TODO: Navigate to change password screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Change password coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Preferences Section
              _buildSectionTitle('Preferences'),
              const SizedBox(height: 16),
              _buildSettingItem(
                context: context,
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () {
                  // TODO: Navigate to notifications settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification settings coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildSettingItem(
                context: context,
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: 'English (US)',
                onTap: () {
                  // TODO: Navigate to language settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Language settings coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Support Section
              _buildSectionTitle('Support'),
              const SizedBox(height: 16),
              _buildSettingItem(
                context: context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
                onTap: () {
                  // TODO: Navigate to help screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Help center coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildSettingItem(
                context: context,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () {
                  _showAboutDialog(context);
                },
              ),

              const SizedBox(height: 48),

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
        color: _subtext,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE6E9EE)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
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
                      fontSize: ResponsiveHelper.getHeadingFontSize(context),
                      fontWeight: FontWeight.w500,
                      color: _headingText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveHelper.getBodyFontSize(context),
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

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.getButtonHeight(context),
      child: OutlinedButton.icon(
        onPressed: () => _handleLogout(context),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _errorRed, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        icon: const Icon(Icons.logout, color: _errorRed),
        label: Text(
          'Logout',
          style: GoogleFonts.inter(
            fontSize: ResponsiveHelper.getHeadingFontSize(context),
            fontWeight: FontWeight.w600,
            color: _errorRed,
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
      // Clear all authentication data
      await SecureStorage.instance.clearAuthData();

      // Navigate to sign-in screen and clear all previous routes
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/sign-in',
          (route) => false,
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'About Pregnancy Dashboard',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _headingText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: _headingText,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'A comprehensive pregnancy monitoring dashboard with vital tracking and alerts.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _subtext,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
