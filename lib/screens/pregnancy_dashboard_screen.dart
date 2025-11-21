import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/vitals_provider.dart';
import '../utils/responsive_helper.dart';
import '../widgets/alert_card.dart';
import '../widgets/daily_tip_card.dart';
import '../widgets/vital_card.dart';
import 'educational_tips_screen.dart';
import 'emergency_screen.dart';
import 'find_clinics_screen.dart';

/// Main dashboard screen for pregnancy monitoring
///
/// Displays:
/// - User greeting and pregnancy week
/// - Vital signs (Blood Pressure, Heart Rate)
/// - Health alerts
/// - Daily health tips
/// - Bottom navigation bar
/// - Floating action button for logging vitals
class PregnancyDashboardScreen extends StatefulWidget {
  const PregnancyDashboardScreen({super.key, this.embedInParent = false});

  /// When true, the widget will return only its inner body (no Scaffold,
  /// no bottom navigation). This allows embedding inside a parent that
  /// provides persistent navigation (e.g. `HomeScreen`).
  final bool embedInParent;

  @override
  State<PregnancyDashboardScreen> createState() =>
      _PregnancyDashboardScreenState();
}

class _PregnancyDashboardScreenState extends State<PregnancyDashboardScreen> {
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize provider data on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VitalsProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive breakpoint for tablet/desktop
          final isLargeScreen = !ResponsiveHelper.isMobile(context);

