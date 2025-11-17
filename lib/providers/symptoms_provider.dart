import 'package:flutter/foundation.dart';
import '../models/symptom_entry.dart';
import '../services/local_db.dart';

/// Provider for managing symptom entries and symptom tracking state
///
/// Handles:
/// - Loading symptom entries from local database
/// - Adding new symptom entries
/// - Updating existing entries
/// - Managing available symptom options
/// - Notifying listeners of state changes
class SymptomsProvider with ChangeNotifier {
  final LocalDatabase _db = LocalDatabase();

  // State
  List<SymptomEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  /// Available symptoms for selection (configurable)
  List<String> _availableSymptoms = List.from(SymptomOptions.defaultSymptoms);

  // Getters
  List<SymptomEntry> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get availableSymptoms => List.unmodifiable(_availableSymptoms);

  /// Get entries count
  int get entriesCount => _entries.length;

  /// Get the most recent entry
  SymptomEntry? get latestEntry {
    if (_entries.isEmpty) return null;
    return _entries.first;
  }

  /// Get entries for a specific date
  List<SymptomEntry> getEntriesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _entries.where((entry) {
      return entry.timestamp.isAfter(startOfDay) &&
          entry.timestamp.isBefore(endOfDay);
    }).toList();
  }

  /// Get entries within a date range
  List<SymptomEntry> getEntriesInRange(DateTime start, DateTime end) {
    return _entries.where((entry) {
      return entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end);
    }).toList();
  }

  /// Initialize and load entries from database
  Future<void> initialize() async {
    debugPrint('[SymptomsProvider] Initializing...');
    await fetchEntries();
  }

  /// Fetch all entries from database
  Future<void> fetchEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('[SymptomsProvider] Fetching symptom entries...');
      final fetchedMaps = await _db.getSymptomEntries();

      // Convert maps to SymptomEntry objects
      _entries = fetchedMaps.map((map) {
        if (map is Map<String, dynamic>) {
          return SymptomEntry.fromMap(map);
        } else {
          // Handle dynamic type from SharedPreferences
          return SymptomEntry.fromMap(Map<String, dynamic>.from(map as Map));
        }
      }).toList();

      // Sort by timestamp descending (most recent first)
      _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint('[SymptomsProvider] Loaded ${_entries.length} entries');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[SymptomsProvider] Error fetching entries: $e');
      _error = 'Failed to load symptom entries';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new symptom entry
  ///
  /// Returns the saved entry with generated ID, or null if save failed
  Future<SymptomEntry?> addEntry(SymptomEntry entry) async {
    try {
      debugPrint('[SymptomsProvider] Adding new entry: ${entry.symptoms}');

      // Validate entry
      if (!entry.isValid) {
        debugPrint('[SymptomsProvider] Invalid entry - no symptoms or notes');
        _error = 'Please select at least one symptom or add notes';
        notifyListeners();
        return null;
      }

      // Save to database
      final id = await _db.insertSymptomEntry(entry);

      if (id == null) {
        debugPrint('[SymptomsProvider] Failed to save entry');
        _error = 'Failed to save symptom entry';
        notifyListeners();
        return null;
      }

      // Create entry with ID
      final savedEntry = entry.copyWith(id: id);

      // Add to local list and re-sort
      _entries.insert(0, savedEntry); // Add at beginning (most recent)
      _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint('[SymptomsProvider] Entry saved with ID: $id');
      _error = null;
      notifyListeners();

      return savedEntry;
    } catch (e) {
      debugPrint('[SymptomsProvider] Error adding entry: $e');
      _error = 'Failed to save symptom entry: $e';
      notifyListeners();
      return null;
    }
  }

  /// Update an existing symptom entry
  ///
  /// Returns true if update was successful
  Future<bool> updateEntry(SymptomEntry entry) async {
    if (entry.id == null) {
      debugPrint('[SymptomsProvider] Cannot update entry without ID');
      return false;
    }

    try {
      debugPrint('[SymptomsProvider] Updating entry: ${entry.id}');

      final success = await _db.updateSymptomEntry(entry);

      if (success) {
        // Update in local list
        final index = _entries.indexWhere((e) => e.id == entry.id);
        if (index != -1) {
          _entries[index] = entry;
          _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          notifyListeners();
        }
        debugPrint('[SymptomsProvider] Entry updated successfully');
      } else {
        debugPrint('[SymptomsProvider] Failed to update entry');
        _error = 'Failed to update symptom entry';
        notifyListeners();
      }

      return success;
    } catch (e) {
      debugPrint('[SymptomsProvider] Error updating entry: $e');
      _error = 'Failed to update symptom entry: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a symptom entry
  ///
  /// Returns true if deletion was successful
  Future<bool> deleteEntry(String entryId) async {
    try {
      debugPrint('[SymptomsProvider] Deleting entry: $entryId');

      final success = await _db.deleteSymptomEntry(entryId);

      if (success) {
        _entries.removeWhere((e) => e.id == entryId);
        notifyListeners();
        debugPrint('[SymptomsProvider] Entry deleted successfully');
      } else {
        debugPrint('[SymptomsProvider] Failed to delete entry');
        _error = 'Failed to delete symptom entry';
        notifyListeners();
      }

      return success;
    } catch (e) {
      debugPrint('[SymptomsProvider] Error deleting entry: $e');
      _error = 'Failed to delete symptom entry: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update available symptoms list (for customization)
  void updateAvailableSymptoms(List<String> symptoms) {
    _availableSymptoms = List.from(symptoms);
    debugPrint('[SymptomsProvider] Updated available symptoms: $_availableSymptoms');
    notifyListeners();
  }

  /// Add a custom symptom to available options
  void addCustomSymptom(String symptom) {
    if (!_availableSymptoms.contains(symptom)) {
      _availableSymptoms.add(symptom);
      debugPrint('[SymptomsProvider] Added custom symptom: $symptom');
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get symptom frequency statistics
  Map<String, int> getSymptomFrequency() {
    final frequency = <String, int>{};

    for (final entry in _entries) {
      for (final symptom in entry.symptoms) {
        frequency[symptom] = (frequency[symptom] ?? 0) + 1;
      }
    }

    return frequency;
  }

  /// Get entries grouped by date
  Map<DateTime, List<SymptomEntry>> getEntriesGroupedByDate() {
    final grouped = <DateTime, List<SymptomEntry>>{};

    for (final entry in _entries) {
      final dateKey = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(entry);
    }

    return grouped;
  }
}
