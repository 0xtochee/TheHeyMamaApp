import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/sign_in_constants.dart';

/// Reusable rounded text input field widget for forms
///
/// Features:
/// - Customizable label, placeholder, and validation
/// - Password field support with show/hide toggle
/// - Pixel-perfect styling matching design specifications
/// - Accessibility support with semantic labels
/// - Focus state with color change
class RoundedInputField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool enabled;
  final String? semanticLabel;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;

  const RoundedInputField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.enabled = true,
    this.semanticLabel,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<RoundedInputField> createState() => _RoundedInputFieldState();
}

class _RoundedInputFieldState extends State<RoundedInputField> {
  bool _obscureText = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(
            bottom: 8.0,
            left: 4.0,
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: SignInConstants.labelFontSize,
              fontWeight: SignInConstants.labelWeight,
              color: SignInConstants.textLabel,
            ),
          ),
        ),

        // Text Field
        Semantics(
          label: widget.semanticLabel ?? widget.label,
          textField: true,
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            obscureText: _obscureText && widget.isPassword,
            enabled: widget.enabled,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            style: GoogleFonts.inter(
              fontSize: SignInConstants.inputFontSize,
              color: SignInConstants.textDark,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: GoogleFonts.inter(
                fontSize: SignInConstants.inputFontSize,
                color: SignInConstants.textPlaceholder,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: SignInConstants.cardBackground,
              contentPadding: const EdgeInsets.symmetric(
                vertical: SignInConstants.inputVerticalPadding,
                horizontal: SignInConstants.inputHorizontalPadding,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  SignInConstants.inputBorderRadius,
                ),
                borderSide: const BorderSide(
                  color: SignInConstants.borderStroke,
                  width: SignInConstants.inputBorderWidth,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  SignInConstants.inputBorderRadius,
                ),
                borderSide: const BorderSide(
                  color: SignInConstants.borderStroke,
                  width: SignInConstants.inputBorderWidth,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  SignInConstants.inputBorderRadius,
                ),
                borderSide: const BorderSide(
                  color: SignInConstants.borderFocused,
                  width: SignInConstants.inputBorderWidth,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  SignInConstants.inputBorderRadius,
                ),
                borderSide: const BorderSide(
                  color: SignInConstants.errorColor,
                  width: SignInConstants.inputBorderWidth,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  SignInConstants.inputBorderRadius,
                ),
                borderSide: const BorderSide(
                  color: SignInConstants.errorColor,
                  width: SignInConstants.inputBorderWidth,
                ),
              ),
              errorStyle: GoogleFonts.inter(
                fontSize: 12.0,
                color: SignInConstants.errorColor,
                height: 1.3,
              ),
              // Password visibility toggle
              suffixIcon: widget.isPassword
                  ? Semantics(
                      label: _obscureText ? 'Show password' : 'Hide password',
                      button: true,
                      child: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: SignInConstants.textMuted,
                          size: 20.0,
                        ),
                        onPressed: _togglePasswordVisibility,
                        splashRadius: 20.0,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
