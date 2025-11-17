import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doctor.dart';

/// Reusable tile widget for displaying doctor information
///
/// Displays doctor avatar, name, specialty, location with a Book button.
class DoctorTile extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback? onBook;
  final VoidCallback? onTap;

  const DoctorTile({
    super.key,
    required this.doctor,
    this.onBook,
    this.onTap,
  });

  // Design constants
  static const Color _primaryBlue = Color(0xFF0D79FF);
  static const Color _headingText = Color(0xFF182033);
  static const Color _subtext = Color(0xFF5B6B7A);
  static const double _avatarSize = 64.0;
  static const double _tileHeight = 96.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${doctor.name}, ${doctor.specialty}${doctor.location != null ? ", ${doctor.location}" : ""}',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: _tileHeight,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE6E9EE),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Doctor Avatar
              _buildAvatar(),

              const SizedBox(width: 12),

              // Doctor Info
              Expanded(
                child: _buildDoctorInfo(),
              ),

              const SizedBox(width: 8),

              // Book Button
              if (onBook != null) _buildBookButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build doctor avatar with fallback to initials
  Widget _buildAvatar() {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF5F6F7),
      ),
      child: doctor.avatarAsset != null
          ? ClipOval(
              child: Image.asset(
                doctor.avatarAsset!,
                width: _avatarSize,
                height: _avatarSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to initials if image fails to load
                  return _buildInitialsAvatar();
                },
              ),
            )
          : _buildInitialsAvatar(),
    );
  }

  /// Build initials-based avatar fallback
  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        doctor.initials,
        style: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _primaryBlue,
        ),
      ),
    );
  }

  /// Build doctor information section
  Widget _buildDoctorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Doctor Name
        Text(
          doctor.name,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _headingText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // Specialty
        Text(
          doctor.specialty,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: _subtext,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Location (if available)
        if (doctor.location != null) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: _subtext,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  doctor.location!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _subtext,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Build Book button
  Widget _buildBookButton() {
    return Semantics(
      label: 'Book appointment with ${doctor.name}',
      button: true,
      child: ElevatedButton(
        onPressed: onBook,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          minimumSize: const Size(80, 40),
        ),
        child: Text(
          'Book',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
