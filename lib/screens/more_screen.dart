import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/appointments_provider.dart';
import '../providers/doctor_provider.dart';
import '../utils/responsive_helper.dart';

/// More Screen - Doctor & Support, Community, and Settings
///
/// A comprehensive screen displaying:
/// - Doctor profiles with booking functionality
/// - Community discussion previews
/// - Settings & Account access
///
/// This is a static preview screen with placeholder functionality.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  // Design constants
  static const Color _primaryBlue = Color(0xFF0D79FF);
  static const Color _headingText = Color(0xFF182033);
  static const Color _subtext = Color(0xFF5B6B7A);
  static const Color _timestampGrey = Color(0xFFA0A7B3);
  static const Color _navInactive = Color(0xFF8A99A8);

  static const double _buttonRadius = 28.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getHorizontalPadding(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        height: ResponsiveHelper.getVerticalPadding(context)),

                    // Doctor & Support Section
                    _buildDoctorSupportSection(context),

                    SizedBox(
                        height: ResponsiveHelper.getSectionSpacing(context)),

                    // Community Section
                    _buildCommunitySection(context),

                    SizedBox(
                        height: ResponsiveHelper.getSectionSpacing(context)),

                    // Settings & Account Section
                    _buildSettingsSection(context),

                    SizedBox(
                        height: ResponsiveHelper.getVerticalPadding(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build top bar with back button and title
  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getHorizontalPadding(context),
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE6E9EE).withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          Semantics(
            label: 'Go back',
            button: true,
            child: InkWell(
              onTap: () {
                // TODO: Add navigation back functionality
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: _headingText,
                ),
              ),
            ),
          ),

          // Title
          Expanded(
            child: Text(
              'More',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveHelper.getTitleFontSize(context),
                fontWeight: FontWeight.w500,
                color: _headingText,
              ),
            ),
          ),

          // Spacer for symmetry
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  /// Build Doctor & Support section
  Widget _buildDoctorSupportSection(BuildContext context) {
    return Consumer2<DoctorProvider, AppointmentsProvider>(
      builder: (context, doctorProvider, appointmentsProvider, child) {
        // Get unique doctors from upcoming appointments
        final upcomingAppointments = appointmentsProvider.upcomingAppointments;
        final Set<String> doctorIdsWithAppointments = {};
        final List<Map<String, dynamic>> doctorsToShow = [];

        // First, add all doctors with appointments (showing appointment time)
        for (final appointment in upcomingAppointments) {
          if (!doctorIdsWithAppointments.contains(appointment.doctorId)) {
            doctorIdsWithAppointments.add(appointment.doctorId);
            final doctor = doctorProvider.getDoctorById(appointment.doctorId);
            if (doctor != null) {
              final dateStr =
                  DateFormat('MMM d, h:mm a').format(appointment.dateTime);
              doctorsToShow.add({
                'name': doctor.name,
                'subtitle': 'Upcoming: $dateStr',
                'avatarPath':
                    doctor.avatarAsset ?? 'images/doctor_placeholder.png',
                'semanticLabel': 'Appointment with ${doctor.name} on $dateStr',
                'hasAppointment': true,
                'appointmentId': appointment.id,
              });
            }
          }
        }

        // Add remaining doctors from the directory
        final allDoctors = doctorProvider.doctors;
        for (final doctor in allDoctors) {
          if (!doctorIdsWithAppointments.contains(doctor.id)) {
            doctorsToShow.add({
              'name': doctor.name,
              'subtitle':
                  '${doctor.specialty}${doctor.location != null ? ", ${doctor.location}" : ""}',
              'avatarPath':
                  doctor.avatarAsset ?? 'images/doctor_placeholder.png',
              'semanticLabel':
                  '${doctor.name}, ${doctor.specialty}${doctor.location != null ? " in ${doctor.location}" : ""}',
              'hasAppointment': false,
            });
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(
              'Doctor & Support',
              style: GoogleFonts.inter(
                fontSize: ResponsiveHelper.getHeadingFontSize(context),
                fontWeight: FontWeight.w600,
                color: _headingText,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getItemSpacing(context)),

            // Scrollable doctor list with responsive height
            Container(
              constraints: BoxConstraints(
                maxHeight: ResponsiveHelper.getListMaxHeight(context),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: doctorsToShow.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: ResponsiveHelper.getItemSpacing(context)),
                itemBuilder: (context, index) {
                  final doctorData = doctorsToShow[index];
                  final hasAppointment = doctorData['hasAppointment'] as bool;

                  return _buildDoctorCard(
                    context: context,
                    name: doctorData['name'] as String,
                    subtitle: doctorData['subtitle'] as String,
                    avatarPath: doctorData['avatarPath'] as String,
                    semanticLabel: doctorData['semanticLabel'] as String,
                    hasDeleteButton: hasAppointment,
                    onDelete: hasAppointment
                        ? () async {
                            final appointmentId =
                                doctorData['appointmentId'] as String;
                            final confirmed =
                                await _showDeleteConfirmDialog(context);
                            if (confirmed == true) {
                              await appointmentsProvider
                                  .deleteAppointment(appointmentId);
                            }
                          }
                        : null,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Book Appointment Button (always same text)
            _buildPrimaryButton(
              context: context,
              text: 'Book Appointment',
              onPressed: () {
                Navigator.pushNamed(context, '/doctorDirectory');
              },
              semanticLabel: 'Book an appointment with a doctor',
            ),
          ],
        );
      },
    );
  }

  /// Show confirmation dialog for deleting appointment
  Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel Appointment',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _headingText,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this appointment?',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: _headingText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'No',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _subtext,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Yes, Cancel',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFE53935),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual doctor card
  Widget _buildDoctorCard({
    required BuildContext context,
    required String name,
    required String subtitle,
    required String avatarPath,
    required String semanticLabel,
    bool hasDeleteButton = false,
    VoidCallback? onDelete,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to doctor profile
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Avatar
              Container(
                width: ResponsiveHelper.getAvatarSize(context, isLarge: true),
                height: ResponsiveHelper.getAvatarSize(context, isLarge: true),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF5F6F7),
                  image: DecorationImage(
                    image: AssetImage(avatarPath),
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) {
                      // Fallback to icon if image fails to load
                    },
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: Color(0xFFCCD5DE),
                ),
              ),

              const SizedBox(width: 12),

              // Name and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveHelper.getHeadingFontSize(context),
                        fontWeight: FontWeight.w500,
                        color: _headingText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveHelper.getBodyFontSize(context),
                        color: _subtext,
                      ),
                    ),
                  ],
                ),
              ),

              // Delete button for appointments or chevron for regular doctors
              if (hasDeleteButton && onDelete != null)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFFE53935),
                    size: 20,
                  ),
                  onPressed: onDelete,
                  tooltip: 'Cancel appointment',
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _subtext,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Community section
  Widget _buildCommunitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'Community',
          style: GoogleFonts.inter(
            fontSize: ResponsiveHelper.getHeadingFontSize(context),
            fontWeight: FontWeight.w600,
            color: _headingText,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getItemSpacing(context)),

        // Community Post 1: Sophia Bennett
        _buildCommunityCard(
          context: context,
          name: 'Sophia Bennett',
          message: 'I\'m 12 weeks pregnant and experiencing nausea. Any tips?',
          timestamp: '2d ago',
          avatarPath: 'images/female_avatar1.png',
        ),

        SizedBox(height: ResponsiveHelper.getItemSpacing(context)),

        // Community Post 2: Olivia Hayes
        _buildCommunityCard(
          context: context,
          name: 'Olivia Hayes',
          message: 'Has anyone tried prenatal yoga? What are the benefits?',
          timestamp: '3d ago',
          avatarPath: 'images/female_avatar2.png',
        ),

        const SizedBox(height: 20),

        // Ask a Question Button
        _buildPrimaryButton(
          context: context,
          text: 'Ask a Question',
          onPressed: () {
            // TODO: Implement community question posting
          },
          semanticLabel: 'Ask a question in the community',
        ),
      ],
    );
  }

  /// Build individual community card
  Widget _buildCommunityCard({
    required BuildContext context,
    required String name,
    required String message,
    required String timestamp,
    required String avatarPath,
  }) {
    return Semantics(
      label: '$name asked: $message, $timestamp',
      button: true,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to community post detail
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: ResponsiveHelper.getAvatarSize(context),
                height: ResponsiveHelper.getAvatarSize(context),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF5F6F7),
                  image: DecorationImage(
                    image: AssetImage(avatarPath),
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) {
                      // Fallback to icon if image fails to load
                    },
                  ),
                ),
                // child: const Icon(
                //   Icons.person,
                //   size: 28,
                //   color: Color(0xFFCCD5DE),
                // ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveHelper.getBodyFontSize(context),
                        fontWeight: FontWeight.w500,
                        color: _headingText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Message
                    Text(
                      message,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveHelper.getBodyFontSize(context),
                        color: _subtext,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Timestamp
                    Text(
                      timestamp,
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveHelper.getSmallFontSize(context),
                        color: _timestampGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Settings & Account section
  Widget _buildSettingsSection(BuildContext context) {
    return Semantics(
      label: 'Settings and Account',
      button: true,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/settings-account');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Settings & Account',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveHelper.getHeadingFontSize(context),
                  fontWeight: FontWeight.w600,
                  color: _headingText,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _subtext,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build primary button (reusable)
  Widget _buildPrimaryButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    required String semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: SizedBox(
        width: double.infinity,
        height: ResponsiveHelper.getButtonHeight(context),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonRadius),
            ),
            elevation: 0,
          ),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: ResponsiveHelper.getHeadingFontSize(context),
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
