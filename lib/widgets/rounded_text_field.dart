import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/ui_constants.dart';

/// Reusable rounded text field with validation and accessibility support
///
/// A customizable text input field with:
/// - Rounded border design matching app style
/// - Built-in validation support
/// - Accessibility labels
/// - Optional prefix/suffix icons
/// - Keyboard type configuration
/// - Input formatters support
class RoundedTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? semanticLabel;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final double? height;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;

  const RoundedTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.semanticLabel,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.height,
    this.onTap,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      onTap: onTap,
      textInputAction: textInputAction,
      focusNode: focusNode,
      autofocus: autofocus,
      style: AppTextStyles.body1.copyWith(
        color: enabled ? AppColors.headingText : AppColors.subtleText,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelStyle: AppTextStyles.label,
        hintStyle: AppTextStyles.body1.copyWith(
          color: AppColors.subtleText,
        ),
        // Border styling
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.stroke,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.stroke,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.activeBlue,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: BorderSide(
            color: AppColors.stroke.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        // Padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.inputPadding,
          vertical: AppDimensions.inputPadding,
        ),
        // Ensure proper height
        isDense: false,
        // Error styling
        errorStyle: const TextStyle(
          color: AppColors.errorRed,
          fontSize: 12,
          height: 1.2,
        ),
        errorMaxLines: 2,
      ),
    );

    // Wrap in Semantics for accessibility
    final semanticWidget = Semantics(
      label: semanticLabel ?? labelText ?? hintText,
      textField: true,
      enabled: enabled,
      child: field,
    );

    // Wrap in SizedBox if height is specified
    if (height != null) {
      return SizedBox(
        height: height,
        child: semanticWidget,
      );
    }

    return semanticWidget;
  }
}

/// Numeric text field variant with built-in number validation
class NumericTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? semanticLabel;
  final double? minValue;
  final double? maxValue;
  final bool allowDecimals;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final bool enabled;
  final String? unit;

  const NumericTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.semanticLabel,
    this.minValue,
    this.maxValue,
    this.allowDecimals = false,
    this.onChanged,
    this.suffixIcon,
    this.enabled = true,
    this.unit,
  });

  String? _validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (minValue != null && number < minValue!) {
      return 'Value must be at least ${minValue!.toStringAsFixed(allowDecimals ? 1 : 0)}';
    }

    if (maxValue != null && number > maxValue!) {
      return 'Value must be at most ${maxValue!.toStringAsFixed(allowDecimals ? 1 : 0)}';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return RoundedTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      semanticLabel: semanticLabel,
      keyboardType: TextInputType.numberWithOptions(
        decimal: allowDecimals,
        signed: false,
      ),
      inputFormatters: [
        if (allowDecimals)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      validator: _validate,
      onChanged: onChanged,
      suffixIcon: unit != null
          ? Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                widthFactor: 1.0,
                child: Text(
                  unit!,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.subtleText,
                  ),
                ),
              ),
            )
          : suffixIcon,
      enabled: enabled,
    );
  }
}
