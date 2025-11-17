import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/secure_storage.dart';
import '../utils/responsive_helper.dart';

/// Personal Info Screen
///
/// Allows users to edit their personal details including name,
/// age, weight, height, and pregnancy stage
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  static const Color _primaryBlue = Color(0xFF4A90E2);
  static const Color _headingText = Color(0xFF182033);
  static const Color _subtext = Color(0xFF5B6B7A);
  static const Color _inputBorder = Color(0xFFE6E9EE);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _selectedPregnancyStage = 'Pregnancy Stage';
  bool _isLoading = true;

  final List<String> _pregnancyStages = [
    'Pregnancy Stage',
    'First Trimester (1-12 weeks)',
    'Second Trimester (13-26 weeks)',
    'Third Trimester (27-40 weeks)',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = await SecureStorage.instance.getUserEmail();
      final userKey = email?.toLowerCase() ?? 'default';

      final name = prefs.getString('user_name_$userKey') ?? '';
      final age = prefs.getString('user_age_$userKey') ?? '';
      final weight = prefs.getString('user_weight_$userKey') ?? '';
      final height = prefs.getString('user_height_$userKey') ?? '';
      final pregnancyStage =
          prefs.getString('user_pregnancy_stage_$userKey') ?? '';

      setState(() {
        _nameController.text = name;
        _ageController.text = age;
        _weightController.text = weight.isNotEmpty ? '${weight}kg' : '';
        _heightController.text = height.isNotEmpty ? '${height}cm' : '';

        // Map full stage name to display option
        if (pregnancyStage.contains('First')) {
          _selectedPregnancyStage = 'First Trimester (1-12 weeks)';
        } else if (pregnancyStage.contains('Second')) {
          _selectedPregnancyStage = 'Second Trimester (13-26 weeks)';
        } else if (pregnancyStage.contains('Third')) {
          _selectedPregnancyStage = 'Third Trimester (27-40 weeks)';
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Personal Info',
          style: GoogleFonts.inter(
            fontSize: ResponsiveHelper.getTitleFontSize(context),
            fontWeight: FontWeight.w600,
            color: _headingText,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getHorizontalPadding(context),
                  vertical: ResponsiveHelper.getVerticalPadding(context),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        label: 'Name',
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        label: 'Age',
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        label: 'Weight',
                        controller: _weightController,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        label: 'Height',
                        controller: _heightController,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdownField(
                        label: 'Pregnancy Stage',
                      ),
                      const SizedBox(height: 40),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _subtext,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: _headingText,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _subtext,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedPregnancyStage,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryBlue, width: 2),
            ),
          ),
          style: GoogleFonts.inter(
            fontSize: 16,
            color: _headingText,
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: _pregnancyStages.map((stage) {
            return DropdownMenuItem<String>(
              value: stage,
              child: Text(stage),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPregnancyStage = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.getButtonHeight(context),
      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          'Save Changes',
          style: GoogleFonts.inter(
            fontSize: ResponsiveHelper.getHeadingFontSize(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final email = await SecureStorage.instance.getUserEmail();
        final userKey = email?.toLowerCase() ?? 'default';

        // Extract numeric values from weight and height
        final weightText = _weightController.text.replaceAll(RegExp(r'[^0-9.]'), '');
        final heightText = _heightController.text.replaceAll(RegExp(r'[^0-9.]'), '');

        // Save basic user details
        await prefs.setString('user_name_$userKey', _nameController.text.trim());
        await prefs.setString('user_age_$userKey', _ageController.text.trim());
        await prefs.setString('user_weight_$userKey', weightText);
        await prefs.setString('user_height_$userKey', heightText);
        await prefs.setString('user_pregnancy_stage_$userKey', _selectedPregnancyStage);

        // Update pregnancy weeks based on stage
        int pregnancyWeeks = 0;
        if (_selectedPregnancyStage.contains('First')) {
          pregnancyWeeks = 8;
        } else if (_selectedPregnancyStage.contains('Second')) {
          pregnancyWeeks = 20;
        } else if (_selectedPregnancyStage.contains('Third')) {
          pregnancyWeeks = 32;
        }
        await prefs.setInt('pregnancy_weeks_$userKey', pregnancyWeeks);

        // Update user name in secure storage
        await SecureStorage.instance.saveUserName(_nameController.text.trim());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Personal info saved successfully'),
              backgroundColor: Color(0xFF43A047),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving info: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }
}
