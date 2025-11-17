import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/sign_in_constants.dart';
import '../services/auth_service.dart';
import '../services/secure_storage.dart';
import '../widgets/rounded_input_field.dart';

/// Sign Up / Create Account Screen
///
/// Allows new users to create an account with:
/// - Full name
/// - Email address
/// - Password (with confirmation)
/// - Terms & conditions acceptance
class SignUpScreen extends StatefulWidget {
  final AuthService? authService;

  const SignUpScreen({
    super.key,
    this.authService,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptedTerms = false;
  bool _isLoading = false;

  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService.instance;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: SignInConstants.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final result = await _authService.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result.success) {
        // Save authentication token and current user session info
        if (result.token != null) {
          await SecureStorage.instance.saveAuthToken(result.token!);
        }
        // Note: User credentials are already stored in AuthService during signUp
        // Only store current session info in SecureStorage

        // Navigate to user details screen to complete profile
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/user-details');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: SignInConstants.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: SignInConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SignInConstants.pageBackgroundBlue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: SignInConstants.cardHorizontalMargin,
              vertical: 24.0,
            ),
            child: _buildSignUpCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpCard() {
    return Container(
      decoration: BoxDecoration(
        color: SignInConstants.cardBackground,
        borderRadius: BorderRadius.circular(
          SignInConstants.cardBorderRadius,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: SignInConstants.cardSidePadding,
        vertical: SignInConstants.cardTopPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLogo(),
          const SizedBox(height: 32),
          _buildHeaderText(),
          const SizedBox(height: SignInConstants.sectionSpacing),
          _buildSignUpForm(),
          const SizedBox(height: 16),
          _buildSignInLink(),
          const SizedBox(height: SignInConstants.cardBottomPadding),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Semantics(
      label: 'App logo',
      image: true,
      child: Center(
        child: Image.asset(
          'assets/images/sign-in-logo.png',
          width: SignInConstants.logoSize,
          height: SignInConstants.logoSize,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: SignInConstants.logoSize,
              height: SignInConstants.logoSize,
              decoration: BoxDecoration(
                color: SignInConstants.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person_add,
                size: 48,
                color: SignInConstants.primaryBlue,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      children: [
        Text(
          'Create Account',
          style: GoogleFonts.inter(
            fontSize: SignInConstants.titleFontSize,
            fontWeight: SignInConstants.titleWeight,
            color: SignInConstants.textDark,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Sign up to get started',
          style: GoogleFonts.inter(
            fontSize: SignInConstants.subtitleFontSize,
            fontWeight: SignInConstants.subtitleWeight,
            color: SignInConstants.textMuted,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full Name
          RoundedInputField(
            label: 'Full Name',
            placeholder: 'Enter your full name',
            controller: _nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            semanticLabel: 'Full name input',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: SignInConstants.inputSpacing),

          // Email
          RoundedInputField(
            label: 'Email',
            placeholder: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            semanticLabel: 'Email address input',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!_authService.isValidEmail(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: SignInConstants.inputSpacing),

          // Password
          RoundedInputField(
            label: 'Password',
            placeholder: 'Create a password',
            controller: _passwordController,
            isPassword: true,
            textInputAction: TextInputAction.next,
            semanticLabel: 'Password input',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (!value.contains(RegExp(r'[A-Z]'))) {
                return 'Password must contain an uppercase letter';
              }
              if (!value.contains(RegExp(r'[a-z]'))) {
                return 'Password must contain a lowercase letter';
              }
              if (!value.contains(RegExp(r'[0-9]'))) {
                return 'Password must contain a number';
              }
              return null;
            },
          ),
          const SizedBox(height: SignInConstants.inputSpacing),

          // Confirm Password
          RoundedInputField(
            label: 'Confirm Password',
            placeholder: 'Re-enter your password',
            controller: _confirmPasswordController,
            isPassword: true,
            textInputAction: TextInputAction.done,
            semanticLabel: 'Confirm password input',
            onFieldSubmitted: (_) => _handleSignUp(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: SignInConstants.smallSpacing),

          // Terms & Conditions
          _buildTermsCheckbox(),
          const SizedBox(height: SignInConstants.sectionSpacing),

          // Sign Up Button
          _buildSignUpButton(),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Semantics(
      label: 'Accept terms and conditions checkbox',
      checked: _acceptedTerms,
      child: InkWell(
        onTap: _isLoading
            ? null
            : () {
                setState(() {
                  _acceptedTerms = !_acceptedTerms;
                });
              },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: SignInConstants.minTouchTarget,
                height: SignInConstants.minTouchTarget,
                child: Center(
                  child: SizedBox(
                    width: SignInConstants.checkboxSize,
                    height: SignInConstants.checkboxSize,
                    child: Checkbox(
                      value: _acceptedTerms,
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _acceptedTerms = value ?? false;
                              });
                            },
                      activeColor: SignInConstants.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: SignInConstants.textLabel,
                        fontWeight: FontWeight.w400,
                      ),
                      children: const [
                        TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TextStyle(
                            color: SignInConstants.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: SignInConstants.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Semantics(
      label: 'Create account button',
      button: true,
      enabled: !_isLoading,
      child: SizedBox(
        height: SignInConstants.buttonHeight,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSignUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: SignInConstants.accentBlue,
            disabledBackgroundColor:
                SignInConstants.accentBlue.withOpacity(0.5),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                SignInConstants.buttonBorderRadius,
              ),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Create Account',
                  style: GoogleFonts.inter(
                    fontSize: SignInConstants.buttonFontSize,
                    fontWeight: SignInConstants.buttonWeight,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Center(
      child: TextButton(
        onPressed: _isLoading
            ? null
            : () {
                Navigator.pop(context);
              },
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 14,
              color: SignInConstants.textMuted,
            ),
            children: const [
              TextSpan(text: 'Already have an account? '),
              TextSpan(
                text: 'Sign In',
                style: TextStyle(
                  color: SignInConstants.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
