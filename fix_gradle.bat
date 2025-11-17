@echo off
echo ================================================
echo  Fixing Flutter Android Build Issues
echo ================================================
echo.
echo Step 1: Killing Java/Gradle processes...
taskkill /F /IM java.exe 2>nul
taskkill /F /IM gradle.exe 2>nul
timeout /t 2 /nobreak >nul
echo Done!
echo.
echo Step 2: Clearing corrupted Gradle caches...
rd /s /q "%USERPROFILE%\.gradle\caches\transforms-3" 2>nul
rd /s /q "%USERPROFILE%\.gradle\caches\modules-2" 2>nul
rd /s /q "android\.gradle" 2>nul
rd /s /q "android\build" 2>nul
rd /s /q "android\app\build" 2>nul
echo Done!
echo.
echo Step 3: Cleaning Flutter project...
cd /d "%~dp0"
flutter clean
echo Done!
echo.
echo Step 4: Getting dependencies...
flutter pub get
echo Done!
echo.
echo Step 5: Building and running on Android...
echo This will take 2-5 minutes on first build...
echo.
flutter run -d CYMJFML7BMZ9MVEY --no-pub
pause
