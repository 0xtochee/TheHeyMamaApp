import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/reminder.dart';
import '../models/appointment.dart';
import 'secure_storage.dart';

/// Model class for vital sign readings
///
/// Represents a complete vital sign record with all measurements.
/// Used for persistence and data transfer between layers.
class VitalRecord {
  final String? id;
  final DateTime timestamp;
  final double? weightKg;
  final int? systolic;
  final int? diastolic;
  final int? heartRate;
  final int? bloodSugar;

  VitalRecord({
    this.id,
    required this.timestamp,
    this.weightKg,
    this.systolic,
    this.diastolic,
    this.heartRate,
    this.bloodSugar,
  });

  /// Create VitalRecord from database map
  factory VitalRecord.fromMap(Map<String, dynamic> map) {
    return VitalRecord(
      id: map['id']?.toString(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      weightKg: map['weight_kg'] != null
          ? (map['weight_kg'] as num).toDouble()
          : null,
      systolic: map['systolic'] as int?,
      diastolic: map['diastolic'] as int?,
      heartRate: map['heart_rate'] as int?,
      bloodSugar: map['blood_sugar'] as int?,
    );
  }

  /// Convert VitalRecord to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'timestamp': timestamp.toIso8601String(),
      if (weightKg != null) 'weight_kg': weightKg,
      if (systolic != null) 'systolic': systolic,
      if (diastolic != null) 'diastolic': diastolic,
      if (heartRate != null) 'heart_rate': heartRate,
      if (bloodSugar != null) 'blood_sugar': bloodSugar,
    };
  }

  /// Convert to JSON for SharedPreferences fallback
  Map<String, dynamic> toJson() => toMap();

  /// Create from JSON
  factory VitalRecord.fromJson(Map<String, dynamic> json) =>
      VitalRecord.fromMap(json);

  @override
  String toString() {
    return 'VitalRecord(id: $id, timestamp: $timestamp, weight: $weightKg, '
        'BP: $systolic/$diastolic, HR: $heartRate, BS: $bloodSugar)';
  }
}

