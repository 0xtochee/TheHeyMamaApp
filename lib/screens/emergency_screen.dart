import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen for emergency contacts and resources
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Emergency Contacts Section
                    _buildEmergencyContactsSection(context),
                    const SizedBox(height: 24),

                    // Emergency Resources Section
                    _buildEmergencyResourcesSection(context),
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
              'Emergency',
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

  /// Build Emergency Contacts section
  Widget _buildEmergencyContactsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F4F6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.phone,
                  color: Color(0xFFE53935),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2B3B4A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Doctor contact card
          _buildContactCard(
            name: 'Dr. Aduke Adeloye',
            phone: '+234 801 234 5678',
            onCall: () => _makePhoneCall('+2348012345678'),
            onTest: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test alert sent to Dr. Aduke'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Add Emergency Contact button
          _buildAddContactButton(context),
        ],
      ),
    );
  }

  /// Build contact card
  Widget _buildContactCard({
    required String name,
    required String phone,
    required VoidCallback onCall,
    required VoidCallback onTest,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2B3B4A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F97AA),
                  ),
                ),
              ],
            ),
          ),
          // Test Alert button
          GestureDetector(
            onTap: onTest,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    size: 16,
                    color: Color(0xFF2B3B4A),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Test Alert',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2B3B4A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build add contact button
  Widget _buildAddContactButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to add emergency contact screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add emergency contact feature coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Color(0xFF2B3B4A),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Add Emergency Contact',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2B3B4A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Emergency Resources section
  Widget _buildEmergencyResourcesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F4F6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber,
                  color: Color(0xFFE53935),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Emergency Resources',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2B3B4A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Warning Signs card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Warning Signs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE53935),
                  ),
                ),
                const SizedBox(height: 12),
                _buildWarningItem('Severe headache'),
                _buildWarningItem('Vision changes'),
                _buildWarningItem('Upper abdominal pain'),
                _buildWarningItem('Rapid weight gain'),
                _buildWarningItem('Decreased baby movement'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Call Emergency button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _makePhoneCall('199'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Call Emergency: 199',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Call Doctor button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _makePhoneCall('+2348012345678'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                  side: const BorderSide(
                    color: Color(0xFF2B3B4A),
                    width: 1.5,
                  ),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone,
                    color: Color(0xFF2B3B4A),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Call Dr. Aduke',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B3B4A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build warning item
  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F97AA),
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7F97AA),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Make phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
