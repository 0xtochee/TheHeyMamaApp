# Troubleshooting: Vitals Not Saving

This guide helps diagnose and fix issues when vitals cannot be saved in the Pregnancy Dashboard app.

## Quick Diagnostic Steps

### Step 1: Check Your Platform

The issue might vary based on platform:

- **Web**: SQLite doesn't work on web - app should auto-fallback to SharedPreferences
- **Android/iOS**: Requires proper permissions for file storage
- **Desktop (Windows/macOS/Linux)**: Should work with SQLite

### Step 2: Check Console for Errors

When you tap "Save Vitals", check your debug console for error messages:

```bash
# Run app with verbose logging
flutter run -v
```

Look for messages like:
- `[LocalDatabase] Failed to initialize database:`
- `[LocalDatabase] SQLite insert failed, using SharedPreferences fallback:`
- `Failed to add vital record:`

### Step 3: Verify Form Validation

The form requires these fields to be filled:
- **Weight**: 20-300 kg
- **Systolic BP**: 50-250 mmHg
- **Diastolic BP**: 30-150 mmHg
- **Heart Rate**: 30-220 bpm
- **Date**: Required
- **Time**: Required

If validation fails, you'll see: "Please correct the errors in the form"

## Common Issues & Solutions

### Issue 1: "Nothing happens when I tap Save Vitals"

**Cause**: Form validation is failing silently

**Solution**: Check each field has valid values within the ranges above

**Debug**: Add this to check validation state:
1. Before tapping Save, ensure all fields have values
2. Look for red error text under any fields
3. Make sure date and time are selected

### Issue 2: "Error saving vitals" message appears

**Cause**: Database save failed

**Solution**:
1. Check file permissions (Android/iOS)
2. Verify provider is initialized
3. Check console logs for specific error

**Quick Fix**: The app should automatically fall back to SharedPreferences. If you're seeing this repeatedly:

```dart
// In lib/services/local_db.dart, the fallback should work automatically
// Check console for: "SQLite insert failed, using SharedPreferences fallback"
```

### Issue 3: Web Platform - Vitals not persisting

**Cause**: SQLite doesn't work on web

**Solution**: This is expected! The app uses SharedPreferences on web.

**Verify**:
1. Open browser DevTools → Application → Local Storage
2. Check for `flutter.vitals_fallback` key
3. You should see JSON data there

### Issue 4: App crashes when saving

**Cause**: Missing dependencies or provider not initialized

**Solution**:

1. **Verify dependencies are installed:**
```bash
cd pregnancy_dashboard
flutter pub get
```

2. **Check main.dart has provider:**
```dart
// Should see this in main.dart
ChangeNotifierProvider(
  create: (_) => VitalsProvider()..initialize(),
  child: MaterialApp(...)
)
```

3. **If still crashing, check stack trace for specifics**

### Issue 5: Vitals save but don't appear on dashboard

**Cause**: Dashboard not refreshing after save

**Solution**: Check the navigation handler in pregnancy_dashboard_screen.dart:

```dart
void _handleLogVital() async {
  final result = await Navigator.pushNamed(context, '/add-vitals');

  // This should refresh the vitals
  if (result != null && mounted) {
    context.read<VitalsProvider>().loadLatestVitals();
  }
}
```

## Platform-Specific Issues

### Android

**Permissions**: Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**Note**: On Android 11+, these may not be needed due to scoped storage.

### iOS

**Permissions**: Should work out of the box, but if issues persist, check `ios/Runner/Info.plist`

### Web

**Expected Behavior**:
- SQLite will always fail (expected)
- App automatically uses SharedPreferences
- Data persists in browser's local storage
- Clear browser cache = data loss (expected)

## Enable Debug Logging

To get detailed logs, temporarily modify `lib/services/local_db.dart`:

```dart
void debugPrint(String message) {
  // Change this line:
  print('[LocalDatabase] $message');  // Make sure it's printing

  // To also output to a file for later review:
  // (Optional - only if you need persistent logs)
}
```

## Testing the Save Functionality

Run this test to verify the save mechanism:

```bash
flutter test test/debug_save_vitals_test.dart
```

Expected output:
```
✅ VitalRecord created successfully
✅ VitalRecord converted to map successfully
✅ VitalRecord saved to database
✅ VitalRecord saved via provider
```

If any fail, check the error message.

## Manual Testing Steps

1. **Open AddVitalsScreen**
   - Tap "Log Vital" button on dashboard
   - Screen should open with form

2. **Fill in ALL fields**
   - Weight: Enter "70" (kg)
   - Systolic: Enter "120"
   - Diastolic: Enter "80"
   - Heart Rate: Enter "75"
   - Tap date field → select today
   - Tap time field → select current time

3. **Tap "Save Vitals"**
   - Should show loading indicator
   - Then show green success message: "Vitals saved successfully!"
   - Screen should close automatically

4. **Verify on Dashboard**
   - BP card should show: 120/80 mmHg
   - HR card should show: 75 bpm

## Still Not Working?

If none of the above helps:

1. **Check Flutter version**: `flutter --version` (need 3.0+)
2. **Clean and rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Check for provider errors**:
   - Look for `VitalsProvider initialization failed`
   - Check notification service isn't blocking

4. **Test with minimal data**:
   - Only fill BP and HR (leave weight empty)
   - Try saving - should still work

5. **Collect logs and create issue**:
   ```bash
   flutter run -v > debug.log 2>&1
   # Try to save vitals
   # Share debug.log for analysis
   ```

## Known Limitations

1. **Web Platform**: Data only persists in browser local storage
2. **Multiple Records**: Currently shows only latest on dashboard (full history available via database)
3. **Offline**: All platforms work offline; data saves locally

## Quick Verification Checklist

- [ ] All dependencies installed (`flutter pub get`)
- [ ] Provider initialized in main.dart
- [ ] All form fields filled with valid values
- [ ] Date and time selected
- [ ] Console checked for error messages
- [ ] Platform-specific permissions granted (if needed)
- [ ] Not running on web expecting SQLite to work

## Emergency Workaround

If vitals absolutely won't save through the UI, you can manually add test data via provider:

```dart
// In pregnancy_dashboard_screen.dart, temporarily modify _handleLogVital:
void _handleLogVital() async {
  final provider = context.read<VitalsProvider>();

  // Add directly via provider (bypasses form)
  final record = VitalRecord(
    timestamp: DateTime.now(),
    weightKg: 70.0,
    systolic: 120,
    diastolic: 80,
    heartRate: 75,
  );

  await provider.addVitalRecord(record);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Test vitals added')),
  );
}
```

This will confirm if the issue is with the form or the database layer.

---

**Need more help?**
- Check the [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for detailed API documentation
- Review test files in `test/` for working examples
- Check GitHub issues for similar problems
