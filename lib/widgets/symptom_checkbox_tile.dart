import 'package:flutter/material.dart';

/// A reusable checkbox tile widget for symptom selection
///
/// Features:
/// - Checkbox on left, label on right
/// - Touch target of 48-56px height for accessibility
/// - Rounded border with subtle styling
/// - Semantic labeling for screen readers
/// - Smooth check/uncheck animations
/// - Keyboard accessible
class SymptomCheckboxTile extends StatelessWidget {
  /// The symptom name to display
  final String symptom;

  /// Whether this symptom is currently selected
  final bool isSelected;

  /// Callback when the selection state changes
  final ValueChanged<bool> onChanged;

  /// Optional semantic label (defaults to "Select {symptom}")
  final String? semanticsLabel;

  /// Optional icon to display (emoji or IconData)
  final Widget? icon;

  const SymptomCheckboxTile({
    Key? key,
    required this.symptom,
    required this.isSelected,
    required this.onChanged,
    this.semanticsLabel,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? 'Select $symptom',
      checked: isSelected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!isSelected),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0D79FF)
                    : const Color(0xFFE6E9EE),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected
                  ? const Color(0xFF0D79FF).withOpacity(0.05)
                  : Colors.white,
            ),
            child: Row(
              children: [
                // Checkbox
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (value) => onChanged(value ?? false),
                    activeColor: const Color(0xFF0D79FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 12),

                // Optional icon
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],

                // Label
                Expanded(
                  child: Text(
                    symptom,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? const Color(0xFF1A2332)
                          : const Color(0xFF4A5568),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A variant with emoji icon support
class SymptomCheckboxTileWithEmoji extends StatelessWidget {
  final String symptom;
  final String emoji;
  final bool isSelected;
  final ValueChanged<bool> onChanged;
  final String? semanticsLabel;

  const SymptomCheckboxTileWithEmoji({
    Key? key,
    required this.symptom,
    required this.emoji,
    required this.isSelected,
    required this.onChanged,
    this.semanticsLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SymptomCheckboxTile(
      symptom: symptom,
      isSelected: isSelected,
      onChanged: onChanged,
      semanticsLabel: semanticsLabel,
      icon: Text(
        emoji,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
