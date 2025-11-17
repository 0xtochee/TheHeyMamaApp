# Track Vitals Screen - Data & Charts Guide

## ✅ What's Working Now

The Track Vitals screen is **fully implemented** and will display charts based on **actual data from your database**. Here's how it works:

### Data Flow
```
User Adds Vitals → Database → VitalsProvider → Chart Widget → Display
```

## 🚀 Quick Start - See Charts Immediately

### Option 1: Use Sample Data Button (Fastest!)

1. **Run the app** (should already be running)
2. On the **Dashboard screen**, scroll down
3. You'll see a **purple "Add Sample Data"** button below the "Log Vital" button
4. **Tap it** - this adds 7 days of sample vitals data
5. Navigate to **Track** screen (bottom navigation, 2nd tab)
6. **You should now see charts with data!** 📊

### Option 2: Manual Entry

1. From Dashboard, tap **"Log Vital"**
2. Enter data for multiple days:
   - **Day 1**: Weight: 68 kg, BP: 120/80, HR: 75, Sugar: 90
   - **Day 2**: Weight: 69 kg, BP: 118/78, HR: 73, Sugar: 92
   - **Day 3**: Weight: 70 kg, BP: 122/82, HR: 77, Sugar: 88
3. Navigate to **Track** screen
4. View your charts!

## 📊 What You'll See

### Weight Chart
- **Line graph** showing weight changes over time
- **X-axis**: Days of the week (Mon, Tue, Wed, etc.)
- **Y-axis**: Weight in kg (auto-scaled)
- **Touch chart**: Shows tooltip "Mon — 68.5 kg"
- **Trend**: Shows percentage change (e.g., "+2.9%")

### Blood Pressure Chart
- Shows **systolic pressure** values
- **Touch chart**: Shows "Mon — 120 mmHg"
- Red color scheme

### Heart Rate Chart
- Shows **heart rate** in bpm
- **Touch chart**: Shows "Mon — 75 bpm"
- Orange color scheme

### Blood Sugar Chart
- Shows **blood sugar** in mg/dL
- **Touch chart**: Shows "Mon — 90 mg/dL"
- Purple color scheme

## 🔧 How It Works

### 1. Data Storage
- Data saved to **SQLite database** (or SharedPreferences as fallback)
- Each record stores: timestamp, weight, BP (systolic/diastolic), HR, blood sugar
- Records stored in `vital_records` table

### 2. Data Loading
When you open Track screen:
```dart
1. Provider calls initializeChartData()
2. Loads records from last 7 days (default)
3. Extracts data for selected metric (Weight/BP/HR/Sugar)
4. Converts to TimeSeriesPoint objects
5. Chart displays the points
```

### 3. Date Range Selection
- **Last 7 Days** (default)
- **Last 30 Days**
- **Last 90 Days**

Change range using the chips at the bottom of the chart.

## 🐛 Debugging

### Check Console Output

You should see these logs when loading charts:

```
[VitalsProvider] Loading chart data for Weight
[VitalsProvider] Date range: 2025-10-27 to 2025-11-03
[VitalsProvider] Found 7 records
[VitalsProvider] Extracted 7 data points for Weight
[VitalsProvider] First point: TimeSeriesPoint(time: 2025-10-27, value: 68.5)
[VitalsProvider] Last point: TimeSeriesPoint(time: 2025-11-03, value: 70.5)
```

### If You See "No data yet for this period"

This means no data exists in the selected date range. Solutions:

1. **Use the "Add Sample Data" button** (easiest!)
2. **Add data manually** with today's date
3. **Check date range** - data might be outside the selected range
4. **Check console** for error messages

### If Charts Don't Update After Adding Data

The Quick Log button now properly refreshes data:
```dart
// After saving, the app automatically:
1. Reloads latest vitals
2. Reloads chart data
3. Updates the display
```

## 📱 UI Features

### Chart Interactions
- **Touch & Hold**: See tooltip with exact value
- **Pan**: Scroll through data points
- **Animated**: Smooth 500ms transitions when switching

### Tab Switching
- Tap tabs at top to switch metrics
- Chart animates to show new data
- Header updates with current value and trend

### Date Range
- Select different time periods
- Chart reloads with new date range
- All metrics use the same date range

## 🎯 Testing Checklist

- [ ] Run app (Windows/Web/Mobile)
- [ ] Tap "Add Sample Data" button
- [ ] See success message
- [ ] Navigate to Track screen (bottom nav)
- [ ] See Weight chart with 7 data points
- [ ] Switch to Blood Pressure tab - see BP chart
- [ ] Switch to Heart Rate tab - see HR chart
- [ ] Switch to Blood Sugar tab - see Sugar chart
- [ ] Touch chart - see tooltip appear
- [ ] Change date range - chart updates
- [ ] Tap Quick Log - add new data
- [ ] See chart update with new point

## 🔍 Data Structure

### VitalRecord Model
```dart
class VitalRecord {
  final DateTime timestamp;    // When recorded
  final double? weightKg;       // Weight in kg
  final int? systolic;          // BP systolic
  final int? diastolic;         // BP diastolic
  final int? heartRate;         // HR in bpm
  final int? bloodSugar;        // Sugar in mg/dL
}
```

### TimeSeriesPoint (for charts)
```dart
class TimeSeriesPoint {
  final DateTime time;          // X-axis
  final double value;           // Y-axis
}
```

### MetricConfig (per metric)
```dart
- metric: MetricType enum
- unit: "kg", "mmHg", "bpm", "mg/dL"
- minY/maxY: Chart Y-axis range
- color: Chart line color
- tooltipFormatter: Format tooltip text
- valueFormatter: Format display value
```

## 💡 Pro Tips

1. **Add data regularly** - Charts look best with multiple data points
2. **Use different dates** - Spread data across the week
3. **Vary values slightly** - Makes trends visible
4. **Check all tabs** - Each metric has its own chart
5. **Use Quick Log** from Track screen - It auto-refreshes

## 📝 Sample Data Details

The "Add Sample Data" button adds:
- **7 records** (one per day for the last week)
- **Weight**: 68.5 → 70.5 kg (gradual increase)
- **BP**: 115/75 → 123/81 mmHg (slight variation)
- **HR**: 72 → 78 bpm (normal range)
- **Sugar**: 88 → 94 mg/dL (healthy levels)

All with realistic trending values!

---

**Status**: ✅ Fully Functional - Charts display real data from database
**Last Updated**: Nov 3, 2025
