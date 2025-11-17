import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

/// Reusable card widget for displaying vital signs
///
/// Displays an icon, value, and label in a tappable card format.
/// Used for Blood Pressure and Heart Rate on the dashboard.
class VitalCard extends StatelessWidget {
  final String iconPath;
  final String value;
  final String label;
  final VoidCallback? onTap;
  final List<Color>? gradientColors;

  const VitalCard({
    super.key,
    required this.iconPath,
    required this.value,
    required this.label,
    this.onTap,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradient = [
      const Color(0xFFE3F2FD),
      const Color(0xFFBBDEFB),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (gradientColors?.first ?? defaultGradient.first).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Semantics(
            button: true,
            label: '\$label: \$value',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Full card image with gradient overlay
                  Positioned.fill(
                    child: Image.asset(
                      iconPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback gradient if asset is missing
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors ?? defaultGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.favorite,
                              size: 64,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Gradient overlay for better text readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.black.withOpacity(0.3),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                  // Content positioned at bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context) * 0.8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Value with larger, bolder font
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getTitleFontSize(context) + 4,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                          SizedBox(height: ResponsiveHelper.isMobile(context) ? 4 : 8),
                          // Label with subtle styling - more responsive
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // Use smaller font on very narrow screens
                              final fontSize = constraints.maxWidth < 150
                                  ? ResponsiveHelper.getBodyFontSize(context) - 2
                                  : ResponsiveHelper.getBodyFontSize(context);

                              return Text(
                                label,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.2,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.visible,
                                softWrap: true,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