          return Stack(
            children: [
              // Main scrollable content
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getHorizontalPadding(context),
                  vertical: ResponsiveHelper.getVerticalPadding(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildVitalsSummary(isLargeScreen),
                    const SizedBox(height: 24),
                    _buildLocalLanguageSection(),
                    const SizedBox(height: 24),
                    _buildEmergencyResourcesSection(),
                    const SizedBox(height: 24),
                    _buildAlertsSection(),
                    const SizedBox(height: 24),
                    _buildDailyTipSection(),
                    const SizedBox(height: 24),
                    // Log Vital Button in normal flow (not floating)
                    _buildLogVitalButton(),
                    const SizedBox(height: 16),
                    // Log Symptoms Button
                    _buildLogSymptomsButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    if (widget.embedInParent) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: bodyContent,
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  /// Build the header section with greeting and pregnancy week
  Widget _buildHeader() {
    return Consumer<VitalsProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              'Hello, ${provider.userName} 👋',
              style: GoogleFonts.inter(
                fontSize: ResponsiveHelper.getTitleFontSize(context) + 8,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2332),
              ),
            ),
            const SizedBox(height: 8),
            // Pregnancy week
            Text(
              'You\'re ${provider.pregnancyWeeks} weeks pregnant',
              style: GoogleFonts.inter(
                fontSize: ResponsiveHelper.getHeadingFontSize(context),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build the vitals summary section with BP and HR cards
  Widget _buildVitalsSummary(bool isLargeScreen) {
    return Consumer<VitalsProvider>(
      builder: (context, provider, child) {
        // Get latest vital values or use placeholder
        final bpValue = provider.latestBloodPressure?.value ?? '--';
        final hrValue = provider.latestHeartRate?.value ?? '--';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Vital Summary" Heading
            Text(
              'Vital Summary',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2332),
              ),
            ),
            const SizedBox(height: 16),
            // Cards in a row
            Row(
              children: [
                Expanded(
                  child: _buildVitalCard(
                    value: bpValue == '--' ? bpValue : '$bpValue mmHg',
                    label: 'Blood Pressure',
                    imagePath: 'assets/images/blood_pressure.png',
                    onTap: () => _navigateToVitalDetail('blood_pressure'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVitalCard(
                    value: hrValue == '--' ? hrValue : '$hrValue bpm',
                    label: 'Heart Rate',
                    imagePath: 'assets/images/heart_rate.png',
                    onTap: () => _navigateToVitalDetail('heart_rate'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Build individual vital card with background image
  Widget _buildVitalCard({
    required String value,
    required String label,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to solid color if image fails
                    return Container(
                      color: const Color(0xFF2C2C2C),
                    );
                  },
                ),
              ),
              // Dark overlay for better text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.3),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              // Text content
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Local Language Education section
  Widget _buildLocalLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        Text(
          'Local Language Module',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A2332),
          ),
        ),
        const SizedBox(height: 16),

        // Card
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EducationalTipsScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Local Language Education',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Learn about pregnancy health, preeclampsia warning signs, and care practices in your native language.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Core badge on the right
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF66BB6A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Core',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build Emergency Resources section
  Widget _buildEmergencyResourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        Text(
          'Emergency Resources',
          style: GoogleFonts.inter(
            fontSize: ResponsiveHelper.getTitleFontSize(context),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A2332),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getItemSpacing(context)),

        // Nearby Clinics Card
        _buildEmergencyCard(
          title: 'Nearby Clinics',
          description:
              'Access safe, nearby clinics whenever you need medical attention or urgent maternity care.',
          imagePath: 'assets/images/clinic_1.png',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FindClinicsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Emergency Contacts Card
        _buildEmergencyCard(
          title: 'Emergency Contacts',
          description:
              'Instantly connect with the people who can help you most in an emergency.',
          imagePath: 'assets/images/female_doctor.png',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EmergencyScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build individual emergency resource card
  Widget _buildEmergencyCard({
    required String title,
    required String description,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF1F4F6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2B3B4A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF7F97AA),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the alerts section showing health warnings
  Widget _buildAlertsSection() {
    return Consumer<VitalsProvider>(
      builder: (context, provider, child) {
        // Show alerts if any exist
        if (provider.alerts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Alerts" Heading
            Text(
              'Alerts',
              style: GoogleFonts.inter(
                fontSize: ResponsiveHelper.getTitleFontSize(context),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2332),
              ),
            ),
            SizedBox(height: ResponsiveHelper.getItemSpacing(context)),
            ...provider.alerts.asMap().entries.map((entry) {
              final index = entry.key;
              final alert = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AlertCard(
                  title: alert.title,
                  headline: alert.headline,
                  message: alert.message,
                  imagePath: alert.imagePath,
                  hasAction: alert.hasAction,
                  onActionPressed: () => _handleContactDoctor(),
                  onDismiss: () => provider.removeAlert(index),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  /// Build the daily tip section
  Widget _buildDailyTipSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Tips',
          style: GoogleFonts.inter(
            fontSize: ResponsiveHelper.getTitleFontSize(context),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A2332),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getItemSpacing(context)),
        const DailyTipCard(
          title: 'Nutrition Tip',
          content:
              'Stay hydrated throughout the day. Aim for 8-10 glasses of water daily. '
              'Proper hydration supports healthy blood flow and can help prevent common pregnancy discomforts.',
          imagePath: 'assets/images/nutrition_tip.png',
        ),
      ],
    );
  }

  /// Build the floating action button for logging vitals
  Widget _buildLogVitalButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _handleLogVital(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, size: 24),
            const SizedBox(width: 10),
            Text(
              'Log Vital',
              style: GoogleFonts.inter(
                fontSize: ResponsiveHelper.getHeadingFontSize(context),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the log symptoms button
  Widget _buildLogSymptomsButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _handleLogSymptoms(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medical_information, size: 24),
            const SizedBox(width: 10),
            Text(
              'Log Symptoms',
              style: GoogleFonts.inter(
                fontSize: ResponsiveHelper.getHeadingFontSize(context),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the bottom navigation bar
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: (index) {
        setState(() {
          _selectedNavIndex = index;
        });
        _handleNavigation(index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1976D2),
      unselectedItemColor: Colors.grey.shade600,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getSmallFontSize(context),
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getSmallFontSize(context),
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timeline),
          label: 'Track',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Reminders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: 'More',
        ),
      ],
    );
  }

  // Navigation and action handlers

  /// Navigate to vital detail/logging screen
  /// TODO: Implement detailed vital screens for each type
  void _navigateToVitalDetail(String vitalType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to $vitalType detail screen'),
        duration: const Duration(seconds: 2),
      ),
    );
    // TODO: Navigator.push to detail screen
    // Example: Navigator.pushNamed(context, '/vital-detail', arguments: vitalType);
  }

  /// Handle log vital button press
  /// Navigate to AddVitalsScreen
  void _handleLogVital() async {
    final result = await Navigator.pushNamed(context, '/add-vitals');

    // If vitals were saved, result will contain the VitalRecord
    if (result != null && mounted) {
      // Refresh the dashboard data
      await context.read<VitalsProvider>().loadLatestVitals();
      // Force rebuild to show updated values
      setState(() {});
    }
  }

  /// Handle log symptoms button press
  /// Navigate to LogSymptomsScreen
  void _handleLogSymptoms() async {
    final result = await Navigator.pushNamed(context, '/log-symptoms');

    // If symptoms were saved, refresh the dashboard
    if (result != null && mounted) {
      // Force rebuild to show any updates
      setState(() {});
    }
  }

  /// Handle contact doctor action
  /// TODO: Integrate with messaging/calling functionality
  void _handleContactDoctor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Doctor'),
        content: const Text(
          'This would typically open your messaging app or place a call to your healthcare provider.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    // TODO: Implement actual contact functionality
    // Example: launch('tel:+1234567890') or navigate to messaging
  }

  /// Handle bottom navigation item selection
  void _handleNavigation(int index) async {
    switch (index) {
      case 0:
        // Already on Dashboard
        break;
      case 1:
        // Navigate to Track screen
        await Navigator.pushNamed(context, '/track');
        // Reset selection when coming back
        if (mounted) {
          setState(() => _selectedNavIndex = 0);
        }
        break;
      case 2:
        // Navigate to Reminders screen
        await Navigator.pushNamed(context, '/reminders');
        // Reset selection when coming back
        if (mounted) {
          setState(() => _selectedNavIndex = 0);
        }
        break;
      case 3:
        // Navigate to More screen
        await Navigator.pushNamed(context, '/more');
        // Reset selection when coming back
        if (mounted) {
          setState(() => _selectedNavIndex = 0);
        }
        break;
    }
  }
}
