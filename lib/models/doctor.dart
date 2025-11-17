/// Model class for doctor information
///
/// Represents a doctor with their profile details.
class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String? location;
  final String? avatarAsset;
  final String? phone;
  final String? email;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    this.location,
    this.avatarAsset,
    this.phone,
    this.email,
  });

  /// Get initials from doctor name for avatar fallback
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'D';
  }

  /// Create copy with updated fields
  Doctor copyWith({
    String? id,
    String? name,
    String? specialty,
    String? location,
    String? avatarAsset,
    String? phone,
    String? email,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      location: location ?? this.location,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'location': location,
      'avatarAsset': avatarAsset,
      'phone': phone,
      'email': email,
    };
  }

  /// Create from JSON
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      location: json['location'] as String?,
      avatarAsset: json['avatarAsset'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );
  }

  @override
  String toString() {
    return 'Doctor(id: $id, name: $name, specialty: $specialty, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Doctor && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
