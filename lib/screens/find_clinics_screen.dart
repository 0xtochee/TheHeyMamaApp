import 'package:flutter/material.dart';
import 'clinic_details_screen.dart';

/// Screen for finding nearby clinics
class FindClinicsScreen extends StatelessWidget {
  const FindClinicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            _buildAppBar(context),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Search bar
                    _buildSearchBar(),
                    const SizedBox(height: 20),

                    // Map
                    _buildMap(),
                    const SizedBox(height: 24),

                    // Nearby Clinics section
                    const Text(
                      'Nearby Clinics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2B3B4A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Clinic cards
                    _buildClinicCard(
                      context,
                      imagePath: 'assets/images/clinic_1.png',
                      name: 'Golden Gate Clinic',
                      address: '123 Main St, San Francisco',
                      type: 'Public Hospital',
                      distance: '2.3km',
                      waitTime: '45 mins wait',
                      status: 'Open Now',
                      isEmergency: true,
                    ),
                    const SizedBox(height: 16),
                    _buildClinicCard(
                      context,
                      imagePath: 'assets/images/clinic_2.png',
                      name: 'Bay Area Women\'s Health',
                      address: '456 Oak Ave, Oakland',
                      type: 'Private Hospital',
                      distance: '2.3km',
                      waitTime: '45 mins wait',
                      status: 'Open Now',
                      isEmergency: false,
                    ),
                    const SizedBox(height: 16),
                    _buildClinicCard(
                      context,
                      imagePath: 'assets/images/clinic_3.png',
                      name: 'Coastal Family Clinic',
                      address: '789 Pine Ln, Berkeley',
                      type: 'Public Hospital',
                      distance: '2.3km',
                      waitTime: '45 mins wait',
                      status: 'Open Now',
                      isEmergency: false,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build app bar
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF2B3B4A),
              ),
            ),
          ),

          // Title
          const Expanded(
            child: Text(
              'Find Clinics',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2B3B4A),
              ),
            ),
          ),

          // Spacer for symmetry
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  /// Build search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.search,
            color: Color(0xFF7F97AA),
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for clinics',
                hintStyle: TextStyle(
                  color: Color(0xFF7F97AA),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build map
  Widget _buildMap() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/map.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// Build clinic card
  Widget _buildClinicCard(
    BuildContext context, {
    required String imagePath,
    required String name,
    required String address,
    required String type,
    required String distance,
    required String waitTime,
    required String status,
    required bool isEmergency,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClinicDetailsScreen(
              imagePath: imagePath,
              name: name,
              address: address,
              isEmergency: isEmergency,
            ),
          ),
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clinic image
            Stack(
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isEmergency)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_hospital,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Emergency',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Clinic info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2B3B4A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFF7F97AA),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7F97AA),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.business, type),
                      _buildInfoChip(Icons.directions, distance),
                      _buildInfoChip(Icons.access_time, waitTime),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build info chip
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF7F97AA),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7F97AA),
            ),
          ),
        ],
      ),
    );
  }
}
