import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Onboarding Screen with multiple slides
///
/// Shows a beautiful introduction to the app features.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Track Your Journey',
      description:
          'Monitor your pregnancy health with comprehensive vital signs tracking and personalized insights.',
      icon: Icons.favorite,
      color: const Color(0xFFE3F2FD),
      iconColor: const Color(0xFF1976D2),
    ),
    OnboardingPage(
      title: 'Stay Informed',
      description:
          'Get real-time health alerts, daily tips, and expert guidance throughout your pregnancy.',
      icon: Icons.notifications_active,
      color: const Color(0xFFFCE4EC),
      iconColor: const Color(0xFFE91E63),
    ),
    OnboardingPage(
      title: 'Never Miss a Beat',
      description:
          'Set reminders for medications, appointments, and important milestones.',
      icon: Icons.alarm,
      color: const Color(0xFFF3E5F5),
      iconColor: const Color(0xFF9C27B0),
    ),
    OnboardingPage(
      title: 'Connect with Care',
      description:
          'Book appointments with trusted doctors and access support whenever you need it.',
      icon: Icons.medical_services,
      color: const Color(0xFFE8F5E9),
      iconColor: const Color(0xFF4CAF50),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (mounted) {
      Navigator.pushNamed(context, '/sign-in');
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicators
            _buildPageIndicators(),
            const SizedBox(height: 32),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: page.color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 70,
              color: page.iconColor,
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF182033),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF5B6B7A),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => Container(
          width: _currentPage == index ? 32 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentPage == index
                ? const Color(0xFF1976D2)
                : const Color(0xFFE6E9EE),
          ),
        ),
      ),
    );
  }
}

/// Model for onboarding page data
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color iconColor;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.iconColor,
  });
}
