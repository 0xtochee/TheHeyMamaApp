import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/sign_in_constants.dart';
import '../services/auth_service.dart';
import '../services/secure_storage.dart';
import '../widgets/rounded_input_field.dart';

/// Sign In Screen
///
/// A pixel-perfect implementation of the sign-in design featuring:
/// - Rounded white card over soft blue background
/// - Email and password fields with validation
/// - "Remember me" checkbox
/// - Primary sign-in button with loading state
/// - Social sign-in options (Google, Apple)
/// - Comprehensive accessibility support
///
/// This screen is self-contained and does not navigate to other screens.
/// On successful sign-in, it returns true via Navigator.pop() or shows
/// a success message.
class SignInScreen extends StatefulWidget {
  /// Optional auth service for dependency injection (useful for testing)
  final AuthService? authService;

  const SignInScreen({
    super.key,
    this.authService,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading = false;

  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService.instance;
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Load saved email if "remember me" was previously checked
  Future<void> _loadSavedEmail() async {
    final savedEmail = await SecureStorage.instance.getUserEmail();
    final rememberFlag = await SecureStorage.instance.getRememberFlag();

    if (savedEmail != null && rememberFlag) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberMe = true;
      });
    }
  }

  /// Handle sign-in button press
  Future<void> _handleSignIn() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Show loading state
    setState(() => _isLoading = true);

    try {
      // Attempt sign-in
      final result = await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (result.success) {
        // Save authentication token and session info
        // Note: AuthService already stored email/name during sign-in
        if (result.token != null) {
          await SecureStorage.instance.saveAuthToken(result.token!);
        }

        // Save remember me preference
        await SecureStorage.instance.saveRememberFlag(_rememberMe);

        // Navigate to dashboard
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        // Show error message
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
      // Handle unexpected errors
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
      // Hide loading state
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handle social sign-in (Google or Apple)
  Future<void> _handleSocialSignIn(String provider) async {
    setState(() => _isLoading = true);

    try {
      late AuthResult result;

      if (provider == 'google') {
        result = await _authService.signInWithGoogle();
      } else if (provider == 'apple') {
        result = await _authService.signInWithApple();
      }

      if (!mounted) return;

      if (result.success) {
        if (result.token != null) {
          await SecureStorage.instance.saveAuthToken(result.token!);
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
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
      appBar: AppBar(
        backgroundColor: SignInConstants.pageBackgroundBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/onboarding');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: SignInConstants.cardHorizontalMargin,
              vertical: 24.0,
            ),
            child: _buildSignInCard(),
          ),
        ),
      ),
    );
  }

  /// Build the main white rounded card containing the sign-in form
  Widget _buildSignInCard() {
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
          _buildSignInForm(),
          const SizedBox(height: 16),
          _buildSignUpLink(),
          const SizedBox(height: SignInConstants.cardBottomPadding),
        ],
      ),
    );
  }

  /// Build the "Create Account" link
  Widget _buildSignUpLink() {
    return Center(
      child: TextButton(
        onPressed: _isLoading
            ? null
            : () {
                Navigator.pushNamed(context, '/sign-up');
              },
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 14,
              color: SignInConstants.textMuted,
            ),
            children: const [
              TextSpan(text: 'Don\'t have an account? '),
              TextSpan(
                text: 'Create Account',
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

  /// Build the logo at the top of the card
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
            // Fallback if logo image is not found
            return Container(
              width: SignInConstants.logoSize,
              height: SignInConstants.logoSize,
              decoration: BoxDecoration(
                color: SignInConstants.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.account_circle,
                size: 48,
                color: SignInConstants.primaryBlue,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build the header with title and subtitle
  Widget _buildHeaderText() {
    return Column(
      children: [
        Text(
          'Sign In',
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
          'Log in to access your account',
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

  /// Build the sign-in form with inputs and buttons
  Widget _buildSignInForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
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

          // Password field
          RoundedInputField(
            label: 'Password',
            placeholder: 'Enter your password',
            controller: _passwordController,
            isPassword: true,
            textInputAction: TextInputAction.done,
            semanticLabel: 'Password input',
            onFieldSubmitted: (_) => _handleSignIn(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (!_authService.isValidPassword(value)) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: SignInConstants.smallSpacing),

          // Remember me checkbox
          _buildRememberMeCheckbox(),
          const SizedBox(height: SignInConstants.sectionSpacing),

          // Sign in button
          _buildSignInButton(),
          const SizedBox(height: SignInConstants.sectionSpacing),

          // Divider with "or sign in with" text
          _buildDivider(),
          const SizedBox(height: SignInConstants.sectionSpacing),

          // Social sign-in buttons
          _buildSocialSignInButtons(),
        ],
      ),
    );
  }

  /// Build the "Remember me" checkbox
  Widget _buildRememberMeCheckbox() {
    return Semantics(
      label: 'Remember me checkbox',
      checked: _rememberMe,
      child: InkWell(
        onTap: _isLoading
            ? null
            : () {
                setState(() {
                  _rememberMe = !_rememberMe;
                });
              },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: SignInConstants.minTouchTarget,
                height: SignInConstants.minTouchTarget,
                child: Center(
                  child: SizedBox(
                    width: SignInConstants.checkboxSize,
                    height: SignInConstants.checkboxSize,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _rememberMe = value ?? false;
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
              Text(
                'Remember me',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: SignInConstants.textLabel,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the primary sign-in button
  Widget _buildSignInButton() {
    final isFormValid =
        _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

    return Semantics(
      label: 'Sign in button',
      button: true,
      enabled: !_isLoading && isFormValid,
      child: SizedBox(
        height: SignInConstants.buttonHeight,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSignIn,
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
                  'Sign In',
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

  /// Build the divider with "or sign in with" text
  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(
          child: Divider(
            color: SignInConstants.borderStroke,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'or sign in with',
            style: TextStyle(
              fontSize: SignInConstants.dividerTextSize,
              color: SignInConstants.textMuted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: SignInConstants.borderStroke,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  /// Build social sign-in buttons (Google and Apple)
  Widget _buildSocialSignInButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          label: 'Sign in with Google',
          icon: Icons.g_mobiledata,
          onTap: () => _handleSocialSignIn('google'),
        ),
        const SizedBox(width: SignInConstants.socialIconSpacing),
        _buildSocialButton(
          label: 'Sign in with Apple',
          icon: Icons.apple,
          onTap: () => _handleSocialSignIn('apple'),
        ),
      ],
    );
  }

  /// Build a single social sign-in button
  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: label,
      button: true,
      enabled: !_isLoading,
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(SignInConstants.socialIconRadius),
        child: Container(
          width: SignInConstants.socialIconSize,
          height: SignInConstants.socialIconSize,
          decoration: const BoxDecoration(
            color: SignInConstants.socialIconBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 28,
              color: SignInConstants.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
