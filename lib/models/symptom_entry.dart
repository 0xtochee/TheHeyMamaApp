import 'dart:convert';

/// Model representing a symptom entry with selected symptoms and optional notes
///
/// Used for tracking pregnancy-related symptoms over time. Each entry
/// captures the timestamp, selected symptoms, and any additional notes
/// the user wants to record.
class SymptomEntry {
  /// Unique identifier for the entry (null for new entries)
  final String? id;

  /// When the entry was created
  final DateTime timestamp;

  /// List of selected symptom names (e.g., ["Headache", "Nausea"])
  final List<String> symptoms;

  /// Optional user notes about the symptoms
  final String? notes;

  const SymptomEntry({
    this.id,
    required this.timestamp,
    required this.symptoms,
    this.notes,
  });

  /// Create a SymptomEntry from a database map
  factory SymptomEntry.fromMap(Map<String, dynamic> map) {
    // Parse symptoms from JSON string or CSV
    List<String> symptomsList = [];
    final symptomsData = map['symptoms'];

    if (symptomsData is String) {
      if (symptomsData.startsWith('[')) {
        // JSON array format
        try {
          symptomsList = List<String>.from(json.decode(symptomsData));
        } catch (e) {
          // Fallback to empty list if parsing fails
          symptomsList = [];
        }
      } else {
        // CSV format
        symptomsList = symptomsData.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
    } else if (symptomsData is List) {
      symptomsList = List<String>.from(symptomsData);
    }

    return SymptomEntry(
      id: map['id'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      symptoms: symptomsList,
      notes: map['notes'] as String?,
    );
  }

  /// Convert SymptomEntry to a database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'symptoms': json.encode(symptoms), // Store as JSON array
      'notes': notes,
    };
  }

  /// Create a copy of this entry with updated fields
  SymptomEntry copyWith({
    String? id,
    DateTime? timestamp,
    List<String>? symptoms,
    String? notes,
  }) {
    return SymptomEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
    );
  }

  /// Get a human-readable summary of symptoms
  String get symptomsSummary {
    if (symptoms.isEmpty) return 'No symptoms selected';
    if (symptoms.length == 1) return symptoms.first;
    if (symptoms.length == 2) return '${symptoms[0]}, ${symptoms[1]}';
    return '${symptoms[0]}, ${symptoms[1]}, +${symptoms.length - 2} more';
  }

  /// Check if this entry is valid (has symptoms or notes)
  bool get isValid => symptoms.isNotEmpty || (notes != null && notes!.isNotEmpty);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SymptomEntry &&
        other.id == id &&
        other.timestamp == timestamp &&
        _listEquals(other.symptoms, symptoms) &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        timestamp.hashCode ^
        symptoms.hashCode ^
        notes.hashCode;
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'SymptomEntry(id: $id, timestamp: $timestamp, symptoms: $symptoms, notes: $notes)';
  }
}

/// Available symptom options
///
/// This list can be extended or customized based on pregnancy-specific
/// symptoms that need to be tracked.
class SymptomOptions {
  static const List<String> defaultSymptoms = [
    'Headache',
    'Nausea',
    'Swelling',
    'Blurred Vision',
    'Dizziness',
    'Fatigue',
  ];

  /// Get symptom icon for display (optional)
  static String getSymptomIcon(String symptom) {
    switch (symptom.toLowerCase()) {
      case 'headache':
        return '🤕';
      case 'nausea':
        return '🤢';
      case 'swelling':
        return '🦶';
      case 'blurred vision':
        return '👁️';
      case 'dizziness':
        return '😵';
      case 'fatigue':
        return '😴';
      default:
        return '📝';
    }
  }

  /// Get semantic description for accessibility
  static String getSymptomSemanticLabel(String symptom) {
    return 'Select $symptom';
  }
}
