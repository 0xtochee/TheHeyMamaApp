import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vital_record.dart';
import '../services/local_db.dart';
import '../services/notification_service.dart';
import '../services/secure_storage.dart';

/// Model class representing a vital reading
class VitalReading {
  final DateTime timestamp;
  final String type;
  final String value;

  VitalReading({
    required this.timestamp,
    required this.type,
    required this.value,
  });

  factory VitalReading.fromMap(Map<String, dynamic> map) {
    return VitalReading(
      timestamp: DateTime.parse(map['timestamp'] as String),
      type: map['type'] as String,
      value: map['value'] as String,
    );
  }
}

/// Model class for health alerts
class HealthAlert {
  final String title;
  final String headline;
  final String message;
  final String? imagePath;
  final bool hasAction;

  HealthAlert({
    required this.title,
    required this.headline,
    required this.message,
    this.imagePath,
    this.hasAction = false,
  });
}

/// Provider class for managing vital readings, alerts, and thresholds
///
/// This provider handles:
/// - Loading and storing vital readings
/// - Managing blood pressure and heart rate thresholds
/// - Generating alerts for abnormal readings
/// - Coordinating with database and notification services
class VitalsProvider with ChangeNotifier {
  final LocalDatabase _db = LocalDatabase();
  final NotificationService _notificationService = NotificationService();

  // User information
  String _userName = 'Mary';
  int _pregnancyWeeks = 24;

  // Latest vital readings
  VitalReading? _latestBloodPressure;
  VitalReading? _latestHeartRate;

  // Health alerts
  final List<HealthAlert> _alerts = [];

  // Alert thresholds
  int _bpSystolicThreshold = 140;
  int _bpDiastolicThreshold = 90;
  int _heartRateMinThreshold = 60;
  int _heartRateMaxThreshold = 100;

  // Loading state
  bool _isLoading = false;

  // Chart data state
  MetricType _selectedMetric = MetricType.weight;
  DateRange _selectedDateRange = DateRange.last7Days;
  List<TimeSeriesPoint> _chartData = [];

  // Getters
  String get userName => _userName;
  int get pregnancyWeeks => _pregnancyWeeks;
  VitalReading? get latestBloodPressure => _latestBloodPressure;
  VitalReading? get latestHeartRate => _latestHeartRate;
  List<HealthAlert> get alerts => List.unmodifiable(_alerts);
  bool get isLoading => _isLoading;
  int get bpSystolicThreshold => _bpSystolicThreshold;
  int get bpDiastolicThreshold => _bpDiastolicThreshold;
  int get heartRateMinThreshold => _heartRateMinThreshold;
  int get heartRateMaxThreshold => _heartRateMaxThreshold;
  MetricType get selectedMetric => _selectedMetric;
  DateRange get selectedDateRange => _selectedDateRange;
  List<TimeSeriesPoint> get chartData => List.unmodifiable(_chartData);

  /// Initialize the provider and load initial data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load user profile data
      await _loadUserProfile();

      // Initialize notification service
      await _notificationService.initialize();
      await _notificationService.requestPermissions();

      // Load latest vitals from database
      await loadLatestVitals();

