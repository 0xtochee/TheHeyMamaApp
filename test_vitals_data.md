# Testing Vitals Data Flow

## How to Test the Chart Data Display

### Step 1: Add Sample Vitals Data
1. Run the app
2. From Dashboard, tap "Log Vital" button
3. Enter sample data:
   - Weight: 70 kg
   - Blood Pressure: 120/80
   - Heart Rate: 75
4. Tap "Save Vitals"
5. Repeat 3-4 times with different dates and values

### Step 2: View Charts
1. From Dashboard, tap "Track" in bottom navigation
2. You should see the Weight chart with data points
3. Switch tabs to see BP, HR charts

### Step 3: Verify Data is Displaying
- **If charts show data:** Working correctly! ✅
- **If charts show "No data yet":** Data might not be saving correctly

## Debugging Steps

### Check if Data is Being Saved
Look for these debug logs in console:
```
[AddVitalsScreen] VitalRecord created: VitalRecord(...)
[VitalsProvider] Saved vital record with ID: ...
[LocalDatabase] Inserted vital record with ID: ...
```

### Check if Data is Being Loaded
Look for these debug logs:
```
[VitalsProvider] Loading chart data...
Failed to load chart data: ... (if there's an error)
```

### Common Issues

1. **Database not initialized on web**
   - App automatically falls back to SharedPreferences
   - This is expected behavior

2. **No data showing in charts**
   - Make sure you entered data for ALL fields (weight, BP, HR)
   - Check that dates are within the selected range (Last 7 Days by default)
   - Try entering data with today's date

3. **Charts not updating after adding data**
   - This should now work with the fix applied
   - Make sure you're using the "Quick Log" button from Track screen

## Expected Behavior

### Weight Chart
- Shows line graph of weight over time
- X-axis: Mon, Tue, Wed, etc.
- Y-axis: Weight values (auto-scaled)
- Touch chart for tooltips: "Mon — 70.0 kg"

### Blood Pressure Chart
- Shows systolic values as line graph
- Touch for tooltips: "Mon — 120 mmHg"

### Heart Rate Chart
- Shows HR values as line graph
- Touch for tooltips: "Mon — 75 bpm"

### Sugar Chart
- Shows blood sugar values
- Touch for tooltips: "Mon — 95 mg/dL"

## Adding Debug Output

If you need to see what's happening, check the console for:
- Save operations
- Database queries
- Chart data loading
- Provider state changes
