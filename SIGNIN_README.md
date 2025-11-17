# Sign In Screen Implementation

A pixel-perfect Flutter sign-in screen with comprehensive features and testing.

## 📁 Files Created

### 1. **`lib/screens/sign_in_screen.dart`**
The main sign-in screen widget with:
- Rounded white card over soft blue background
- Email and password input fields with validation
- "Remember me" checkbox functionality
- Primary sign-in button with loading state
- Social sign-in buttons (Google, Apple)
- Full accessibility support

### 2. **`lib/widgets/rounded_input_field.dart`**
Reusable text input widget featuring:
- Customizable labels and placeholders
- Password field with show/hide toggle
- Focus state with color change
- Form validation support
- Semantic labels for accessibility

### 3. **`lib/services/auth_service.dart`**
Authentication service stub with:
- Email/password sign-in (demo credentials)
- Google sign-in stub
- Apple sign-in stub
- Email and password validation
- Detailed TODOs for backend integration

### 4. **`lib/services/secure_storage.dart`**
Secure storage wrapper for:
- "Remember me" flag persistence
- Auth token storage
- User email storage
- Platform-specific encrypted storage

### 5. **`lib/constants/sign_in_constants.dart`**
UI constants including:
- All colors (primary, text, borders, etc.)
- Border radii and spacing values
- Typography sizes and weights
- Component dimensions

### 6. **`test/sign_in_screen_test.dart`**
Comprehensive widget tests covering:
- UI element rendering
- Form validation (empty fields, invalid email, short password)
- Sign-in flow with mock service
- Success/error message display
- Remember me checkbox toggle
- Password visibility toggle
- Social sign-in button interactions

## 🎨 Design Specifications

### Colors
- **Primary Blue**: `#1E88E5`
- **Accent Blue**: `#0D79FF`
- **Background Blue**: `#BEE3FF`
- **Text Dark**: `#182033`
- **Text Muted**: `#7B8594`
- **Text Label**: `#5B6B7A`
- **Border Stroke**: `#E6E9EE`
- **Error Red**: `#D84315`

### Layout
- **Card Border Radius**: 28px
- **Input Border Radius**: 12px
- **Button Border Radius**: 28px (pill shape)
- **Card Margins**: 16px horizontal
- **Card Padding**: 24px horizontal, 48px top
- **Input Spacing**: 20px between fields

### Typography
- **Title**: 30sp, Bold (Inter)
- **Subtitle**: 15sp, Regular
- **Labels**: 13sp, Medium
- **Inputs**: 15sp
- **Button**: 16sp, Semibold

## 🔐 Demo Credentials

The auth service includes demo credentials for testing:

```
Email: demo@demo.com
Password: password123
```

All other credentials will fail authentication.

## 🧪 Running Tests

```bash
# Run all sign-in screen tests
flutter test test/sign_in_screen_test.dart

# Run with coverage
flutter test --coverage test/sign_in_screen_test.dart

# Run in verbose mode
flutter test --verbose test/sign_in_screen_test.dart
```

### Test Coverage
The test suite includes:
- ✅ UI element rendering verification
- ✅ Empty field validation
- ✅ Invalid email validation
- ✅ Short password validation
- ✅ Successful sign-in flow
- ✅ Failed sign-in flow
- ✅ Remember me toggle
- ✅ Password visibility toggle
- ✅ Google sign-in trigger
- ✅ Apple sign-in trigger

## 📦 Dependencies Added

```yaml
dependencies:
  flutter_secure_storage: ^9.2.2  # For secure token/flag storage
  google_fonts: ^6.1.0             # For Inter font (already in project)

assets:
  - assets/images/sign-in-logo.png # Logo asset
```

## 🚀 Usage

### Basic Usage
```dart
import 'package:pregnancy_dashboard/screens/sign_in_screen.dart';

// Navigate to sign-in screen
final result = await Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SignInScreen()),
);

if (result == true) {
  // User signed in successfully
}
```

### With Custom Auth Service (for testing)
```dart
final mockAuthService = MockAuthService();

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SignInScreen(
      authService: mockAuthService,
    ),
  ),
);
```

## 🔧 Backend Integration TODOs

The implementation includes clear TODOs for connecting to a real backend:

### 1. **Email/Password Authentication**
In `lib/services/auth_service.dart`, replace the stub in `signInWithEmail()`:
```dart
// TODO: Connect to real backend API
final response = await http.post(
  Uri.parse('https://api.example.com/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'email': email, 'password': password}),
);
```

### 2. **Google Sign-In**
Add `google_sign_in` package and implement in `signInWithGoogle()`:
```dart
final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
// Send googleAuth.idToken to backend
```

### 3. **Apple Sign-In**
Add `sign_in_with_apple` package and implement in `signInWithApple()`:
```dart
final credential = await SignInWithApple.getAppleIDCredential(
  scopes: [
    AppleIDAuthorizationScopes.email,
    AppleIDAuthorizationScopes.fullName,
  ],
);
// Send credential.identityToken to backend
```

## 🎯 Features

### ✅ Implemented
- Pixel-perfect UI matching design specs
- Email/password validation
- Remember me functionality with secure storage
- Loading states during authentication
- Error handling with user-friendly messages
- Social sign-in UI (Google, Apple)
- Full accessibility (semantic labels, focus management)
- Keyboard handling (dismiss on submit)
- Responsive layout with safe areas
- Comprehensive widget tests

### 📝 Notes for Production

1. **Logo Asset**: Place your actual logo at `assets/images/sign-in-logo.png` (72x72 recommended)
2. **Backend**: Connect the auth service stubs to your real authentication API
3. **Password Requirements**: Update password validation in `auth_service.dart` for stronger requirements
4. **Error Messages**: Customize error messages based on your API responses
5. **Navigation**: After successful sign-in, navigate to your home screen instead of `Navigator.pop()`
6. **Token Refresh**: Implement token refresh logic if using JWT authentication
7. **Biometric Auth**: Consider adding fingerprint/face ID using `local_auth` package

## 🎨 Customization

All visual constants are centralized in `lib/constants/sign_in_constants.dart`. To customize:

```dart
// Change primary color
static const Color primaryBlue = Color(0xFFYOURCOLOR);

// Adjust spacing
static const double inputSpacing = 24.0;

// Modify typography
static const double titleFontSize = 32.0;
```

## 🐛 Known Limitations

1. **Logo**: Currently shows fallback icon if `sign-in-logo.png` not found
2. **Social Sign-In**: Stubs only - need real OAuth implementation
3. **Network Errors**: Currently shows generic error messages
4. **Offline Support**: No offline authentication capability

## 📱 Accessibility

The screen includes:
- Semantic labels on all interactive elements
- Minimum 44x44 touch targets
- Keyboard navigation support
- Screen reader announcements
- High contrast support
- Font scaling support

## 📄 License

Part of the Pregnancy Dashboard project.
