import 'package:flutter/material.dart';

/// Reusable segmented control widget for selecting between multiple options
///
/// Features:
/// - Customizable options list
/// - Selected state with primary color fill
/// - Unselected state with outline
/// - Accessible with semantic labels
/// - Smooth transitions
class SegmentedChoice extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final Color? borderColor;
  final double? height;
  final double? borderRadius;

  const SegmentedChoice({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.borderColor,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? const Color(0xFF1E88E5);
    final effectiveUnselectedColor = unselectedColor ?? Colors.white;
    final effectiveSelectedTextColor = selectedTextColor ?? Colors.white;
    final effectiveUnselectedTextColor =
        unselectedTextColor ?? const Color(0xFF5B6B7A);
    final effectiveBorderColor = borderColor ?? const Color(0xFFE6E9EE);
    final effectiveHeight = height ?? 40.0;
    final effectiveBorderRadius = borderRadius ?? 12.0;

    return Row(
      children: List.generate(options.length, (index) {
        final isSelected = index == selectedIndex;
        final isLast = index == options.length - 1;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: isLast ? 0 : 12,
            ),
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: Semantics(
                label: '${options[index]} ${isSelected ? 'selected' : ''}',
                button: true,
                selected: isSelected,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: effectiveHeight,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? effectiveSelectedColor
                        : effectiveUnselectedColor,
                    borderRadius: BorderRadius.circular(effectiveBorderRadius),
                    border: Border.all(
                      color: isSelected
                          ? effectiveSelectedColor
                          : effectiveBorderColor,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    options[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? effectiveSelectedTextColor
                          : effectiveUnselectedTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
