# Debug Steps: Vitals Not Saving Issue

## What I've Done

1. ✅ Added missing `path` package dependency to `pubspec.yaml`
2. ✅ Added comprehensive debug logging to `AddVitalsScreen`
3. ✅ Created troubleshooting guide
4. ✅ Created debug tests

## What You Need To Do Now

### Step 1: Install Dependencies

```bash
cd pregnancy_dashboard
flutter pub get
```

### Step 2: Run the App with Logging

```bash
flutter run -v
```

Or if running on web:

```bash
flutter run -d chrome --web-port=8080
```

### Step 3: Try to Save Vitals

1. Click "Log Vital" button
2. Fill in the form:
   - Weight: `70`
   - Systolic: `120`
   - Diastolic: `80`
   - Heart Rate: `75`
   - Select today's date
   - Select current time
3. Click "Save Vitals"

### Step 4: Check the Console Output

Look for these debug messages in your console:

```
[AddVitalsScreen] Parsed values:
  Weight: 70.0 kg
  BP: 120/80 mmHg
  HR: 75 bpm
  DateTime: 2025-01-15 10:30:00.000
[AddVitalsScreen] VitalRecord created: VitalRecord(...)
[AddVitalsScreen] Attempting to save via provider...
[LocalDatabase] Inserted vital record with ID: 1
[AddVitalsScreen] Save result: true
```

### What the Logs Tell You

**If you see:**
- `Save result: true` → ✅ Save succeeded!
- `Save result: false` → ❌ Provider returned false
- `Error saving vitals: ...` → ❌ Exception occurred
- `SQLite insert failed, using SharedPreferences fallback` → ⚠️ Using fallback (expected on web)

### Common Fixes Based on Logs

#### 1. No logs appear at all
**Issue**: App not running in debug mode or logs filtered out

**Fix**:
```bash
flutter clean
flutter pub get
flutter run -v 2>&1 | tee debug.log
```

#### 2. "Save result: false" appears
**Issue**: Provider couldn't save to database

**Possible causes**:
- Database not initialized
- Permissions issue (Android/iOS)
- Web platform (should auto-fallback)

**Fix**: Check earlier in logs for:
```
[LocalDatabase] Failed to initialize database: ...
```

#### 3. "Error saving vitals: Exception: ..."
**Issue**: Actual error occurred

**Fix**: Read the exception message and stack trace for specifics

#### 4. Form validation error
**Issue**: Fields not filled correctly

**Fix**: Ensure all fields have values within valid ranges

## Quick Test

Run this to verify the core save functionality works:

```bash
flutter test test/debug_save_vitals_test.dart -r expanded
```

Expected output:
```
✅ VitalRecord created successfully
✅ VitalRecord converted to map successfully
✅ VitalRecord saved to database
✅ VitalRecord saved via provider
All tests passed!
```

## Platform-Specific Notes

### Running on Web
- SQLite will NOT work (expected)
- Will automatically use SharedPreferences
- Open browser DevTools (F12) → Console tab to see logs
- Check Application → Local Storage → `flutter.vitals_fallback`

### Running on Android/iOS
- May need storage permissions
- Check logcat (Android) or Xcode console (iOS)
- Database file created in app documents directory

### Running on Windows Desktop
- Should work out of the box
- Database saved to Windows app data folder

## If Still Not Working

### Option 1: Use Emergency Workaround

Temporarily bypass the form to test if database works:

Edit `lib/screens/pregnancy_dashboard_screen.dart`, line 377:

```dart
void _handleLogVital() async {
  // TEMPORARY TEST - Remove after debugging
  final provider = context.read<VitalsProvider>();
  final record = VitalRecord(
    timestamp: DateTime.now(),
    weightKg: 70.0,
    systolic: 120,
    diastolic: 80,
    heartRate: 75,
  );

  debugPrint('DEBUG: Manually adding vital record...');
  final success = await provider.addVitalRecord(record);
  debugPrint('DEBUG: Manual add result: $success');

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Test vital added: $success')),
  );

  // Original code commented out:
  // final result = await Navigator.pushNamed(context, '/add-vitals');
  // if (result != null && mounted) {
  //   context.read<VitalsProvider>().loadLatestVitals();
  // }
}
```

If this works, the issue is in the AddVitalsScreen form. If this doesn't work, the issue is in the database/provider layer.

### Option 2: Check Test Results

```bash
# Run all tests
flutter test

# Run specific database test
flutter test test/local_db_test.dart

# Run provider test
flutter test test/vitals_provider_test.dart
```

### Option 3: Share Logs

If still stuck, capture full logs:

```bash
flutter clean
flutter pub get
flutter run -v > debug.log 2>&1
# Try to save vitals
# Then share debug.log
```

## Success Criteria

You'll know it's working when:
1. ✅ No errors in console
2. ✅ Green success message appears: "Vitals saved successfully!"
3. ✅ Screen closes automatically
4. ✅ Dashboard shows updated BP and HR values
5. ✅ Can repeat without errors

## Next Steps After Fix

1. Remove debug `debugPrint` statements (or keep for future debugging)
2. Test on all target platforms
3. Verify data persists after app restart
4. Test edge cases (invalid data, missing fields, etc.)

---

**Need Help?**
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions
- Review [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for API usage
- Check console logs for specific error messages
