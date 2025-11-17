import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/ui_constants.dart';
import '../widgets/rounded_text_field.dart';
import '../providers/vitals_provider.dart';
import '../services/local_db.dart';

/// Add Vitals Screen
///
/// Fullscreen modal for logging vital sign readings including:
/// - Weight (with slider)
/// - Blood Pressure (systolic/diastolic)
/// - Heart Rate (with slider)
/// - Date and Time
///
/// Features:
/// - Form validation with inline errors
/// - 2-way binding between sliders and text fields
/// - Auto-alert generation on abnormal readings
/// - Accessibility support
/// - Keyboard dismissal on tap outside
class AddVitalsScreen extends StatefulWidget {
  final VitalRecord? initialValues;

  const AddVitalsScreen({
    super.key,
    this.initialValues,
  });

  @override
  State<AddVitalsScreen> createState() => _AddVitalsScreenState();
}

class _AddVitalsScreenState extends State<AddVitalsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  late final TextEditingController _weightController;
  late final TextEditingController _systolicController;
  late final TextEditingController _diastolicController;
  late final TextEditingController _heartRateController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;

  // Slider values
  double _weight = VitalLimits.weightDefault;
  double _heartRate = VitalLimits.heartRateDefault.toDouble();

  // Date and time
  DateTime _selectedDateTime = DateTime.now();

  // Loading state
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Load today's data and last weight after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodaysDataAndLastWeight();
    });

    // Initialize with provided values or defaults
    final initial = widget.initialValues;
    _weight = initial?.weightKg ?? VitalLimits.weightDefault;
    _heartRate = initial?.heartRate?.toDouble() ?? VitalLimits.heartRateDefault.toDouble();
    _selectedDateTime = initial?.timestamp ?? DateTime.now();

    // Initialize controllers
    _weightController = TextEditingController(
      text: _weight.round().toString(),
    );
    _systolicController = TextEditingController(
      text: initial?.systolic?.toString() ?? '',
    );
    _diastolicController = TextEditingController(
      text: initial?.diastolic?.toString() ?? '',
    );
    _heartRateController = TextEditingController(
      text: _heartRate.round().toString(),
    );
    _dateController = TextEditingController(
      text: DateFormat('MMM dd, yyyy').format(_selectedDateTime),
    );
    _timeController = TextEditingController(
      text: DateFormat('hh:mm a').format(_selectedDateTime),
    );

    // Add listeners for 2-way binding (prevent update loops)
    _weightController.addListener(_onWeightTextChanged);
    _heartRateController.addListener(_onHeartRateTextChanged);
  }

  /// Load today's record if it exists, and pre-fill with last weight
  Future<void> _loadTodaysDataAndLastWeight() async {
    if (!mounted) return;

    final provider = context.read<VitalsProvider>();

    // Check if there's a record for today
    final todaysRecord = await provider.getTodaysRecord();

    if (todaysRecord != null) {
      // Pre-fill with today's data (user is editing)
      debugPrint('[AddVitalsScreen] Loading today\'s record for editing');
      setState(() {
        _weight = todaysRecord.weightKg ?? _weight;
        _heartRate = todaysRecord.heartRate?.toDouble() ?? _heartRate;

        _weightController.text = _weight.round().toString();
        _systolicController.text = todaysRecord.systolic?.toString() ?? '';
        _diastolicController.text = todaysRecord.diastolic?.toString() ?? '';
        _heartRateController.text = _heartRate.round().toString();
      });

      // Show info message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Editing today\'s entry'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // No record for today, pre-fill weight with last recorded value
      debugPrint('[AddVitalsScreen] No record for today, loading last weight');
      final lastWeight = await provider.getLastRecordedWeight();

      if (lastWeight != null && mounted) {
        setState(() {
          _weight = lastWeight;
          _weightController.text = _weight.round().toString();
        });
        debugPrint('[AddVitalsScreen] Pre-filled weight with last value: $lastWeight kg');
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  /// Handle weight text field changes (update slider)
  void _onWeightTextChanged() {
    final value = double.tryParse(_weightController.text);
    if (value != null && value != _weight && value >= VitalLimits.weightMin && value <= VitalLimits.weightMax) {
      setState(() => _weight = value);
    }
  }

  /// Handle heart rate text field changes (update slider)
  void _onHeartRateTextChanged() {
    final value = double.tryParse(_heartRateController.text);
    if (value != null && value != _heartRate && value >= VitalLimits.heartRateMin && value <= VitalLimits.heartRateMax) {
      setState(() => _heartRate = value);
    }
  }

  /// Show date picker
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.headingText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
        _dateController.text = DateFormat('MMM dd, yyyy').format(_selectedDateTime);
      });
    }
  }

  /// Show time picker
  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.headingText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
        _timeController.text = DateFormat('hh:mm a').format(_selectedDateTime);
      });
    }
  }

  /// Save vital readings
  Future<void> _saveVitals() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in the form'),
          backgroundColor: AppColors.errorRed,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Parse values
      final systolic = int.tryParse(_systolicController.text);
      final diastolic = int.tryParse(_diastolicController.text);
      final heartRate = int.tryParse(_heartRateController.text);
      final weight = double.tryParse(_weightController.text);

      // Debug: Log parsed values
      debugPrint('[AddVitalsScreen] Parsed values:');
      debugPrint('  Weight: $weight kg');
      debugPrint('  BP: $systolic/$diastolic mmHg');
      debugPrint('  HR: $heartRate bpm');
      debugPrint('  DateTime: $_selectedDateTime');

      // Create vital record
      final record = VitalRecord(
        timestamp: _selectedDateTime,
        weightKg: weight,
        systolic: systolic,
        diastolic: diastolic,
        heartRate: heartRate,
      );

      debugPrint('[AddVitalsScreen] VitalRecord created: ${record.toString()}');

      // Save via provider (will update if today's record exists, or create new)
      final provider = context.read<VitalsProvider>();
      debugPrint('[AddVitalsScreen] Attempting to save/update via provider...');
      final success = await provider.saveOrUpdateTodaysRecord(record);
      debugPrint('[AddVitalsScreen] Save result: $success');

      if (!mounted) return;

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Vitals saved successfully!'),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Close screen and return record
        Navigator.pop(context, record);
      } else {
        throw Exception('Failed to save vitals');
      }
    } catch (e, stackTrace) {
      debugPrint('[AddVitalsScreen] Error saving vitals: $e');
      debugPrint('[AddVitalsScreen] Stack trace: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving vitals: ${e.toString()}'),
          backgroundColor: AppColors.errorRed,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: GestureDetector(
        // Dismiss keyboard on tap outside
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.horizontalPadding,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppDimensions.verticalSpacing),
                        _buildWeightSection(),
                        const SizedBox(height: AppDimensions.verticalSpacing),
                        _buildBloodPressureSection(),
                        const SizedBox(height: AppDimensions.verticalSpacing),
                        _buildHeartRateSection(),
                        const SizedBox(height: AppDimensions.verticalSpacing),
                        _buildDateTimeSection(),
                        const SizedBox(height: 32),
                        _buildSaveButton(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header with close button and title
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.horizontalPadding,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Close button (min 44x44 for accessibility)
          Semantics(
            button: true,
            label: 'Close add vitals screen',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: AppDimensions.minTouchTarget,
                  height: AppDimensions.minTouchTarget,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.close,
                    color: AppColors.headingText,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Title
          Expanded(
            child: Text(
              'Log Vitals',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.headingText,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Spacer to center title
          const SizedBox(width: AppDimensions.minTouchTarget + 8),
        ],
      ),
    );
  }

  /// Build weight section with slider
  Widget _buildWeightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 12),
        NumericTextField(
          controller: _weightController,
          labelText: 'Weight (kg)',
          hintText: 'Enter weight',
          semanticLabel: 'Weight in kilograms',
          minValue: VitalLimits.weightMin,
          maxValue: VitalLimits.weightMax,
          allowDecimals: true,
          unit: 'kg',
        ),
        const SizedBox(height: 12),
        // Weight slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: AppDimensions.sliderTrackHeight,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: AppDimensions.sliderThumbRadius,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: AppColors.activeBlue,
            inactiveTrackColor: AppColors.stroke,
            thumbColor: AppColors.activeBlue,
            overlayColor: AppColors.activeBlue.withOpacity(0.2),
          ),
          child: Slider(
            min: VitalLimits.weightMin,
            max: VitalLimits.weightMax,
            divisions: ((VitalLimits.weightMax - VitalLimits.weightMin) * 2).round(),
            value: _weight.clamp(VitalLimits.weightMin, VitalLimits.weightMax),
            label: '${_weight.toStringAsFixed(1)} kg',
            onChanged: (value) {
              setState(() {
                _weight = value;
                _weightController.text = value.toStringAsFixed(1);
              });
            },
          ),
        ),
        Text(
          '${_weight.toStringAsFixed(1)} kg',
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build blood pressure section (optional)
  Widget _buildBloodPressureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Blood Pressure',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(width: 8),
            Text(
              '(Optional)',
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF7F97AA),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: RoundedTextField(
                controller: _systolicController,
                labelText: 'Systolic',
                hintText: '120',
                semanticLabel: 'Systolic blood pressure',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null; // Optional field
                  }
                  final number = int.tryParse(value);
                  if (number == null) {
                    return 'Invalid number';
                  }
                  if (number < VitalLimits.systolicMin ||
                      number > VitalLimits.systolicMax) {
                    return 'Must be ${VitalLimits.systolicMin}-${VitalLimits.systolicMax}';
                  }
                  return null;
                },
                suffixIcon: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Center(
                    widthFactor: 1.0,
                    child: Text(
                      'mmHg',
                      style: TextStyle(color: Color(0xFF7F97AA), fontSize: 13),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RoundedTextField(
                controller: _diastolicController,
                labelText: 'Diastolic',
                hintText: '80',
                semanticLabel: 'Diastolic blood pressure',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null; // Optional field
                  }
                  final number = int.tryParse(value);
                  if (number == null) {
                    return 'Invalid number';
                  }
                  if (number < VitalLimits.diastolicMin ||
                      number > VitalLimits.diastolicMax) {
                    return 'Must be ${VitalLimits.diastolicMin}-${VitalLimits.diastolicMax}';
                  }
                  return null;
                },
                suffixIcon: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Center(
                    widthFactor: 1.0,
                    child: Text(
                      'mmHg',
                      style: TextStyle(color: Color(0xFF7F97AA), fontSize: 13),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build heart rate section with slider (optional)
  Widget _buildHeartRateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Heart Rate',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(width: 8),
            Text(
              '(Optional)',
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF7F97AA),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RoundedTextField(
          controller: _heartRateController,
          labelText: 'Heart Rate (bpm)',
          hintText: 'Enter heart rate',
          semanticLabel: 'Heart rate in beats per minute',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null; // Optional field
            }
            final number = int.tryParse(value);
            if (number == null) {
              return 'Invalid number';
            }
            if (number < VitalLimits.heartRateMin ||
                number > VitalLimits.heartRateMax) {
              return 'Must be ${VitalLimits.heartRateMin}-${VitalLimits.heartRateMax}';
            }
            return null;
          },
          suffixIcon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              widthFactor: 1.0,
              child: Text(
                'bpm',
                style: TextStyle(color: Color(0xFF7F97AA), fontSize: 13),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Heart rate slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: AppDimensions.sliderTrackHeight,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: AppDimensions.sliderThumbRadius,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: AppColors.activeBlue,
            inactiveTrackColor: AppColors.stroke,
            thumbColor: AppColors.activeBlue,
            overlayColor: AppColors.activeBlue.withOpacity(0.2),
          ),
          child: Slider(
            min: VitalLimits.heartRateMin.toDouble(),
            max: VitalLimits.heartRateMax.toDouble(),
            divisions: VitalLimits.heartRateMax - VitalLimits.heartRateMin,
            value: _heartRate.clamp(
              VitalLimits.heartRateMin.toDouble(),
              VitalLimits.heartRateMax.toDouble(),
            ),
            label: '${_heartRate.round()} bpm',
            onChanged: (value) {
              setState(() {
                _heartRate = value;
                _heartRateController.text = value.round().toString();
              });
            },
          ),
        ),
        Text(
          '${_heartRate.round()} bpm',
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build date and time section
  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date & Time',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: RoundedTextField(
                controller: _dateController,
                labelText: 'Date',
                hintText: 'Select date',
                semanticLabel: 'Date of measurement',
                readOnly: true,
                onTap: _selectDate,
                prefixIcon: const Icon(Icons.calendar_today, size: 20),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Date is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RoundedTextField(
                controller: _timeController,
                labelText: 'Time',
                hintText: 'Select time',
                semanticLabel: 'Time of measurement',
                readOnly: true,
                onTap: _selectTime,
                prefixIcon: const Icon(Icons.access_time, size: 20),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Time is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build save button
  Widget _buildSaveButton() {
    return Semantics(
      button: true,
      label: 'Save vital signs',
      child: Container(
        width: double.infinity,
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.activeBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveVitals,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            ),
            disabledBackgroundColor: AppColors.stroke,
            disabledForegroundColor: AppColors.subtleText,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Save Vitals',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}
