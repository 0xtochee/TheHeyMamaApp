import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// User Details Screen - First step after sign up
///
/// Collects basic user information:
/// - Name
/// - Age
/// - Weight (kg)
/// - Height (feet)
/// - Pregnancy Stage
class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String? _selectedPregnancyStage;

  final List<String> _pregnancyStages = [
    'First Trimester (1-12 weeks)',
    'Second Trimester (13-26 weeks)',
    'Third Trimester (27-40 weeks)',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPregnancyStage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your pregnancy stage'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Navigate to medical history screen
      Navigator.pushNamed(
        context,
        '/medical-history',
        arguments: {
          'name': _nameController.text.trim(),
          'age': _ageController.text.trim(),
          'weight': _weightController.text.trim(),
          'height': _heightController.text.trim(),
          'pregnancyStage': _selectedPregnancyStage,
        },
      );
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
            _buildProgressBar(0.25),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'Let us know about you',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF182033),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fill in your details.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF5B6B7A),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Name field
                      _buildTextField(
                        controller: _nameController,
                        label: 'Name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Age field
                      _buildTextField(
                        controller: _ageController,
                        label: 'Age',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your age';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age < 15 || age > 60) {
                            return 'Please enter a valid age (15-60)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Weight field
                      _buildTextField(
                        controller: _weightController,
                        label: 'Weight in kg',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your weight';
                          }
                          final weight = double.tryParse(value);
                          if (weight == null || weight < 30 || weight > 200) {
                            return 'Please enter a valid weight';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Height field
                      _buildTextField(
                        controller: _heightController,
                        label: 'Height in feet',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your height';
                          }
                          final height = double.tryParse(value);
                          if (height == null || height < 3 || height > 8) {
                            return 'Please enter a valid height';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Pregnancy Stage dropdown
                      _buildDropdown(),
                    ],
                  ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(
        fontSize: 16,
        color: const Color(0xFF182033),
      ),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          color: const Color(0xFFA0A7B3),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE6E9EE),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE6E9EE),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF0D79FF),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE6E9EE),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: DropdownButtonFormField<String>(
        value: _selectedPregnancyStage,
        hint: Text(
          'Pregnancy Stage',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFFA0A7B3),
          ),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF182033),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: GoogleFonts.inter(
          fontSize: 16,
          color: const Color(0xFF182033),
        ),
        dropdownColor: Colors.white,
        items: _pregnancyStages.map((String stage) {
          return DropdownMenuItem<String>(
            value: stage,
            child: Text(stage),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedPregnancyStage = newValue;
          });
        },
      ),
    );
  }
}
