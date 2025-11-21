import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'more_screen.dart';
import 'pregnancy_dashboard_screen.dart';
import 'reminders_screen.dart';
import 'track_vitals_screen.dart';

/// Top-level HomeScreen that keeps a persistent BottomNavigationBar
/// and switches between main app sections using an IndexedStack.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialIndex = 0});

  /// The initially selected tab index. Useful when opening the app
  /// directly to Track/Reminders/More via named routes.
  final int initialIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    const PregnancyDashboardScreen(embedInParent: true),
    const TrackVitalsScreen(embedInParent: true),
    const RemindersScreen(embedInParent: true),
    const MoreScreen(embedInParent: true),
  ];

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Track'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Reminders'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