      // Check for abnormal readings and generate alerts
      _checkForAbnormalReadings();
    } catch (e) {
      debugPrint('Failed to initialize VitalsProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user profile data from SecureStorage and SharedPreferences
  Future<void> _loadUserProfile() async {
    try {
      // Get user name from SecureStorage (current logged-in user)
      final userName = await SecureStorage.instance.getUserName();
      if (userName != null && userName.isNotEmpty) {
        _userName = userName;
      } else {
        _userName = 'User';
      }

      // Get pregnancy weeks from SharedPreferences (per-user data)
      final prefs = await SharedPreferences.getInstance();
      final email = await SecureStorage.instance.getUserEmail();
      if (email != null) {
        final key = 'pregnancy_weeks_${email.toLowerCase()}';
        _pregnancyWeeks = prefs.getInt(key) ?? 24;
      } else {
        _pregnancyWeeks = 24;
      }
    } catch (e) {
      debugPrint('Failed to load user profile: $e');
      _userName = 'User';
      _pregnancyWeeks = 24;
    }
  }

  /// Load the latest vital readings from the database
  Future<void> loadLatestVitals() async {
    try {
      // Try to load from new VitalRecord table first (works on web with fallback)
      final latestRecord = await _db.getLatestVitalRecord();

      if (latestRecord != null) {
        debugPrint(
            '[VitalsProvider] Loaded latest VitalRecord: ${latestRecord.toString()}');

        // Update BP if available
        if (latestRecord.systolic != null && latestRecord.diastolic != null) {
          _latestBloodPressure = VitalReading(
            timestamp: latestRecord.timestamp,
            type: 'blood_pressure',
            value: '${latestRecord.systolic}/${latestRecord.diastolic}',
          );
          debugPrint(
              '[VitalsProvider] Set latest BP from VitalRecord: ${_latestBloodPressure!.value}');
        }

        // Update HR if available
        if (latestRecord.heartRate != null) {
          _latestHeartRate = VitalReading(
            timestamp: latestRecord.timestamp,
            type: 'heart_rate',
            value: latestRecord.heartRate.toString(),
          );
          debugPrint(
              '[VitalsProvider] Set latest HR from VitalRecord: ${_latestHeartRate!.value}');
        }
      } else {
        // Fallback to legacy method if VitalRecord not available
        debugPrint(
            '[VitalsProvider] No VitalRecord found, trying legacy method...');

        // Load latest blood pressure
        final bpData = await _db.getLatestVital('blood_pressure');
        if (bpData != null) {
          _latestBloodPressure = VitalReading.fromMap(bpData);
        }
        // Don't set placeholder - leave as null if no data

        // Load latest heart rate
        final hrData = await _db.getLatestVital('heart_rate');
        if (hrData != null) {
          _latestHeartRate = VitalReading.fromMap(hrData);
        }
        // Don't set placeholder - leave as null if no data
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load latest vitals: $e');
      // On error, leave values as null (will show '--' placeholder in UI)
      notifyListeners();
    }
  }

  /// Add a new blood pressure reading
  ///
  /// Parameters:
  /// - [systolic]: Systolic pressure value
  /// - [diastolic]: Diastolic pressure value
  /// - [timestamp]: When the reading was taken (defaults to now)
  Future<void> addBloodPressureReading({
    required int systolic,
    required int diastolic,
    DateTime? timestamp,
  }) async {
    try {
      final readingTime = timestamp ?? DateTime.now();
      final value = '$systolic/$diastolic';

      await _db.insertVital(
        timestamp: readingTime,
        type: 'blood_pressure',
        value: value,
      );

      _latestBloodPressure = VitalReading(
        timestamp: readingTime,
        type: 'blood_pressure',
        value: value,
      );

      // Check if this reading is abnormal
      if (systolic >= _bpSystolicThreshold ||
          diastolic >= _bpDiastolicThreshold) {
        _generateBloodPressureAlert(systolic, diastolic);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to add blood pressure reading: $e');
      throw Exception('Failed to save blood pressure reading');
    }
  }

  /// Add a new heart rate reading
  ///
  /// Parameters:
  /// - [bpm]: Beats per minute
  /// - [timestamp]: When the reading was taken (defaults to now)
  Future<void> addHeartRateReading({
    required int bpm,
    DateTime? timestamp,
  }) async {
    try {
      final readingTime = timestamp ?? DateTime.now();
      final value = bpm.toString();

      await _db.insertVital(
        timestamp: readingTime,
        type: 'heart_rate',
        value: value,
      );

      _latestHeartRate = VitalReading(
        timestamp: readingTime,
        type: 'heart_rate',
        value: value,
      );

      // Check if this reading is abnormal
      if (bpm < _heartRateMinThreshold || bpm > _heartRateMaxThreshold) {
        _generateHeartRateAlert(bpm);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to add heart rate reading: $e');
      throw Exception('Failed to save heart rate reading');
    }
  }

  /// Set blood pressure alert thresholds
  ///
  /// Parameters:
  /// - [systolic]: Systolic threshold (default: 140)
  /// - [diastolic]: Diastolic threshold (default: 90)
  void setBpThreshold({int? systolic, int? diastolic}) {
    if (systolic != null) _bpSystolicThreshold = systolic;
    if (diastolic != null) _bpDiastolicThreshold = diastolic;
    notifyListeners();
  }

  /// Set heart rate alert thresholds
  ///
  /// Parameters:
  /// - [min]: Minimum heart rate threshold (default: 60)
  /// - [max]: Maximum heart rate threshold (default: 100)
  void setHeartRateThreshold({int? min, int? max}) {
    if (min != null) _heartRateMinThreshold = min;
    if (max != null) _heartRateMaxThreshold = max;
    notifyListeners();
  }

  /// Update user information
  Future<void> updateUserInfo({String? name, int? weeks}) async {
    if (name != null) {
      _userName = name;
      // Save to SecureStorage for current session
      await SecureStorage.instance.saveUserName(name);
    }

    if (weeks != null) {
      _pregnancyWeeks = weeks;
      // Save to SharedPreferences with user-specific key
      try {
        final email = await SecureStorage.instance.getUserEmail();
        if (email != null) {
          final prefs = await SharedPreferences.getInstance();
          final key = 'pregnancy_weeks_${email.toLowerCase()}';
          await prefs.setInt(key, weeks);
        }
      } catch (e) {
        debugPrint('Failed to save pregnancy weeks: $e');
      }
    }

    notifyListeners();
  }

  /// Check for abnormal readings and generate alerts
  void _checkForAbnormalReadings() {
    _alerts.clear();

    // Check blood pressure
    if (_latestBloodPressure != null) {
      final parts = _latestBloodPressure!.value.split('/');
      if (parts.length == 2) {
        final systolic = int.tryParse(parts[0]);
        final diastolic = int.tryParse(parts[1]);

        if (systolic != null &&
            diastolic != null &&
            (systolic >= _bpSystolicThreshold ||
                diastolic >= _bpDiastolicThreshold)) {
          _generateBloodPressureAlert(systolic, diastolic, notify: false);
        }
      }
    }

    // Check heart rate
    if (_latestHeartRate != null) {
      final bpm = int.tryParse(_latestHeartRate!.value);
      if (bpm != null &&
          (bpm < _heartRateMinThreshold || bpm > _heartRateMaxThreshold)) {
        _generateHeartRateAlert(bpm, notify: false);
      }
    }
  }

  /// Generate a blood pressure alert
  void _generateBloodPressureAlert(
    int systolic,
    int diastolic, {
    bool notify = true,
  }) {
    final alert = HealthAlert(
      title: 'Abnormal Reading',
      headline: 'High Blood Pressure',
      message:
          'Your blood pressure reading of $systolic/$diastolic mmHg is higher than normal. Consider contacting your healthcare provider.',
      imagePath: 'assets/images/alert.png',
      hasAction: true,
    );

    _alerts.add(alert);

    if (notify) {
      _notificationService.showUrgentAlert(
        title: 'High Blood Pressure',
        body:
            'Your reading of $systolic/$diastolic mmHg is above threshold. Please review.',
      );
    }
  }

  /// Generate a heart rate alert
  void _generateHeartRateAlert(int bpm, {bool notify = true}) {
    final isHigh = bpm > _heartRateMaxThreshold;
    final alert = HealthAlert(
      title: 'Abnormal Reading',
      headline: isHigh ? 'High Heart Rate' : 'Low Heart Rate',
      message:
          'Your heart rate of $bpm bpm is ${isHigh ? "higher" : "lower"} than normal. Consider monitoring it closely.',
      imagePath: 'assets/images/heart_rate.jpg',
      hasAction: true,
    );

    _alerts.add(alert);

    if (notify) {
      _notificationService.showUrgentAlert(
        title: isHigh ? 'High Heart Rate' : 'Low Heart Rate',
        body: 'Your reading of $bpm bpm is outside normal range.',
      );
    }
  }

  /// Clear all alerts
  void clearAlerts() {
    _alerts.clear();
    notifyListeners();
  }

  /// Remove a specific alert
  void removeAlert(int index) {
    if (index >= 0 && index < _alerts.length) {
      _alerts.removeAt(index);
      notifyListeners();
    }
  }

  /// Get vitals history for a specific type
  Future<List<VitalReading>> getVitalsHistory(String type) async {
    try {
      final data = await _db.getVitalsByType(type);
      return data.map((map) => VitalReading.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Failed to get vitals history: $e');
      return [];
    }
  }

  /// Add a complete vital record (new comprehensive method)
  ///
  /// This method handles saving a complete vital record with multiple measurements
  /// and automatically generates alerts if any values are outside normal ranges.
  ///
  /// Parameters:
  /// - [record]: VitalRecord containing all vital measurements
  ///
  /// Returns: true if saved successfully, false otherwise
  ///
  /// Throws: Exception if critical error occurs during save
  Future<bool> addVitalRecord(VitalRecord record) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Save to database (with fallback to SharedPreferences)
      final recordId = await _db.insertVitalRecord(record);
      debugPrint('Saved vital record with ID: $recordId');

      // Update latest readings for legacy compatibility
      if (record.systolic != null && record.diastolic != null) {
        _latestBloodPressure = VitalReading(
          timestamp: record.timestamp,
          type: 'blood_pressure',
          value: '${record.systolic}/${record.diastolic}',
        );
        debugPrint(
            '[VitalsProvider] Updated latest BP: ${_latestBloodPressure!.value}');

        // Also save to legacy table for backward compatibility
        await _db.insertVital(
          timestamp: record.timestamp,
          type: 'blood_pressure',
          value: '${record.systolic}/${record.diastolic}',
        );
      }

      if (record.heartRate != null) {
        _latestHeartRate = VitalReading(
          timestamp: record.timestamp,
          type: 'heart_rate',
          value: record.heartRate.toString(),
        );
        debugPrint(
            '[VitalsProvider] Updated latest HR: ${_latestHeartRate!.value}');

        // Also save to legacy table for backward compatibility
        await _db.insertVital(
          timestamp: record.timestamp,
          type: 'heart_rate',
          value: record.heartRate.toString(),
        );
      }

      // Check for abnormal values and generate alerts
      _checkVitalRecordForAlerts(record);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to add vital record: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Check a vital record for abnormal values and generate appropriate alerts
  void _checkVitalRecordForAlerts(VitalRecord record) {
    // Remove blood pressure alerts if BP is now normal
    if (record.systolic != null && record.diastolic != null) {
      // Remove any existing BP alerts
      _alerts.removeWhere((alert) => alert.headline.contains('Blood Pressure'));

      // Add new alert only if BP is abnormal
      if (record.systolic! >= _bpSystolicThreshold ||
          record.diastolic! >= _bpDiastolicThreshold) {
        _generateBloodPressureAlert(record.systolic!, record.diastolic!);
      } else if (record.systolic! <= 90 || record.diastolic! <= 60) {
        // Also check for low blood pressure
        _generateLowBloodPressureAlert(record.systolic!, record.diastolic!);
      }
      // If BP is normal, no new alert is added
    }

    // Remove heart rate alerts if HR is now normal
    if (record.heartRate != null) {
      // Remove any existing HR alerts
      _alerts.removeWhere((alert) => alert.headline.contains('Heart Rate'));

      // Add new alert only if HR is abnormal
      if (record.heartRate! < _heartRateMinThreshold ||
          record.heartRate! > _heartRateMaxThreshold) {
        _generateHeartRateAlert(record.heartRate!);
      }
      // If HR is normal, no new alert is added
    }

    // Weight change alerts could be added here in future
    // if tracking weight changes over time
  }

  /// Generate a low blood pressure alert
  void _generateLowBloodPressureAlert(
    int systolic,
    int diastolic, {
    bool notify = true,
  }) {
    final alert = HealthAlert(
      title: 'Abnormal Reading',
      headline: 'Low Blood Pressure',
      message:
          'Your blood pressure reading of $systolic/$diastolic mmHg is lower than normal. Please rest and monitor. Contact your healthcare provider if you feel dizzy or unwell.',
      imagePath: 'assets/images/alert.png',
      hasAction: true,
    );

    _alerts.add(alert);

    if (notify) {
      _notificationService.showUrgentAlert(
        title: 'Low Blood Pressure',
        body:
            'Your reading of $systolic/$diastolic mmHg is below normal range.',
      );
    }
  }

  /// Get all vital records (comprehensive history)
  Future<List<VitalRecord>> getAllVitalRecords({int limit = 100}) async {
    try {
      return await _db.getAllVitalRecords(limit: limit);
    } catch (e) {
      debugPrint('Failed to get all vital records: $e');
      return [];
    }
  }

  /// Get the most recent comprehensive vital record
  Future<VitalRecord?> getLatestVitalRecord() async {
    try {
      return await _db.getLatestVitalRecord();
    } catch (e) {
      debugPrint('Failed to get latest vital record: $e');
      return null;
    }
  }

  /// Change the selected metric and reload chart data
  Future<void> changeMetric(MetricType metric) async {
    if (_selectedMetric == metric) return;

    _selectedMetric = metric;
    // Clear existing chart data immediately to prevent stale data display
    _chartData = [];
    notifyListeners();

    await _loadChartData();
  }

  /// Change the selected date range and reload chart data
  Future<void> changeDateRange(DateRange range) async {
    if (_selectedDateRange == range) return;

    _selectedDateRange = range;
    notifyListeners();

    await _loadChartData();
  }

  /// Load chart data for the selected metric and date range
  Future<void> _loadChartData() async {
    try {
      final endDate = DateTime.now();
      final startDate =
          endDate.subtract(Duration(days: _selectedDateRange.days));

      debugPrint(
          '[VitalsProvider] Loading chart data for ${_selectedMetric.displayName}');
      debugPrint('[VitalsProvider] Date range: $startDate to $endDate');

      final records = await _db.getVitalRecordsInRange(startDate, endDate);
      debugPrint('[VitalsProvider] Found ${records.length} total records');

      _chartData = _extractMetricData(records, _selectedMetric);
      debugPrint(
          '[VitalsProvider] Extracted ${_chartData.length} data points for ${_selectedMetric.displayName}');

      if (_chartData.isEmpty) {
        debugPrint(
            '[VitalsProvider] No data available for ${_selectedMetric.displayName} - will display "--"');
      }

      // Sort by time ascending
      _chartData.sort((a, b) => a.time.compareTo(b.time));

      if (_chartData.isNotEmpty) {
        debugPrint('[VitalsProvider] First point: ${_chartData.first}');
        debugPrint('[VitalsProvider] Last point: ${_chartData.last}');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load chart data: $e');
      _chartData = [];
      notifyListeners();
    }
  }

  /// Extract metric-specific data from vital records
  List<TimeSeriesPoint> _extractMetricData(
    List<VitalRecord> records,
    MetricType metric,
  ) {
    final List<TimeSeriesPoint> points = [];

    for (final record in records) {
      double? value;

      switch (metric) {
        case MetricType.weight:
          value = record.weightKg;
          if (value != null) {
            debugPrint(
                '[VitalsProvider] Weight extraction: $value kg from ${record.timestamp}');
          }
          break;
        case MetricType.bloodPressure:
          // Use systolic as the primary BP value for charting
          value = record.systolic?.toDouble();
          if (value != null) {
            debugPrint(
                '[VitalsProvider] BP extraction: ${record.systolic}/${record.diastolic} from ${record.timestamp}');
          }
          break;
        case MetricType.heartRate:
          value = record.heartRate?.toDouble();
          if (value != null) {
            debugPrint(
                '[VitalsProvider] HR extraction: $value bpm from ${record.timestamp}');
          }
          break;
        case MetricType.sugar:
          value = record.bloodSugar?.toDouble();
          if (value != null) {
            debugPrint(
                '[VitalsProvider] Blood Sugar extraction: $value mg/dL from ${record.timestamp}');
          }
          break;
      }

      if (value != null) {
        points.add(TimeSeriesPoint(record.timestamp, value));
      }
    }

    return points;
  }

  /// Get the current value for the selected metric
  double? getCurrentValue() {
    if (_chartData.isEmpty) {
      debugPrint(
          '[VitalsProvider] No chart data for ${_selectedMetric.displayName} - returning null');
      return null;
    }
    final value = _chartData.last.value;
    debugPrint(
        '[VitalsProvider] Current value for ${_selectedMetric.displayName}: $value');
    return value;
  }

  /// Get the trend percentage for the selected metric over the selected range
  /// Returns null if not enough data, otherwise returns the percentage change
  double? getTrendPercentage() {
    if (_chartData.length < 2) return null;

    final firstValue = _chartData.first.value;
    final lastValue = _chartData.last.value;

    if (firstValue == 0) return null;

    return ((lastValue - firstValue) / firstValue) * 100;
  }

  /// Initialize chart data (called after main initialization)
  Future<void> initializeChartData() async {
    await _loadChartData();
  }

  /// Get today's vital record if it exists
  Future<VitalRecord?> getTodaysRecord() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final records = await _db.getVitalRecordsInRange(startOfDay, endOfDay);

      if (records.isNotEmpty) {
        debugPrint('[VitalsProvider] Found today\'s record: ${records.first}');
        return records.first;
      }

      debugPrint('[VitalsProvider] No record found for today');
      return null;
    } catch (e) {
      debugPrint('[VitalsProvider] Error getting today\'s record: $e');
      return null;
    }
  }

  /// Get the last recorded weight (for pre-filling the form)
  Future<double?> getLastRecordedWeight() async {
    try {
      final latestRecord = await _db.getLatestVitalRecord();
      if (latestRecord?.weightKg != null) {
        debugPrint(
            '[VitalsProvider] Last recorded weight: ${latestRecord!.weightKg} kg');
        return latestRecord.weightKg;
      }
      debugPrint('[VitalsProvider] No previous weight found');
      return null;
    } catch (e) {
      debugPrint('[VitalsProvider] Error getting last weight: $e');
      return null;
    }
  }

  /// Update or create today's vital record
  /// If a record exists for today, update it. Otherwise, create a new one.
  Future<bool> saveOrUpdateTodaysRecord(VitalRecord record) async {
    try {
      _isLoading = true;
      notifyListeners();

      final todaysRecord = await getTodaysRecord();

      if (todaysRecord != null) {
        // Update existing record for today
        debugPrint(
            '[VitalsProvider] Updating today\'s record (ID: ${todaysRecord.id})');

        // Delete old record and insert updated one
        // (SQLite doesn't have a simple update for our use case)
        final updatedRecord = VitalRecord(
          id: todaysRecord.id,
          timestamp: record.timestamp,
          weightKg: record.weightKg,
          systolic: record.systolic,
          diastolic: record.diastolic,
          heartRate: record.heartRate,
          bloodSugar: record.bloodSugar,
        );

        final recordId = await _db.insertVitalRecord(updatedRecord);
        debugPrint('[VitalsProvider] Updated record with ID: $recordId');
      } else {
        // Create new record
        debugPrint('[VitalsProvider] Creating new record for today');
        final recordId = await _db.insertVitalRecord(record);
        debugPrint('[VitalsProvider] Created new record with ID: $recordId');
      }

      // Update latest readings for legacy compatibility
      if (record.systolic != null && record.diastolic != null) {
        _latestBloodPressure = VitalReading(
          timestamp: record.timestamp,
          type: 'blood_pressure',
          value: '${record.systolic}/${record.diastolic}',
        );
      }

      if (record.heartRate != null) {
        _latestHeartRate = VitalReading(
          timestamp: record.timestamp,
          type: 'heart_rate',
          value: record.heartRate.toString(),
        );
      }

      // Check for abnormal values and generate alerts
      _checkVitalRecordForAlerts(record);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[VitalsProvider] Failed to save/update record: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