/// Service class for managing local SQLite database operations for vitals data
///
/// This service handles:
/// - Database initialization and migrations
/// - CRUD operations for vital readings
/// - Query methods for fetching recent vitals
/// - Fallback to SharedPreferences when SQLite fails
class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  static Database? _database;
  static SharedPreferences? _prefs;
  static const String _prefsKey = 'vitals_fallback';

  factory LocalDatabase() => _instance;

  LocalDatabase._internal();

  /// Get database instance, initializing if needed
  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      // If database initialization fails (e.g., on web), throw error
      // This will trigger fallback to SharedPreferences
      debugPrint('Database getter failed: $e');
      rethrow;
    }
  }

  /// Get SharedPreferences instance for fallback storage
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Initialize the SQLite database
  /// Creates the vitals table if it doesn't exist
  ///
  /// Note: This will fail on web platform (expected behavior)
  /// The app will automatically use SharedPreferences fallback
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'pregnancy_vitals.db');

    return await openDatabase(
      path,
      version: 6, // Increment version to add user_email column
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Get current logged-in user's email
  Future<String> _getCurrentUserEmail() async {
    // Try to get from secure storage
    try {
      final email = await SecureStorage.instance.getUserEmail();
      if (email != null && email.isNotEmpty) return email.toLowerCase();
    } catch (e) {
      debugPrint('Error getting user email from secure storage: $e');
    }

    // Fallback to a default user if no user is logged in (shouldn't happen)
    return 'default_user@app.com';
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Create new comprehensive vitals table with user_email
    await db.execute('''
      CREATE TABLE vital_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        weight_kg REAL,
        systolic INTEGER,
        diastolic INTEGER,
        heart_rate INTEGER,
        blood_sugar INTEGER
      )
    ''');

    // Create index for faster user-specific queries
    await db.execute('''
      CREATE INDEX idx_vital_records_user ON vital_records(user_email)
    ''');

    // Keep legacy table for backward compatibility
    await db.execute('''
      CREATE TABLE vitals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_vitals_user ON vitals(user_email)
    ''');

    // Create symptom entries table with user_email
    await db.execute('''
      CREATE TABLE symptom_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        symptoms TEXT NOT NULL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_symptom_entries_user ON symptom_entries(user_email)
    ''');

    // Create reminders table with user_email
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        user_email TEXT NOT NULL,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        datetime INTEGER NOT NULL,
        recurring TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        iconKey TEXT,
        notificationId INTEGER
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_reminders_user ON reminders(user_email)
    ''');

    // Create appointments table with user_email
    await db.execute('''
      CREATE TABLE appointments (
        id TEXT PRIMARY KEY,
        user_email TEXT NOT NULL,
        doctorId TEXT NOT NULL,
        doctorName TEXT NOT NULL,
        datetime INTEGER NOT NULL,
        notes TEXT,
        reminderMinutes INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        isConfirmed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_appointments_user ON appointments(user_email)
    ''');
  }

  /// Handle database version upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // For version 6, we're adding user_email column to all tables
    // Since this is a breaking change and we need user-specific data,
    // we'll drop and recreate all tables (data will be lost)
    if (oldVersion < 6) {
      debugPrint('Upgrading database from version $oldVersion to $newVersion');
      debugPrint('CLEARING ALL DATA to add user-specific support');

      // Drop all existing tables
      await db.execute('DROP TABLE IF EXISTS vital_records');
      await db.execute('DROP TABLE IF EXISTS vitals');
      await db.execute('DROP TABLE IF EXISTS symptom_entries');
      await db.execute('DROP TABLE IF EXISTS reminders');
      await db.execute('DROP TABLE IF EXISTS appointments');

      // Recreate with user_email column
      await _onCreate(db, newVersion);
      return;
    }

    // Legacy upgrade paths (kept for reference, won't be reached after v6)
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS vital_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp TEXT NOT NULL,
          weight_kg REAL,
          systolic INTEGER,
          diastolic INTEGER,
          heart_rate INTEGER,
          blood_sugar INTEGER
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS symptom_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp INTEGER NOT NULL,
          symptoms TEXT NOT NULL,
          notes TEXT
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reminders (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          type TEXT NOT NULL,
          datetime INTEGER NOT NULL,
          recurring TEXT,
          isCompleted INTEGER NOT NULL DEFAULT 0,
          notes TEXT,
          iconKey TEXT,
          notificationId INTEGER
        )
      ''');
    }

    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS appointments (
          id TEXT PRIMARY KEY,
          doctorId TEXT NOT NULL,
          doctorName TEXT NOT NULL,
          datetime INTEGER NOT NULL,
          notes TEXT,
          reminderMinutes INTEGER NOT NULL DEFAULT 0,
          createdAt INTEGER NOT NULL,
          isConfirmed INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
  }

  /// Helper to check if database is available
  void debugPrint(String message) {
    // Simple debug print helper
    // TODO: Replace with proper logging framework in production
    // ignore: avoid_print
    print('[LocalDatabase] $message');
  }

  /// Insert a complete vital record
  ///
  /// Attempts to save to SQLite database first, falls back to SharedPreferences on failure.
  ///
  /// Parameters:
  /// - [record]: VitalRecord to insert
  ///
  /// Returns: ID of the inserted record (as string), or throws on failure
  Future<String> insertVitalRecord(VitalRecord record) async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();

      final dataMap = record.toMap();
      dataMap['user_email'] = userEmail;

      final id = await db.insert(
        'vital_records',
        dataMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Inserted vital record with ID: $id for user: $userEmail');
      return id.toString();
    } catch (e) {
      debugPrint('SQLite insert failed, using SharedPreferences fallback: $e');
      return await _insertVitalRecordFallback(record);
    }
  }

  /// Fallback method to save vital record to SharedPreferences
  Future<String> _insertVitalRecordFallback(VitalRecord record) async {
    try {
      final prefs = await _preferences;
      final List<String> records = prefs.getStringList(_prefsKey) ?? [];

      // Generate a simple ID based on timestamp
      final id = record.timestamp.millisecondsSinceEpoch.toString();
      final recordWithId = VitalRecord(
        id: id,
        timestamp: record.timestamp,
        weightKg: record.weightKg,
        systolic: record.systolic,
        diastolic: record.diastolic,
        heartRate: record.heartRate,
        bloodSugar: record.bloodSugar,
      );

      records.add(jsonEncode(recordWithId.toJson()));
      await prefs.setStringList(_prefsKey, records);
      debugPrint('Saved vital record to SharedPreferences with ID: $id');
      return id;
    } catch (e) {
      throw Exception('Failed to save vital record: $e');
    }
  }

  /// Get all vital records, ordered by timestamp descending
  ///
  /// Parameters:
  /// - [limit]: Maximum number of records to return
  ///
  /// Returns: List of VitalRecord objects
  Future<List<VitalRecord>> getAllVitalRecords({int limit = 100}) async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();

      final results = await db.query(
        'vital_records',
        where: 'user_email = ?',
        whereArgs: [userEmail],
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      return results.map((map) => VitalRecord.fromMap(map)).toList();
    } catch (e) {
      debugPrint('SQLite query failed, using SharedPreferences fallback: $e');
      return await _getAllVitalRecordsFallback(limit: limit);
    }
  }

  /// Fallback method to get vital records from SharedPreferences
  Future<List<VitalRecord>> _getAllVitalRecordsFallback(
      {int limit = 100}) async {
    try {
      final prefs = await _preferences;
      final List<String> records = prefs.getStringList(_prefsKey) ?? [];

      final vitalRecords = records
          .map((json) =>
              VitalRecord.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList();

      // Sort by timestamp descending
      vitalRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return vitalRecords.take(limit).toList();
    } catch (e) {
      debugPrint('SharedPreferences fallback failed: $e');
      return [];
    }
  }

  /// Get the most recent vital record
  ///
  /// Returns: Most recent VitalRecord or null if none exist
  Future<VitalRecord?> getLatestVitalRecord() async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();
      final results = await db.query(
        'vital_records',
        where: 'user_email = ?',
        whereArgs: [userEmail],
        orderBy: 'timestamp DESC',
        limit: 1,
      );
      return results.isNotEmpty ? VitalRecord.fromMap(results.first) : null;
    } catch (e) {
      debugPrint('SQLite query failed, using SharedPreferences fallback: $e');
      final records = await _getAllVitalRecordsFallback(limit: 1);
      return records.isNotEmpty ? records.first : null;
    }
  }

  /// Get vital records within a date range
  ///
  /// Parameters:
  /// - [startDate]: Start of date range
  /// - [endDate]: End of date range
  ///
  /// Returns: List of VitalRecord objects in the specified range
  Future<List<VitalRecord>> getVitalRecordsInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();
      final results = await db.query(
        'vital_records',
        where: 'timestamp BETWEEN ? AND ? AND user_email = ?',
        whereArgs: [
          startDate.toIso8601String(),
          endDate.toIso8601String(),
          userEmail,
        ],
        orderBy: 'timestamp DESC',
      );
      return results.map((map) => VitalRecord.fromMap(map)).toList();
    } catch (e) {
      debugPrint('SQLite query failed, using SharedPreferences fallback: $e');
      final allRecords = await _getAllVitalRecordsFallback(limit: 1000);
      return allRecords
          .where((record) =>
              record.timestamp.isAfter(startDate) &&
              record.timestamp.isBefore(endDate))
          .toList();
    }
  }

  /// Legacy method: Insert a new vital reading
  ///
  /// Parameters:
  /// - [timestamp]: When the reading was taken
  /// - [type]: Type of vital (e.g., 'blood_pressure', 'heart_rate')
  /// - [value]: The reading value (e.g., '120/80', '75')
  ///
  /// Returns: ID of the inserted row
  Future<int> insertVital({
    required DateTime timestamp,
    required String type,
    required String value,
  }) async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();
      return await db.insert(
        'vitals',
        {
          'user_email': userEmail,
          'timestamp': timestamp.toIso8601String(),
          'type': type,
          'value': value,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Legacy insertVital failed: $e (this is expected on web)');
      // Return a fake ID for web compatibility
      return DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// Get the most recent vital reading of a specific type
  ///
  /// Parameters:
  /// - [type]: Type of vital to retrieve
  ///
  /// Returns: Map with vital data or null if not found
  Future<Map<String, dynamic>?> getLatestVital(String type) async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();
      final results = await db.query(
        'vitals',
        where: 'type = ? AND user_email = ?',
        whereArgs: [type, userEmail],
        orderBy: 'timestamp DESC',
        limit: 1,
      );

      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      debugPrint('Legacy getLatestVital failed: $e (expected on web)');
      // Return null on web - provider will use placeholder values
      return null;
    }
  }

  /// Get all vitals of a specific type, ordered by timestamp descending
  ///
  /// Parameters:
  /// - [type]: Type of vital to retrieve
  /// - [limit]: Maximum number of records to return (default: 100)
  Future<List<Map<String, dynamic>>> getVitalsByType(
    String type, {
    int limit = 100,
  }) async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();
      return await db.query(
        'vitals',
        where: 'type = ? AND user_email = ?',
        whereArgs: [type, userEmail],
        orderBy: 'timestamp DESC',
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to get vitals by type: $e');
    }
  }

  /// Get all vitals within a date range
  ///
  /// Parameters:
  /// - [startDate]: Start of date range
  /// - [endDate]: End of date range
  Future<List<Map<String, dynamic>>> getVitalsInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();
      return await db.query(
        'vitals',
        where: 'timestamp BETWEEN ? AND ? AND user_email = ?',
        whereArgs: [
          startDate.toIso8601String(),
          endDate.toIso8601String(),
          userEmail,
        ],
        orderBy: 'timestamp DESC',
      );
    } catch (e) {
      throw Exception('Failed to get vitals in range: $e');
    }
  }

  /// Delete all vitals data (for testing or reset purposes)
  Future<void> clearAllVitals() async {
    try {
      final db = await database;
      await db.delete('vitals');
    } catch (e) {
      throw Exception('Failed to clear vitals: $e');
    }
  }

  // ==================== SYMPTOM ENTRY METHODS ====================

  /// Insert a symptom entry
  ///
  /// Attempts to save to SQLite database first, falls back to SharedPreferences on failure.
  ///
  /// Parameters:
  /// - [entry]: SymptomEntry to insert (must import SymptomEntry model)
  ///
  /// Returns: ID of the inserted entry (as string), or null on failure
  Future<String?> insertSymptomEntry(dynamic entry) async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();
      final map = entry.toMap();
      map['user_email'] = userEmail;

      final id = await db.insert(
        'symptom_entries',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('Inserted symptom entry with ID: $id for user: $userEmail');
      return id.toString();
    } catch (e) {
      debugPrint(
          'SQLite insert failed for symptom, using SharedPreferences fallback: $e');
      return await _insertSymptomEntryFallback(entry);
    }
  }

  /// Fallback method to insert symptom entry using SharedPreferences
  Future<String?> _insertSymptomEntryFallback(dynamic entry) async {
    try {
      final prefs = await _preferences;

      // Generate unique ID
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      // Get existing entries
      final entriesJson = prefs.getString('symptom_entries') ?? '[]';
      final List<dynamic> entries = json.decode(entriesJson);

      // Add new entry with ID
      final map = entry.toMap();
      map['id'] = id;
      entries.add(map);

      // Save back
      await prefs.setString('symptom_entries', json.encode(entries));

      debugPrint('Saved symptom entry to SharedPreferences with ID: $id');
      return id;
    } catch (e) {
      debugPrint('Failed to save symptom entry to fallback: $e');
      return null;
    }
  }

  /// Get all symptom entries
  ///
  /// Returns list of SymptomEntry objects sorted by timestamp descending
  Future<List<dynamic>> getSymptomEntries() async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();
      final List<Map<String, dynamic>> maps = await db.query(
        'symptom_entries',
        where: 'user_email = ?',
        whereArgs: [userEmail],
        orderBy: 'timestamp DESC',
      );

      debugPrint('Retrieved ${maps.length} symptom entries from SQLite');

      // Import SymptomEntry dynamically to avoid circular dependency
      // Caller will need to convert maps to SymptomEntry objects
      return maps;
    } catch (e) {
      debugPrint(
          'SQLite query failed for symptoms, using SharedPreferences fallback: $e');
      return await _getSymptomEntriesFallback();
    }
  }

  /// Fallback method to get symptom entries from SharedPreferences
  Future<List<dynamic>> _getSymptomEntriesFallback() async {
    try {
      final prefs = await _preferences;
      final entriesJson = prefs.getString('symptom_entries') ?? '[]';
      final List<dynamic> entries = json.decode(entriesJson);

      // Sort by timestamp descending
      entries.sort((a, b) {
        final aTime = a['timestamp'] as int;
        final bTime = b['timestamp'] as int;
        return bTime.compareTo(aTime);
      });

      debugPrint(
          'Retrieved ${entries.length} symptom entries from SharedPreferences');
      return entries;
    } catch (e) {
      debugPrint('Failed to get symptom entries from fallback: $e');
      return [];
    }
  }

  /// Update an existing symptom entry
  ///
  /// Parameters:
  /// - [entry]: SymptomEntry with valid ID to update
  ///
  /// Returns: true if update was successful, false otherwise
  Future<bool> updateSymptomEntry(dynamic entry) async {
    if (entry.id == null) {
      debugPrint('Cannot update symptom entry without ID');
      return false;
    }

    try {
      final db = await database;
      final count = await db.update(
        'symptom_entries',
        entry.toMap(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );

      debugPrint('Updated symptom entry ${entry.id}: $count rows affected');
      return count > 0;
    } catch (e) {
      debugPrint(
          'SQLite update failed for symptom, using SharedPreferences fallback: $e');
      return await _updateSymptomEntryFallback(entry);
    }
  }

  /// Fallback method to update symptom entry in SharedPreferences
  Future<bool> _updateSymptomEntryFallback(dynamic entry) async {
    try {
      final prefs = await _preferences;
      final entriesJson = prefs.getString('symptom_entries') ?? '[]';
      final List<dynamic> entries = json.decode(entriesJson);

      // Find and update entry
      final index = entries.indexWhere((e) => e['id'] == entry.id);
      if (index != -1) {
        entries[index] = entry.toMap();
        await prefs.setString('symptom_entries', json.encode(entries));
        debugPrint('Updated symptom entry ${entry.id} in SharedPreferences');
        return true;
      }

      debugPrint('Symptom entry ${entry.id} not found in SharedPreferences');
      return false;
    } catch (e) {
      debugPrint('Failed to update symptom entry in fallback: $e');
      return false;
    }
  }

  /// Delete a symptom entry
  ///
  /// Parameters:
  /// - [entryId]: ID of the entry to delete
  ///
  /// Returns: true if deletion was successful, false otherwise
  Future<bool> deleteSymptomEntry(String entryId) async {
    try {
      final db = await database;
      final count = await db.delete(
        'symptom_entries',
        where: 'id = ?',
        whereArgs: [entryId],
      );

      debugPrint('Deleted symptom entry $entryId: $count rows affected');
      return count > 0;
    } catch (e) {
      debugPrint(
          'SQLite delete failed for symptom, using SharedPreferences fallback: $e');
      return await _deleteSymptomEntryFallback(entryId);
    }
  }

  /// Fallback method to delete symptom entry from SharedPreferences
  Future<bool> _deleteSymptomEntryFallback(String entryId) async {
    try {
      final prefs = await _preferences;
      final entriesJson = prefs.getString('symptom_entries') ?? '[]';
      final List<dynamic> entries = json.decode(entriesJson);

      // Remove entry
      final initialLength = entries.length;
      entries.removeWhere((e) => e['id'] == entryId);

      if (entries.length < initialLength) {
        await prefs.setString('symptom_entries', json.encode(entries));
        debugPrint('Deleted symptom entry $entryId from SharedPreferences');
        return true;
      }

      debugPrint('Symptom entry $entryId not found in SharedPreferences');
      return false;
    } catch (e) {
      debugPrint('Failed to delete symptom entry from fallback: $e');
      return false;
    }
  }

  /// Close the database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // ==================== REMINDER METHODS ====================

  /// Insert a reminder
  ///
  /// Attempts to save to SQLite database first, falls back to SharedPreferences on failure.
  ///
  /// Parameters:
  /// - [reminder]: Reminder to insert
  ///
  /// Returns: true if successful, false otherwise
  Future<bool> insertReminder(Reminder reminder) async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();

      final map = reminder.toMap();
      map['user_email'] = userEmail;

      await db.insert(
        'reminders',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint(
          'Inserted reminder with ID: ${reminder.id} for user: $userEmail');
      return true;
    } catch (e) {
      debugPrint(
          'SQLite insert failed for reminder, using SharedPreferences fallback: $e');
      return await _insertReminderFallback(reminder);
    }
  }

  /// Fallback method to insert reminder using SharedPreferences
  Future<bool> _insertReminderFallback(Reminder reminder) async {
    try {
      final prefs = await _preferences;
      final remindersJson = prefs.getString('reminders') ?? '[]';
      final List<dynamic> reminders = json.decode(remindersJson);

      reminders.add(reminder.toMap());
      await prefs.setString('reminders', json.encode(reminders));

      debugPrint('Saved reminder to SharedPreferences with ID: ${reminder.id}');
      return true;
    } catch (e) {
      debugPrint('Failed to save reminder to fallback: $e');
      return false;
    }
  }

  /// Get all reminders
  ///
  /// Returns list of Reminder objects sorted by datetime ascending
  Future<List<Reminder>> getReminders() async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();
      final List<Map<String, dynamic>> maps = await db.query(
        'reminders',
        where: 'user_email = ?',
        whereArgs: [userEmail],
        orderBy: 'datetime ASC',
      );

      debugPrint('Retrieved ${maps.length} reminders from SQLite');
      return maps.map((map) => Reminder.fromMap(map)).toList();
    } catch (e) {
      debugPrint(
          'SQLite query failed for reminders, using SharedPreferences fallback: $e');
      return await _getRemindersFallback();
    }
  }

  /// Fallback method to get reminders from SharedPreferences
  Future<List<Reminder>> _getRemindersFallback() async {
    try {
      final prefs = await _preferences;
      final remindersJson = prefs.getString('reminders') ?? '[]';
      final List<dynamic> reminders = json.decode(remindersJson);

      final reminderObjects = reminders
          .map((map) => Reminder.fromMap(map as Map<String, dynamic>))
          .toList();

      // Sort by datetime ascending
      reminderObjects.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      debugPrint(
          'Retrieved ${reminderObjects.length} reminders from SharedPreferences');
      return reminderObjects;
    } catch (e) {
      debugPrint('Failed to get reminders from fallback: $e');
      return [];
    }
  }

  /// Get a specific reminder by ID
  ///
  /// Parameters:
  /// - [id]: ID of the reminder to retrieve
  ///
  /// Returns: Reminder object or null if not found
  Future<Reminder?> getReminderById(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'reminders',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return Reminder.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint(
          'SQLite query failed for reminder by ID, using SharedPreferences fallback: $e');
      return await _getReminderByIdFallback(id);
    }
  }

  /// Fallback method to get reminder by ID from SharedPreferences
  Future<Reminder?> _getReminderByIdFallback(String id) async {
    try {
      final reminders = await _getRemindersFallback();
      return reminders.firstWhere(
        (reminder) => reminder.id == id,
        orElse: () => throw Exception('Reminder not found'),
      );
    } catch (e) {
      debugPrint('Failed to get reminder by ID from fallback: $e');
      return null;
    }
  }

  /// Update an existing reminder
  ///
  /// Parameters:
  /// - [reminder]: Reminder object with updated data
  ///
  /// Returns: true if update was successful, false otherwise
  Future<bool> updateReminder(Reminder reminder) async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();

      final map = reminder.toMap();
      map['user_email'] = userEmail;

      final count = await db.update(
        'reminders',
        map,
        where: 'id = ? AND user_email = ?',
        whereArgs: [reminder.id, userEmail],
      );

      debugPrint('Updated reminder ${reminder.id}: $count rows affected');
      return count > 0;
    } catch (e) {
      debugPrint(
          'SQLite update failed for reminder, using SharedPreferences fallback: $e');
      return await _updateReminderFallback(reminder);
    }
  }

  /// Fallback method to update reminder in SharedPreferences
  Future<bool> _updateReminderFallback(Reminder reminder) async {
    try {
      final prefs = await _preferences;
      final remindersJson = prefs.getString('reminders') ?? '[]';
      final List<dynamic> reminders = json.decode(remindersJson);

      // Find and update reminder
      final index = reminders.indexWhere((r) => r['id'] == reminder.id);
      if (index != -1) {
        reminders[index] = reminder.toMap();
        await prefs.setString('reminders', json.encode(reminders));
        debugPrint('Updated reminder ${reminder.id} in SharedPreferences');
        return true;
      }

      debugPrint('Reminder ${reminder.id} not found in SharedPreferences');
      return false;
    } catch (e) {
      debugPrint('Failed to update reminder in fallback: $e');
      return false;
    }
  }

  /// Delete a reminder
  ///
  /// Parameters:
  /// - [reminderId]: ID of the reminder to delete
  ///
  /// Returns: true if deletion was successful, false otherwise
  Future<bool> deleteReminder(String reminderId) async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();
      final count = await db.delete(
        'reminders',
        where: 'id = ? AND user_email = ?',
        whereArgs: [reminderId, userEmail],
      );

      debugPrint('Deleted reminder $reminderId: $count rows affected');
      return count > 0;
    } catch (e) {
      debugPrint(
          'SQLite delete failed for reminder, using SharedPreferences fallback: $e');
      return await _deleteReminderFallback(reminderId);
    }
  }

  /// Fallback method to delete reminder from SharedPreferences
  Future<bool> _deleteReminderFallback(String reminderId) async {
    try {
      final prefs = await _preferences;
      final remindersJson = prefs.getString('reminders') ?? '[]';
      final List<dynamic> reminders = json.decode(remindersJson);

      // Remove reminder
      final initialLength = reminders.length;
      reminders.removeWhere((r) => r['id'] == reminderId);

      if (reminders.length < initialLength) {
        await prefs.setString('reminders', json.encode(reminders));
        debugPrint('Deleted reminder $reminderId from SharedPreferences');
        return true;
      }

      debugPrint('Reminder $reminderId not found in SharedPreferences');
      return false;
    } catch (e) {
      debugPrint('Failed to delete reminder from fallback: $e');
      return false;
    }
  }

  /// Get reminders by type
  ///
  /// Parameters:
  /// - [type]: ReminderType to filter by
  ///
  /// Returns: List of reminders of the specified type
  Future<List<Reminder>> getRemindersByType(ReminderType type) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'reminders',
        where: 'type = ?',
        whereArgs: [type.name],
        orderBy: 'datetime ASC',
      );

      return maps.map((map) => Reminder.fromMap(map)).toList();
    } catch (e) {
      debugPrint(
          'SQLite query failed for reminders by type, using fallback: $e');
      final allReminders = await _getRemindersFallback();
      return allReminders.where((r) => r.type == type).toList();
    }
  }

  /// Get active (non-completed or recurring) reminders
  ///
  /// Returns: List of active reminders
  Future<List<Reminder>> getActiveReminders() async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();
      final List<Map<String, dynamic>> maps = await db.query(
        'reminders',
        where: '(isCompleted = ? OR recurring IS NOT NULL) AND user_email = ?',
        whereArgs: [0, userEmail],
        orderBy: 'datetime ASC',
      );

      return maps.map((map) => Reminder.fromMap(map)).toList();
    } catch (e) {
      debugPrint(
          'SQLite query failed for active reminders, using fallback: $e');
      final allReminders = await _getRemindersFallback();
      return allReminders.where((r) => r.shouldShow).toList();
    }
  }

  // ==================== APPOINTMENT METHODS ====================

  /// Insert an appointment
  ///
  /// Attempts to save to SQLite database first, falls back to SharedPreferences on failure.
  ///
  /// Parameters:
  /// - [appointment]: Appointment to insert
  ///
  /// Returns: true if successful, false otherwise
  Future<bool> insertAppointment(Appointment appointment) async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();

      final map = appointment.toMap();
      map['user_email'] = userEmail;

      await db.insert(
        'appointments',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint(
          'Inserted appointment with ID: ${appointment.id} for user: $userEmail');
      return true;
    } catch (e) {
      debugPrint(
          'SQLite insert failed for appointment, using SharedPreferences fallback: $e');
      return await _insertAppointmentFallback(appointment);
    }
  }

  /// Fallback method to insert appointment using SharedPreferences
  Future<bool> _insertAppointmentFallback(Appointment appointment) async {
    try {
      final prefs = await _preferences;
      final appointmentsJson = prefs.getString('appointments') ?? '[]';
      final List<dynamic> appointments = json.decode(appointmentsJson);

      appointments.add(appointment.toMap());
      await prefs.setString('appointments', json.encode(appointments));

      debugPrint(
          'Saved appointment to SharedPreferences with ID: ${appointment.id}');
      return true;
    } catch (e) {
      debugPrint('Failed to save appointment to fallback: $e');
      return false;
    }
  }

  /// Get all appointments
  ///
  /// Returns list of Appointment objects sorted by datetime ascending
  Future<List<Appointment>> getAppointments() async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();
      final List<Map<String, dynamic>> maps = await db.query(
        'appointments',
        where: 'user_email = ?',
        whereArgs: [userEmail],
        orderBy: 'datetime ASC',
      );

      debugPrint('Retrieved ${maps.length} appointments from SQLite');
      return maps.map((map) => Appointment.fromMap(map)).toList();
    } catch (e) {
      debugPrint(
          'SQLite query failed for appointments, using SharedPreferences fallback: $e');
      return await _getAppointmentsFallback();
    }
  }

  /// Fallback method to get appointments from SharedPreferences
  Future<List<Appointment>> _getAppointmentsFallback() async {
    try {
      final prefs = await _preferences;
      final appointmentsJson = prefs.getString('appointments') ?? '[]';
      final List<dynamic> appointments = json.decode(appointmentsJson);

      final appointmentObjects = appointments
          .map((map) => Appointment.fromMap(map as Map<String, dynamic>))
          .toList();

      // Sort by datetime ascending
      appointmentObjects.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      debugPrint(
          'Retrieved ${appointmentObjects.length} appointments from SharedPreferences');
      return appointmentObjects;
    } catch (e) {
      debugPrint('Failed to get appointments from fallback: $e');
      return [];
    }
  }

  /// Get a specific appointment by ID
  ///
  /// Parameters:
  /// - [id]: ID of the appointment to retrieve
  ///
  /// Returns: Appointment object or null if not found
  Future<Appointment?> getAppointmentById(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'appointments',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return Appointment.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint(
          'SQLite query failed for appointment by ID, using SharedPreferences fallback: $e');
      return await _getAppointmentByIdFallback(id);
    }
  }

  /// Fallback method to get appointment by ID from SharedPreferences
  Future<Appointment?> _getAppointmentByIdFallback(String id) async {
    try {
      final appointments = await _getAppointmentsFallback();
      return appointments.firstWhere(
        (appointment) => appointment.id == id,
        orElse: () => throw Exception('Appointment not found'),
      );
    } catch (e) {
      debugPrint('Failed to get appointment by ID from fallback: $e');
      return null;
    }
  }

  /// Update an existing appointment
  ///
  /// Parameters:
  /// - [appointment]: Appointment object with updated data
  ///
  /// Returns: true if update was successful, false otherwise
  Future<bool> updateAppointment(Appointment appointment) async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();

      final map = appointment.toMap();
      map['user_email'] = userEmail;

      final count = await db.update(
        'appointments',
        map,
        where: 'id = ? AND user_email = ?',
        whereArgs: [appointment.id, userEmail],
      );

      debugPrint('Updated appointment ${appointment.id}: $count rows affected');
      return count > 0;
    } catch (e) {
      debugPrint(
          'SQLite update failed for appointment, using SharedPreferences fallback: $e');
      return await _updateAppointmentFallback(appointment);
    }
  }

  /// Fallback method to update appointment in SharedPreferences
  Future<bool> _updateAppointmentFallback(Appointment appointment) async {
    try {
      final prefs = await _preferences;
      final appointmentsJson = prefs.getString('appointments') ?? '[]';
      final List<dynamic> appointments = json.decode(appointmentsJson);

      // Find and update appointment
      final index = appointments.indexWhere((a) => a['id'] == appointment.id);
      if (index != -1) {
        appointments[index] = appointment.toMap();
        await prefs.setString('appointments', json.encode(appointments));
        debugPrint(
            'Updated appointment ${appointment.id} in SharedPreferences');
        return true;
      }

      debugPrint(
          'Appointment ${appointment.id} not found in SharedPreferences');
      return false;
    } catch (e) {
      debugPrint('Failed to update appointment in fallback: $e');
      return false;
    }
  }

  /// Delete an appointment
  ///
  /// Parameters:
  /// - [appointmentId]: ID of the appointment to delete
  ///
  /// Returns: true if deletion was successful, false otherwise
  Future<bool> deleteAppointment(String appointmentId) async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();
      final count = await db.delete(
        'appointments',
        where: 'id = ? AND user_email = ?',
        whereArgs: [appointmentId, userEmail],
      );

      debugPrint('Deleted appointment $appointmentId: $count rows affected');
      return count > 0;
    } catch (e) {
      debugPrint(
          'SQLite delete failed for appointment, using SharedPreferences fallback: $e');
      return await _deleteAppointmentFallback(appointmentId);
    }
  }

  /// Fallback method to delete appointment from SharedPreferences
  Future<bool> _deleteAppointmentFallback(String appointmentId) async {
    try {
      final prefs = await _preferences;
      final appointmentsJson = prefs.getString('appointments') ?? '[]';
      final List<dynamic> appointments = json.decode(appointmentsJson);

      // Remove appointment
      final initialLength = appointments.length;
      appointments.removeWhere((a) => a['id'] == appointmentId);

      if (appointments.length < initialLength) {
        await prefs.setString('appointments', json.encode(appointments));
        debugPrint('Deleted appointment $appointmentId from SharedPreferences');
        return true;
      }

      debugPrint('Appointment $appointmentId not found in SharedPreferences');
      return false;
    } catch (e) {
      debugPrint('Failed to delete appointment from fallback: $e');
      return false;
    }
  }

  /// Get appointments by doctor ID
  ///
  /// Parameters:
  /// - [doctorId]: ID of the doctor
  ///
  /// Returns: List of appointments for the specified doctor
  Future<List<Appointment>> getAppointmentsByDoctor(String doctorId) async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();
      final List<Map<String, dynamic>> maps = await db.query(
        'appointments',
        where: 'doctorId = ? AND user_email = ?',
        whereArgs: [doctorId, userEmail],
        orderBy: 'datetime ASC',
      );

      return maps.map((map) => Appointment.fromMap(map)).toList();
    } catch (e) {
      debugPrint(
          'SQLite query failed for appointments by doctor, using fallback: $e');
      final allAppointments = await _getAppointmentsFallback();
      return allAppointments.where((a) => a.doctorId == doctorId).toList();
    }
  }

  /// Get upcoming appointments (future only)
  ///
  /// Returns: List of upcoming appointments
  Future<List<Appointment>> getUpcomingAppointments() async {
    try {
      final db = await database;
      final userEmail = await _getCurrentUserEmail();
      final now = DateTime.now().millisecondsSinceEpoch;
      final List<Map<String, dynamic>> maps = await db.query(
        'appointments',
        where: 'datetime > ? AND user_email = ?',
        whereArgs: [now, userEmail],
        orderBy: 'datetime ASC',
      );

      return maps.map((map) => Appointment.fromMap(map)).toList();
    } catch (e) {
      debugPrint(
          'SQLite query failed for upcoming appointments, using fallback: $e');
      final allAppointments = await _getAppointmentsFallback();
      return allAppointments.where((a) => a.isFuture).toList();
    }
  }
}
