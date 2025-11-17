import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/doctor.dart';
import '../providers/doctor_provider.dart';
import '../widgets/doctor_tile.dart';

/// Doctor Directory Screen
///
/// Displays a searchable list of available doctors with booking functionality.
/// Users can browse doctors, search by name or specialty, and book appointments.
class DoctorDirectoryScreen extends StatefulWidget {
  const DoctorDirectoryScreen({super.key});

  @override
  State<DoctorDirectoryScreen> createState() => _DoctorDirectoryScreenState();
}

class _DoctorDirectoryScreenState extends State<DoctorDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Doctor> _filteredDoctors = [];
  bool _isSearching = false;

  // Design constants
  static const Color _primaryBlue = Color(0xFF0D79FF);
  static const Color _headingText = Color(0xFF182033);
  static const Color _subtext = Color(0xFF5B6B7A);
  static const double _horizontalPadding = 20.0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Handle search query changes
  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        final provider = Provider.of<DoctorProvider>(context, listen: false);
        _filteredDoctors = provider.searchDoctors(query);
      }
    });
  }

  /// Navigate to booking screen
  void _navigateToBooking(Doctor doctor) {
    Navigator.pushNamed(
      context,
      '/bookAppointment',
      arguments: doctor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
                vertical: 16,
              ),
              child: _buildSearchBar(),
            ),

            // Doctor List
            Expanded(
              child: _buildDoctorList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build top bar with back button and title
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE6E9EE).withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          Semantics(
            label: 'Go back',
            button: true,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: _headingText,
                ),
              ),
            ),
          ),

          // Title
          const Expanded(
            child: Text(
              'Doctor Directory',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: _headingText,
              ),
            ),
          ),

          // Spacer for symmetry
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  /// Build search bar
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search doctors...',
          hintStyle: GoogleFonts.inter(
            fontSize: 15,
            color: _subtext,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: _subtext,
            size: 22,
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: _subtext,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _isSearching = false;
                      _filteredDoctors = [];
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: GoogleFonts.inter(
          fontSize: 15,
          color: _headingText,
        ),
      ),
    );
  }

  /// Build doctor list
  Widget _buildDoctorList() {
    return Consumer<DoctorProvider>(
      builder: (context, provider, child) {
        final doctors = _isSearching ? _filteredDoctors : provider.doctors;

        if (doctors.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: _horizontalPadding,
            vertical: 8,
          ),
          itemCount: doctors.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return DoctorTile(
              doctor: doctor,
              onBook: () => _navigateToBooking(doctor),
              onTap: () {
                // Optional: Navigate to doctor detail screen
                // For now, just navigate to booking
                _navigateToBooking(doctor);
              },
            );
          },
        );
      },
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    final message = _isSearching
        ? 'No doctors found matching "${_searchController.text}"'
        : 'No doctors available';

    final subtitle = _isSearching
        ? 'Try searching with different keywords'
        : 'Please check back later';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                size: 40,
                color: _subtext,
              ),
            ),

            const SizedBox(height: 24),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _headingText,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _subtext,
              ),
            ),

            if (_isSearching) ...[
              const SizedBox(height: 24),
              // Clear search button
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _isSearching = false;
                    _filteredDoctors = [];
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: _primaryBlue,
                ),
                child: Text(
                  'Clear Search',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
