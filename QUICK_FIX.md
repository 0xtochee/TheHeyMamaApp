# 🔧 Quick Fix for Splash Screen Issue

## Issue
The splash screen (InitialScreen) is stuck loading and not navigating to onboarding.

## Cause
The `flutter_secure_storage` package might be causing the navigation to hang on Windows during initialization.

## Solution Applied

Added error handling to InitialScreen to catch any secure storage issues:

```dart
try {
  rememberMe = await SecureStorage.instance.getRememberFlag();
  hasToken = await SecureStorage.instance.getAuthToken();
} catch (e) {
  // Secure storage might not be available - gracefully fallback
  print('Secure storage error: $e');
}
```

## How to Test

1. **Stop the current app** (if running)
2. **Run with hot restart:**
   ```bash
   # Press 'R' in the terminal where flutter run is active
   # Or stop and restart:
   flutter run -d windows
   ```

3. **Expected flow:**
   - Splash screen shows for 0.5 seconds
   - Automatically navigates to Onboarding (4 slides)
   - Skip or go through slides
   - Sign in screen appears
   - Sign in with demo@demo.com / password123
   - Dashboard loads

## If Still Stuck

Try clearing app data and restarting:

```bash
# Option 1: Full clean rebuild
flutter clean
flutter pub get
flutter run -d windows

# Option 2: Delete app data manually
# Go to Windows Settings > Apps > Pregnancy Dashboard > Advanced options > Reset
```

## Alternative: Simplify for Testing

If you want to skip directly to a specific screen for testing, temporarily change main.dart:

```dart
// In main.dart, line 72, change:
home: const InitialScreen(),

// To one of:
home: const OnboardingScreen(),      // Test onboarding
home: const SignInScreen(),          // Test sign-in
home: const PregnancyDashboardScreen(), // Test dashboard
```

## Debug Info

The InitialScreen now logs navigation info to console. Watch for:
- "Secure storage error: ..." - indicates storage issue
- "Navigation error: ..." - indicates navigation problem

Check the console output when the app runs for these messages.
