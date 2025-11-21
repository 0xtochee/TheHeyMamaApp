import 'package:flutter/material.dart';

/// Screen showing detailed information about a specific clinic
class ClinicDetailsScreen extends StatelessWidget {
  final String imagePath;
  final String name;
  final String address;
  final bool isEmergency;

  const ClinicDetailsScreen({
    super.key,
    required this.imagePath,
    required this.name,
    required this.address,
    required this.isEmergency,
  });

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero image
                    _buildHeroImage(),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Clinic name and status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 22,
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
                                child: const Text(
                                  'Open Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Address
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 18,
                                color: Color(0xFF7F97AA),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  address,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF7F97AA),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Contact
                          const Row(
                            children: [
                              Text(
                                'Contact: ',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2B3B4A),
                                ),
                              ),
                              Text(
                                '(555) 123-4567',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF0D79FF),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Hours
                          const Text(
                            'Mon-Fri: 9 AM - 6 PM, Sat: 10 AM - 2 PM',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F97AA),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Services Offered
                          const Text(
                            'Services Offered',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2B3B4A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildServiceItem('Prenatal Care'),
                          _buildServiceItem('Ultrasound'),
                          _buildServiceItem('Genetic Counseling'),
                          _buildServiceItem('Postpartum Care'),
                          const SizedBox(height: 24),

                          // Photos
                          const Text(
                            'Photos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2B3B4A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildPhotosRow(),
                          const SizedBox(height: 24),

                          // Action buttons
                          _buildActionButton(
                            'Book Appointment',
                            const Color(0xFF0D79FF),
                            Colors.white,
                            () {
                              // TODO: Implement booking
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            'Get Directions',
                            Colors.white,
                            const Color(0xFF0D79FF),
                            () {
                              // TODO: Implement directions
                            },
                            hasBorder: true,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
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
              'Clinic Details',
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

  /// Build hero image
  Widget _buildHeroImage() {
    return Stack(
      children: [
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (isEmergency)
          Positioned(
            top: 16,
            right: 16,
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
    );
  }

  /// Build service item
  Widget _buildServiceItem(String service) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF0D79FF),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            service,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF2B3B4A),
            ),
          ),
        ],
      ),
    );
  }

  /// Build photos row
  Widget _buildPhotosRow() {
    return SizedBox(
      height: 90,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/clinic_inside_1.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/clinic_inside_2.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/clinic_inside_3.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build action button
  Widget _buildActionButton(
    String label,
    Color backgroundColor,
    Color textColor,
    VoidCallback onTap, {
    bool hasBorder = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: hasBorder
                ? const BorderSide(color: Color(0xFF0D79FF), width: 1.5)
                : BorderSide.none,
          ),
          elevation: hasBorder ? 0 : 2,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
