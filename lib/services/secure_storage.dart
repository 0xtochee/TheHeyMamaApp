import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for persisting sensitive data
///
/// Wraps flutter_secure_storage to provide a simple interface
/// for storing authentication tokens, user preferences, and
/// sensitive data like "remember me" flags.
///
/// Data is encrypted and stored in platform-specific secure storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences
/// - Windows: Windows Credential Store
class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  static SecureStorage get instance => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Storage keys
  static const String _rememberMeKey = 'remember_me';
  static const String _authTokenKey = 'auth_token';
  static const String _userEmailKey = 'user_email';
  static const String _userPasswordKey = 'user_password';
  static const String _userNameKey = 'user_name';

  /// Save the "remember me" flag
  ///
  /// When true, the app will persist the user's authentication
  /// and automatically sign them in on next launch.
  Future<void> saveRememberFlag(bool remember) async {
    await _storage.write(
      key: _rememberMeKey,
      value: remember.toString(),
    );
  }

  /// Get the "remember me" flag
  ///
  /// Returns true if the user previously checked "remember me",
  /// false otherwise.
  Future<bool> getRememberFlag() async {
    final value = await _storage.read(key: _rememberMeKey);
    return value == 'true';
  }

  /// Save authentication token
  ///
  /// TODO: Connect to real backend authentication system.
  /// This is a stub for demonstration purposes.
  Future<void> saveAuthToken(String token) async {
    await _storage.write(
      key: _authTokenKey,
      value: token,
    );
  }

  /// Get authentication token
  ///
  /// Returns null if no token is stored.
  Future<String?> getAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  /// Save user email for current session
  /// This is the email of the currently logged-in user
  Future<void> saveUserEmail(String email) async {
    await _storage.write(
      key: _userEmailKey,
      value: email,
    );
  }

  /// Get saved user email for current session
  ///
  /// Returns null if no email is stored.
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  /// Save user password for current session (for auto-fill only)
  /// WARNING: In production, never store passwords locally.
  /// This is for demo purposes only.
  Future<void> saveUserPassword(String password) async {
    await _storage.write(
      key: _userPasswordKey,
      value: password,
    );
  }

  /// Get saved user password for current session
  /// WARNING: In production, never store passwords locally.
  /// Returns null if no password is stored.
  Future<String?> getUserPassword() async {
    return await _storage.read(key: _userPasswordKey);
  }

  /// Save user name
  Future<void> saveUserName(String name) async {
    await _storage.write(
      key: _userNameKey,
      value: name,
    );
  }

  /// Get saved user name
  ///
  /// Returns null if no name is stored.
  Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  /// Clear authentication session data (logout)
  ///
  /// Clears the auth token and remember flag, but keeps
  /// user credentials stored for future logins.
  Future<void> clearAuthData() async {
    await _storage.delete(key: _authTokenKey);
    await _storage.delete(key: _rememberMeKey);
    // Note: We keep email, password, and name stored so user can login again
  }

  /// Clear all user data including credentials
  ///
  /// Use this when user wants to completely remove their account data.
  Future<void> clearUserCredentials() async {
    await _storage.delete(key: _authTokenKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userPasswordKey);
    await _storage.delete(key: _userNameKey);
    await _storage.delete(key: _rememberMeKey);
  }

  /// Clear all data from secure storage
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
