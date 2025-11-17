import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'secure_storage.dart';

/// Authentication service for handling user sign-in
///
/// This is a STUB implementation for demonstration purposes.
/// TODO: Replace with real backend authentication (Firebase, REST API, etc.)
///
/// Current demo credentials:
/// - Email: demo@demo.com
/// - Password: password123
///
/// Registered users are stored in SharedPreferences (for demo only).
/// In production, all authentication would happen on the backend.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static AuthService get instance => _instance;
  final SecureStorage _storage = SecureStorage.instance;

  // Simulate network delay
  static const Duration _networkDelay = Duration(milliseconds: 1500);

  // SharedPreferences key for storing registered users
  static const String _usersKey = 'registered_users';

  /// Demo credentials for testing
  static const String _demoEmail = 'demo@demo.com';
  static const String _demoPassword = 'password123';

  /// Get all registered users from SharedPreferences
  Future<Map<String, Map<String, String>>> _getRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return {};

    final Map<String, dynamic> decoded = jsonDecode(usersJson);
    return decoded
        .map((key, value) => MapEntry(key, Map<String, String>.from(value)));
  }

  /// Save a new registered user to SharedPreferences
  Future<void> _saveRegisteredUser(
      String email, String password, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _getRegisteredUsers();

    users[email.toLowerCase()] = {
      'password': password,
      'name': name,
    };

    await prefs.setString(_usersKey, jsonEncode(users));
  }

  /// Sign in with email and password
  ///
  /// Returns true if authentication successful, false otherwise.
  ///
  /// TODO: Connect to real backend API
  /// - Send POST request to /auth/login endpoint
  /// - Validate response and extract auth token
  /// - Handle network errors and timeouts
  /// - Implement proper error messages
  ///
  /// Example backend integration:
  /// ```dart
  /// final response = await http.post(
  ///   Uri.parse('https://api.example.com/auth/login'),
  ///   headers: {'Content-Type': 'application/json'},
  ///   body: jsonEncode({'email': email, 'password': password}),
  /// );
  /// if (response.statusCode == 200) {
  ///   final data = jsonDecode(response.body);
  ///   return AuthResult(success: true, token: data['token']);
  /// }
  /// ```
  Future<AuthResult> signInWithEmail(String email, String password) async {
    // Simulate network request delay
    await Future.delayed(_networkDelay);

    // Demo authentication logic
    // In production, this would call your backend API

    final emailLower = email.trim().toLowerCase();

    // First check if it's the demo account
    if (emailLower == _demoEmail && password == _demoPassword) {
      // Store current user info in secure storage for session
      await _storage.saveUserEmail(email);
      await _storage.saveUserName('Demo User');

      return AuthResult(
        success: true,
        token: 'demo_auth_token_${DateTime.now().millisecondsSinceEpoch}',
        message: 'Sign in successful',
      );
    }

    // Check registered users from SharedPreferences
    final users = await _getRegisteredUsers();
    final userData = users[emailLower];

    if (userData != null && userData['password'] == password) {
      // Store current user info in secure storage for session
      await _storage.saveUserEmail(email);
      await _storage.saveUserName(userData['name'] ?? 'User');

      return AuthResult(
        success: true,
        token: 'user_auth_token_${DateTime.now().millisecondsSinceEpoch}',
        message: 'Sign in successful',
      );
    }

    // Invalid credentials
    return AuthResult(
      success: false,
      message: 'Invalid email or password',
    );
  }

  /// Sign in with Google
  ///
  /// TODO: Implement Google Sign-In
  /// - Add google_sign_in package dependency
  /// - Configure OAuth credentials in Firebase/Google Cloud Console
  /// - Handle sign-in flow and token exchange
  ///
  /// Example implementation:
  /// ```dart
  /// final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  /// final GoogleSignInAuthentication? googleAuth =
  ///     await googleUser?.authentication;
  /// // Send googleAuth.idToken to backend for verification
  /// ```
  Future<AuthResult> signInWithGoogle() async {
    // Simulate network request delay
    await Future.delayed(_networkDelay);

    // Stub implementation
    // In production, this would trigger Google Sign-In flow
    return AuthResult(
      success: true,
      token: 'google_auth_token_${DateTime.now().millisecondsSinceEpoch}',
      message: 'Google sign in successful (demo)',
    );
  }

  /// Sign in with Apple
  ///
  /// TODO: Implement Apple Sign-In
  /// - Add sign_in_with_apple package dependency
  /// - Configure Apple Sign-In in Apple Developer Console
  /// - Handle sign-in flow and token exchange
  ///
  /// Example implementation:
  /// ```dart
  /// final credential = await SignInWithApple.getAppleIDCredential(
  ///   scopes: [
  ///     AppleIDAuthorizationScopes.email,
  ///     AppleIDAuthorizationScopes.fullName,
  ///   ],
  /// );
  /// // Send credential.identityToken to backend for verification
  /// ```
  Future<AuthResult> signInWithApple() async {
    // Simulate network request delay
    await Future.delayed(_networkDelay);

    // Stub implementation
    // In production, this would trigger Apple Sign-In flow
    return AuthResult(
      success: true,
      token: 'apple_auth_token_${DateTime.now().millisecondsSinceEpoch}',
      message: 'Apple sign in successful (demo)',
    );
  }

  /// Validate email format
  ///
  /// Simple email validation using regex.
  /// For production, consider more robust validation.
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Validate password strength
  ///
  /// Current rules: minimum 6 characters
  /// TODO: Implement stronger password requirements:
  /// - At least 8 characters
  /// - Contains uppercase and lowercase
  /// - Contains numbers
  /// - Contains special characters
  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Sign up / Create new account
  ///
  /// TODO: Connect to real backend registration API
  /// - Send POST request to /auth/register endpoint
  /// - Validate unique email
  /// - Hash password on backend
  /// - Send verification email
  /// - Return auth token after successful registration
  ///
  /// Example backend integration:
  /// ```dart
  /// final response = await http.post(
  ///   Uri.parse('https://api.example.com/auth/register'),
  ///   headers: {'Content-Type': 'application/json'},
  ///   body: jsonEncode({
  ///     'name': name,
  ///     'email': email,
  ///     'password': password,
  ///   }),
  /// );
  /// if (response.statusCode == 201) {
  ///   final data = jsonDecode(response.body);
  ///   return AuthResult(success: true, token: data['token']);
  /// }
  /// ```
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // Simulate network request delay
    await Future.delayed(_networkDelay);

    // Check if email already exists
    final users = await _getRegisteredUsers();
    final emailLower = email.trim().toLowerCase();

    if (users.containsKey(emailLower)) {
      return AuthResult(
        success: false,
        message: 'An account with this email already exists',
      );
    }

    // Save new user to SharedPreferences
    await _saveRegisteredUser(emailLower, password, name);

    // Store current user info in secure storage for session
    await _storage.saveUserEmail(email);
    await _storage.saveUserName(name);

    // In production, this would call your backend registration API
    return AuthResult(
      success: true,
      token: 'new_user_token_${DateTime.now().millisecondsSinceEpoch}',
      message: 'Account created successfully! Welcome, $name!',
    );
  }

  /// Clear all registered users (for testing/development only)
  /// WARNING: This deletes all user accounts from local storage
  Future<void> clearAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await _storage.clearAll();
  }
}

/// Authentication result model
///
/// Contains the result of an authentication attempt
/// including success status, optional auth token, and message.
class AuthResult {
  final bool success;
  final String? token;
  final String message;

  AuthResult({
    required this.success,
    this.token,
    required this.message,
  });
}
