import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/vitals_provider.dart';
import '../widgets/vital_card.dart';
import '../widgets/alert_card.dart';
import '../widgets/daily_tip_card.dart';
import '../utils/responsive_helper.dart';

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
  const PregnancyDashboardScreen({super.key});

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
      ),
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
                fontSize: ResponsiveHelper.getTitleFontSize(context),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2332),
              ),
            ),
            SizedBox(height: ResponsiveHelper.getItemSpacing(context)),
            LayoutBuilder(
          builder: (context, vitalConstraints) {
            // Calculate responsive card height based on screen
            final cardHeight = ResponsiveHelper.isMobile(context) ? 180.0 : 220.0;
            final spacing = ResponsiveHelper.getItemSpacing(context);

            // On large screens or when width allows, show cards side by side
            if (isLargeScreen || vitalConstraints.maxWidth > 400) {
              return SizedBox(
                height: cardHeight,
                child: Row(
                  children: [
                    Expanded(
                      child: VitalCard(
                        iconPath: 'assets/images/blood_pressure.png',
                        value: '$bpValue mmHg',
                        label: 'Blood Pressure',
                        gradientColors: const [Color(0xFFE3F2FD), Color(0xFF90CAF9)],
                        onTap: () => _navigateToVitalDetail('blood_pressure'),
                      ),
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      child: VitalCard(
                        iconPath: 'assets/images/heart_rate.png',
                        value: '$hrValue bpm',
                        label: 'Heart Rate',
                        gradientColors: const [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
                        onTap: () => _navigateToVitalDetail('heart_rate'),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // On smaller screens, stack vertically
              return Column(
                children: [
                  SizedBox(
                    height: cardHeight,
                    child: VitalCard(
                        iconPath: 'assets/images/blood_pressure.png',
                        value: '$bpValue mmHg',
                        label: 'Blood Pressure',
                        gradientColors: const [Color(0xFFE3F2FD), Color(0xFF90CAF9)],
                      onTap: () => _navigateToVitalDetail('blood_pressure'),
                    ),
                  ),
                  SizedBox(height: spacing),
                  SizedBox(
                    height: cardHeight,
                    child: VitalCard(
                        iconPath: 'assets/images/heart_rate.png',
                        value: '$hrValue bpm',
                        label: 'Heart Rate',
                        gradientColors: const [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
                      onTap: () => _navigateToVitalDetail('heart_rate'),
                    ),
                  ),
                ],
              );
            }
          },
            ),
          ],
        );
      },
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
