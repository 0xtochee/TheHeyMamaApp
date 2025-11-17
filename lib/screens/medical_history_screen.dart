import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/local_db.dart';
import '../services/secure_storage.dart';

/// Medical History Screen - Second step after sign up
///
/// Allows users to select their medical history:
/// - Hypertension
/// - Diabetes
/// - Pre-eclampsia
/// - Prev C-section
/// - Hepatitis
/// - Allergies
class MedicalHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> userDetails;

  const MedicalHistoryScreen({
    super.key,
    required this.userDetails,
  });

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final Set<String> _selectedConditions = {};

  final List<Map<String, String>> _medicalConditions = [
    {'id': 'hypertension', 'label': 'Hypertension'},
    {'id': 'diabetes', 'label': 'Diabetes'},
    {'id': 'preeclampsia', 'label': 'Pre-eclampsia'},
    {'id': 'prev_csection', 'label': 'Prev C-section'},
    {'id': 'hepatitis', 'label': 'Hepatitis'},
    {'id': 'allergies', 'label': 'Allergies'},
  ];

  void _toggleCondition(String id) {
    setState(() {
      if (_selectedConditions.contains(id)) {
        _selectedConditions.remove(id);
      } else {
        _selectedConditions.add(id);
      }
    });
  }

  Future<void> _handleContinue() async {
    // Save user profile data
    await _saveUserProfile();

    // Navigate to dashboard
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (route) => false,
      );
    }
  }

  Future<void> _saveUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get current user email for user-specific keys
      final email = await SecureStorage.instance.getUserEmail();
      final userKey = email?.toLowerCase() ?? 'default';

      // Save basic user details with user-specific keys
      await prefs.setString(
          'user_name_$userKey', widget.userDetails['name'] ?? '');
      await prefs.setString(
          'user_age_$userKey', widget.userDetails['age'] ?? '');
      await prefs.setString(
          'user_weight_$userKey', widget.userDetails['weight'] ?? '');
      await prefs.setString(
          'user_height_$userKey', widget.userDetails['height'] ?? '');
      await prefs.setString(
        'user_pregnancy_stage_$userKey',
        widget.userDetails['pregnancyStage'] ?? '',
      );

      // Calculate pregnancy weeks from stage
      int pregnancyWeeks = 0;
      final stage = widget.userDetails['pregnancyStage'] as String?;
      if (stage != null) {
        if (stage.contains('First')) {
          pregnancyWeeks = 8; // Mid-first trimester
        } else if (stage.contains('Second')) {
          pregnancyWeeks = 20; // Mid-second trimester
        } else if (stage.contains('Third')) {
          pregnancyWeeks = 32; // Mid-third trimester
        }
      }
      await prefs.setInt('pregnancy_weeks_$userKey', pregnancyWeeks);

      // Save medical history with user-specific key
      await prefs.setStringList(
        'medical_conditions_$userKey',
        _selectedConditions.toList(),
      );

      // Save user name to secure storage for current session
      await SecureStorage.instance.saveUserName(
        widget.userDetails['name'] ?? '',
      );

      // Create initial weight record in database
      await _createInitialWeightRecord();

      // Mark profile as complete for this user
      await prefs.setBool('profile_complete_$userKey', true);
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Create initial weight record in database
  Future<void> _createInitialWeightRecord() async {
    try {
      final weightStr = widget.userDetails['weight'] as String?;
      if (weightStr != null && weightStr.isNotEmpty) {
        final weight = double.tryParse(weightStr);
        if (weight != null) {
          final db = LocalDatabase();
          final initialRecord = VitalRecord(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            timestamp: DateTime.now(),
            weightKg: weight,
          );
          await db.insertVitalRecord(initialRecord);
        }
      }
    } catch (e) {
      // Silently fail - not critical
      debugPrint('Failed to create initial weight record: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            _buildProgressBar(0.5),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Medical history',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF182033),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your experience.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF5B6B7A),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Medical conditions grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: _medicalConditions.length,
                      itemBuilder: (context, index) {
                        final condition = _medicalConditions[index];
                        final isSelected = _selectedConditions.contains(
                          condition['id'],
                        );
                        return _buildConditionCard(
                          id: condition['id']!,
                          label: condition['label']!,
                          isSelected: isSelected,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D79FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index < (progress * 4).ceil();
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF0D79FF)
                    : const Color(0xFFE6E9EE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildConditionCard({
    required String id,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _toggleCondition(id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D79FF).withOpacity(0.1)
              : const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF0D79FF) : const Color(0xFFE6E9EE),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF0D79FF) : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0D79FF)
                      : const Color(0xFFCCD5DE),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF0D79FF)
                      : const Color(0xFF5B6B7A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
