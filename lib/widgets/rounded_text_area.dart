import 'package:flutter/material.dart';

/// A large rounded multiline text input area for notes
///
/// Features:
/// - Rounded corners (12px radius)
/// - Subtle border styling (#E6E9EE)
/// - Minimum height of 140px
/// - Multiline support with keyboard expansion
/// - Placeholder text
/// - Accessible with semantic labels
/// - Focus state styling
class RoundedTextArea extends StatelessWidget {
  /// Controller for the text field
  final TextEditingController controller;

  /// Placeholder text when empty
  final String placeholder;

  /// Label displayed above the text area
  final String? label;

  /// Minimum height of the text area
  final double minHeight;

  /// Maximum lines (null for unlimited)
  final int? maxLines;

  /// Maximum length (null for unlimited)
  final int? maxLength;

  /// Callback when text changes
  final ValueChanged<String>? onChanged;

  /// Focus node for managing focus state
  final FocusNode? focusNode;

  /// Whether the text area is enabled
  final bool enabled;

  /// Semantic label for accessibility
  final String? semanticsLabel;

  const RoundedTextArea({
    super.key,
    required this.controller,
    this.placeholder = 'Add any notes...',
    this.label,
    this.minHeight = 140.0,
    this.maxLines = null,
    this.maxLength,
    this.onChanged,
    this.focusNode,
    this.enabled = true,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2332),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Text area
        Semantics(
          label: semanticsLabel ?? label ?? 'Notes text area',
          textField: true,
          child: Container(
            constraints: BoxConstraints(
              minHeight: minHeight,
            ),
            decoration: BoxDecoration(
              color: enabled ? Colors.white : const Color(0xFFF7FAFC),
              border: Border.all(
                color: const Color(0xFFE6E9EE),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              maxLines: maxLines,
              maxLength: maxLength,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1A2332),
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF4A5568).withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterText: maxLength != null ? null : '', // Hide counter if no max
              ),
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
            ),
          ),
        ),
      ],
    );
  }
}

/// A variant with character count display
class RoundedTextAreaWithCounter extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final String? label;
  final double minHeight;
  final int maxLength;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool enabled;
  final String? semanticsLabel;

  const RoundedTextAreaWithCounter({
    super.key,
    required this.controller,
    required this.maxLength,
    this.placeholder = 'Add any notes...',
    this.label,
    this.minHeight = 140.0,
    this.onChanged,
    this.focusNode,
    this.enabled = true,
    this.semanticsLabel,
  });

  @override
  State<RoundedTextAreaWithCounter> createState() =>
      _RoundedTextAreaWithCounterState();
}

class _RoundedTextAreaWithCounterState
    extends State<RoundedTextAreaWithCounter> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Rebuild to update counter
  }

  @override
  Widget build(BuildContext context) {
    final currentLength = widget.controller.text.length;
    final isNearLimit = currentLength > widget.maxLength * 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoundedTextArea(
          controller: widget.controller,
          placeholder: widget.placeholder,
          label: widget.label,
          minHeight: widget.minHeight,
          maxLength: null, // Don't show built-in counter
          onChanged: widget.onChanged,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          semanticsLabel: widget.semanticsLabel,
        ),
        const SizedBox(height: 8),

        // Custom character counter
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$currentLength / ${widget.maxLength}',
            style: TextStyle(
              fontSize: 14,
              color: isNearLimit
                  ? const Color(0xFFE53E3E)
                  : const Color(0xFF718096),
            ),
          ),
        ),
      ],
    );
  }
}
