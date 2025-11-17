import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../services/auth_service.dart';
import '../services/secure_storage.dart';

/// Development utilities for testing and debugging
/// WARNING: These methods are for development only and should not be used in production
class DevUtils {
  /// Clear all user data including:
  /// - All registered users from SharedPreferences
  /// - Current session from SecureStorage
  /// - All database data (vitals, symptoms, reminders, appointments)
  static Future<void> clearAllData() async {
    try {
      // 1. Clear registered users and auth data
      await AuthService.instance.clearAllUsers();
      print('✓ Cleared all registered users');

      // 2. Clear secure storage
      await SecureStorage.instance.clearAll();
      print('✓ Cleared secure storage');

      // 3. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✓ Cleared SharedPreferences');

      // 4. Delete database file
      try {
        final documentsDirectory = await getApplicationDocumentsDirectory();
        final dbPath = join(documentsDirectory.path, 'pregnancy_vitals.db');
        await deleteDatabase(dbPath);
        print('✓ Deleted database file');
      } catch (e) {
        print('⚠ Could not delete database file (may not exist): $e');
      }

      print('\n✅ All data cleared successfully!');
      print('You can now create new users and test the app with fresh data.');
    } catch (e) {
      print('❌ Error clearing data: $e');
      rethrow;
    }
  }

  /// Print all registered users (for debugging)
  static Future<void> printRegisteredUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('registered_users');

      if (usersJson == null) {
        print('No registered users found');
        return;
      }

      print('Registered users:');
      print(usersJson);
    } catch (e) {
      print('Error reading registered users: $e');
    }
  }
}
