import 'package:flutter/material.dart';

import '../services/secure_storage.dart';
import 'onboarding_screen.dart';
import 'pregnancy_dashboard_screen.dart';

/// Initial Screen - Determines which screen to show first
///
/// Logic:
/// 1. First launch → Onboarding
/// 2. Onboarding complete but not signed in → Sign In
/// 3. Signed in with "Remember me" → Dashboard
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToCorrectScreen();
  }

  Future<void> _navigateToCorrectScreen() async {
    try {
      // Small delay for splash effect
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      String? authToken;
      String? userEmail;

      try {
        authToken = await SecureStorage.instance.getAuthToken();
        userEmail = await SecureStorage.instance.getUserEmail();
      } catch (e) {
        // Secure storage might not be available on all platforms
        print('Secure storage error: $e');
      }

      Widget nextScreen;

      if (authToken != null && userEmail != null) {
        // User is authenticated - go directly to dashboard
        nextScreen = const PregnancyDashboardScreen();
      } else {
        // Not authenticated - show onboarding
        nextScreen = const OnboardingScreen();
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => nextScreen),
        );
      }
    } catch (e) {
      print('Navigation error: $e');
      // Fallback to onboarding on error
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Splash screen while determining route
    return Scaffold(
      backgroundColor: const Color(0xFF1976D2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon/logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.favorite,
                size: 60,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 24),
            // App name
            const Text(
              'Pregnancy Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Loading indicator
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
