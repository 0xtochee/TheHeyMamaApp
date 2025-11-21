import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'models/doctor.dart';
import 'providers/appointments_provider.dart';
import 'providers/doctor_provider.dart';
import 'providers/reminders_provider.dart';
import 'providers/symptoms_provider.dart';
import 'providers/vitals_provider.dart';
import 'screens/add_vitals_screen.dart';
import 'screens/book_appointment_screen.dart';
import 'screens/data_permissions_screen.dart';
import 'screens/doctor_directory_screen.dart';
import 'screens/educational_tips_screen.dart';
import 'screens/home_screen.dart';
import 'screens/initial_screen.dart';
import 'screens/log_symptoms_screen.dart';
import 'screens/medical_history_screen.dart';
import 'screens/my_pregnancy_screen.dart';
import 'screens/new_reminder_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/personal_info_screen.dart';
import 'screens/settings_account_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
// Note: `More`, `Reminders`, and `Track` are now available via `HomeScreen`.
// Screens are still present for standalone use but are not imported here.
import 'screens/user_details_screen.dart';
import 'services/notification_service.dart';

/// Main entry point for the Pregnancy Dashboard application
///
/// This app provides comprehensive pregnancy monitoring with:
/// - Vital signs tracking (Blood Pressure, Heart Rate)
/// - Health alerts and notifications
/// - Daily health tips
/// - Local data persistence
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DEVELOPMENT ONLY: Clear all data for testing
  // Comment out this line to preserve user data between app restarts
  // await DevUtils.clearAllData();

  // Initialize notification service (includes timezone initialization)
  await NotificationService().initialize();

  runApp(const PregnancyDashboardApp());
}

/// Root application widget with theme and state management setup
class PregnancyDashboardApp extends StatelessWidget {
  const PregnancyDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => VitalsProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => SymptomsProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => RemindersProvider()..fetchReminders(),
        ),
        ChangeNotifierProvider(
          create: (_) => DoctorProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => AppointmentsProvider()..fetchAppointments(),
        ),
      ],
      child: MaterialApp(
        title: 'Pregnancy Dashboard',
        debugShowCheckedModeBanner: false,
        theme: _buildAppTheme(),
        home: const InitialScreen(),
        // Named routes for navigation
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/sign-in': (context) => const SignInScreen(),
          '/sign-up': (context) => const SignUpScreen(),
          '/user-details': (context) => const UserDetailsScreen(),
          '/dashboard': (context) => const HomeScreen(),
          '/add-vitals': (context) => const AddVitalsScreen(),
          '/track': (context) => const HomeScreen(initialIndex: 1),
          '/log-symptoms': (context) => const LogSymptomsScreen(),
          '/reminders': (context) => const HomeScreen(initialIndex: 2),
          '/newReminder': (context) => const NewReminderScreen(),
          '/more': (context) => const HomeScreen(initialIndex: 3),
          '/settings': (context) => const SettingsScreen(),
          '/settings-account': (context) => const SettingsAccountScreen(),
          '/personal-info': (context) => const PersonalInfoScreen(),
          '/my-pregnancy': (context) => const MyPregnancyScreen(),
          '/data-permissions': (context) => const DataPermissionsScreen(),
          '/doctorDirectory': (context) => const DoctorDirectoryScreen(),
          '/educational-tips': (context) => const EducationalTipsScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle routes that need to pass arguments
          if (settings.name == '/bookAppointment') {
            final doctor = settings.arguments as Doctor;
            return MaterialPageRoute(
              builder: (context) => BookAppointmentScreen(doctor: doctor),
            );
          }
          if (settings.name == '/medical-history') {
            final userDetails = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) =>
                  MedicalHistoryScreen(userDetails: userDetails),
            );
          }
          return null;
        },
      ),
    );
  }

  /// Build the application theme with custom colors and typography
  ThemeData _buildAppTheme() {
    // Color constants
    const primaryColor = Color(0xFF1976D2); // Blue
    const secondaryColor = Color(0xFF1A2332); // Dark navy
    const backgroundColor = Color(0xFFFFFFFF); // White
    const cardColor = Color(0xFFF5F6F7); // Light grey
    const errorColor = Color(0xFFE53935); // Red

    return ThemeData(
      // Color scheme
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor,
        surface: cardColor,
      ),

      // Scaffold background
      scaffoldBackgroundColor: backgroundColor,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: secondaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: secondaryColor,
        ),
      ),

      // Card theme
      cardTheme: const CardTheme(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.zero,
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
        ),
      ),

      // Typography theme using Google Fonts
      textTheme: TextTheme(
        // Headings
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: secondaryColor,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: secondaryColor,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: secondaryColor,
        ),

        // Titles
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: secondaryColor,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: secondaryColor,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: secondaryColor,
        ),

        // Body text
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: secondaryColor,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.grey.shade700,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),

        // Labels
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.grey.shade500,
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: secondaryColor,
        size: 24,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
        space: 1,
      ),

      // Use Material 3
      useMaterial3: true,
    );
  }
}
