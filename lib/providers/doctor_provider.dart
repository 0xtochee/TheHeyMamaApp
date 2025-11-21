import 'package:flutter/foundation.dart';

import '../models/doctor.dart';

/// Provider for managing doctors directory
///
/// Provides a list of available doctors with sample data.
/// In production, this would fetch from a backend API.
class DoctorProvider extends ChangeNotifier {
  List<Doctor> _doctors = [];

  List<Doctor> get doctors => _doctors;

  /// Initialize provider with sample doctors
  void initialize() {
    _doctors = [
      const Doctor(
        id: 'doc_1',
        name: 'Dr. Amelia Harper',
        specialty: 'Obstetrician-Gynecologist',
        location: 'San Francisco',
        avatarAsset: 'images/female_doctor.png',
        phone: '+1 (415) 555-0101',
        email: 'amelia.harper@hospital.com',
      ),
      const Doctor(
        id: 'doc_5',
        name: 'Dr. Ethan Carter',
        specialty: 'Gynecologist',
        location: 'Oakland',
        avatarAsset: 'images/doctor_placeholder.png',
        phone: '+1 (510) 555-0105',
        email: 'ethan.carter@hospital.com',
      ),
      const Doctor(
        id: 'doc_2',
        name: 'Dr. Sophia Bennett',
        specialty: 'Obstetrician-Gynecologist',
        location: 'Oakland',
        avatarAsset: 'images/female_doctor.png',
        phone: '+1 (510) 555-0102',
        email: 'sophia.bennett@hospital.com',
      ),
      const Doctor(
        id: 'doc_3',
        name: 'Dr. Olivia Martinez',
        specialty: 'Obstetrician-Gynecologist',
        location: 'Berkeley',
        avatarAsset: 'images/female_doctor.png',
        phone: '+1 (510) 555-0103',
        email: 'olivia.martinez@hospital.com',
      ),
      const Doctor(
        id: 'doc_4',
        name: 'Dr. Isabella Rodriguez',
        specialty: 'Obstetrician-Gynecologist',
        location: 'San Jose',
        avatarAsset: 'images/female_doctor.png',
        phone: '+1 (408) 555-0104',
        email: 'isabella.rodriguez@hospital.com',
      ),
    ];
    notifyListeners();
  }

  /// Get doctor by ID
  Doctor? getDoctorById(String doctorId) {
    try {
      return _doctors.firstWhere((doctor) => doctor.id == doctorId);
    } catch (e) {
      return null;
    }
  }

  /// Search doctors by name or specialty
  List<Doctor> searchDoctors(String query) {
    if (query.isEmpty) return _doctors;

    final lowerQuery = query.toLowerCase();
    return _doctors.where((doctor) {
      return doctor.name.toLowerCase().contains(lowerQuery) ||
          doctor.specialty.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
