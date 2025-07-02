# 7. Setup & Installation Guide

## 🚀 Development Environment Setup

### Prerequisites
Before setting up SafeCom, ensure you have the following installed:

```bash
# Required Software
- Flutter SDK (3.7.2 or higher)
- Dart SDK (included with Flutter)
- Android Studio / VS Code
- Git
- Node.js (for Firebase CLI)

# Platform-specific Requirements
Android:
- Android SDK
- Android Emulator or Physical Device

iOS:
- Xcode (macOS only)
- iOS Simulator or Physical Device
- CocoaPods

Web:
- Chrome browser for testing
```

### Flutter Installation
```bash
# 1. Download Flutter SDK
# Visit: https://docs.flutter.dev/get-started/install

# 2. Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Verify installation
flutter doctor

# 4. Enable required platforms
flutter config --enable-android
flutter config --enable-ios
flutter config --enable-web
```

## 🔧 Project Setup

### 1. Clone Repository
```bash
git clone <repository-url>
cd safecom_final
```

### 2. Install Dependencies
```bash
# Get Flutter packages
flutter pub get

# For iOS (macOS only)
cd ios && pod install && cd ..

# Verify dependencies
flutter doctor
```

### 3. Project Structure Verification
```bash
# Verify project structure
tree lib/ -I '__pycache__|*.pyc'

# Expected structure:
lib/
├── main.dart
├── Core/
│   ├── dependency_injection/
│   ├── navigation/
│   ├── services/
│   ├── constants/
│   ├── errors/
│   └── utils/
├── features/
│   ├── authentication/
│   └── weather/
├── shared/
```

## 🔥 Firebase Configuration

### 1. Firebase Project Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project
firebase init
```

### 2. Firebase Services Configuration

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Name: "SafeCom Emergency System"
4. Enable Google Analytics (optional)

#### Enable Authentication
```bash
# In Firebase Console:
1. Go to Authentication → Sign-in method
2. Enable Email/Password
3. Enable Google Sign-In
4. Configure OAuth consent screen
```

#### Setup Firestore Database
```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Emergency reports - authenticated users can create, read own
    match /emergency_reports/{reportId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Safety incidents - read for all authenticated users, write for system
    match /safety_incidents/{incidentId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
    }
    
    // SOS alerts - user can create/read own
    match /sos_alerts/{sosId} {
      allow create, read: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

#### Configure Firebase Storage
```javascript
// Storage Security Rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can upload images for reports
    match /reports/{userId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Profile images
    match /users/{userId}/profile/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 3. Firebase Configuration Files

#### Android Configuration
```bash
# Download google-services.json from Firebase Console
# Place in: android/app/google-services.json

# Update android/build.gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}

# Update android/app/build.gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.2.2')
}
```

#### iOS Configuration
```bash
# Download GoogleService-Info.plist from Firebase Console
# Place in: ios/Runner/GoogleService-Info.plist

# Update ios/Runner/Info.plist
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

## 🌤️ Weather API Setup

### WeatherAPI Configuration
```dart
// File: lib/Core/constants/api_constants.dart
class ApiConstants {
  static const String weatherApiKey = 'YOUR_WEATHER_API_KEY';
  static const String weatherBaseUrl = 'http://api.weatherapi.com/v1';
  
  // Get API key from: https://www.weatherapi.com/
  // Free tier: 1,000,000 calls/month
}
```

### Environment Variables
```bash
# Create .env file (not committed to git)
echo "WEATHER_API_KEY=your_actual_api_key_here" > .env

# Add to .gitignore
echo ".env" >> .gitignore
```

## 📱 Platform-Specific Setup

### Android Setup
```kotlin
// android/app/src/main/AndroidManifest.xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    
    <application
        android:label="SafeCom"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Main Activity -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme" />
              
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <!-- Firebase Messaging -->
        <service
            android:name=".MyFirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
    </application>
</manifest>
```

### iOS Setup
```xml
<!-- ios/Runner/Info.plist -->
<dict>
    <!-- Location permissions -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>SafeCom needs location access for emergency reporting and safety features.</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>SafeCom may need background location access for emergency situations.</string>
    
    <!-- Camera permissions -->
    <key>NSCameraUsageDescription</key>
    <string>SafeCom needs camera access to attach photos to incident reports.</string>
    
    <!-- Photo library permissions -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>SafeCom needs photo access to attach images to reports.</string>
    
    <!-- App Transport Security -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
        <key>NSExceptionDomains</key>
        <dict>
            <key>api.weatherapi.com</key>
            <dict>
                <key>NSExceptionAllowsInsecureHTTPLoads</key>
                <true/>
            </dict>
        </dict>
    </dict>
</dict>
```

## 🔧 Build Configuration

### Development Build
```bash
# Debug build for testing
flutter run --debug

# Specific platform
flutter run --debug -d android
flutter run --debug -d ios
flutter run --debug -d chrome
```

### Release Build
```bash
# Android Release APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS Release (macOS only)
flutter build ios --release

# Web Release
flutter build web --release
```

### Build Optimization
```dart
// pubspec.yaml - Optimization settings
flutter:
  assets:
    - Images/
  
  # App icon generation
  flutter_icons:
    android: true
    ios: true
    image_path: "Images/logo.png"
    
  # Build optimization
  uses-material-design: true
  generate: true
```

## 🧪 Testing Setup

### Unit Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/auth_service_test.dart

# Test with coverage
flutter test --coverage
```

### Integration Tests
```bash
# Run integration tests
flutter test integration_test/

# Run on specific device
flutter test integration_test/ -d android
```

### Test Configuration
```dart
// test/test_config.dart
class TestConfig {
  static void setupTestEnvironment() {
    // Mock Firebase
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Setup test data
    setupMockData();
    
    // Initialize test services
    initializeTestServices();
  }
}
```

## 🚀 Deployment

### Android Deployment
```bash
# 1. Generate signing key
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 2. Configure signing in android/key.properties
storePassword=myStorePassword
keyPassword=myKeyPassword
keyAlias=upload
storeFile=../upload-keystore.jks

# 3. Build release bundle
flutter build appbundle --release

# 4. Upload to Google Play Console
```

### iOS Deployment
```bash
# 1. Configure in Xcode
open ios/Runner.xcworkspace

# 2. Set up provisioning profiles
# 3. Archive for distribution
# 4. Upload to App Store Connect

# Or use command line
flutter build ios --release
```

### Web Deployment
```bash
# Build for web
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting

# Or deploy to other hosting services
# Copy build/web/ contents to your web server
```

## 🔍 Debugging and Development Tools

### Debug Configuration
```json
// .vscode/launch.json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Flutter Debug",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "args": ["--debug"]
        },
        {
            "name": "Flutter Profile",
            "request": "launch",
            "type": "dart",
            "flutterMode": "profile",
            "program": "lib/main.dart"
        }
    ]
}
```

### Development Scripts
```bash
#!/bin/bash
# scripts/dev_setup.sh

echo "Setting up SafeCom development environment..."

# Install dependencies
flutter pub get

# Generate code if needed
flutter packages pub run build_runner build

# Check for issues
flutter analyze

# Run tests
flutter test

echo "Development environment ready!"
```

## 📋 Environment Variables

### Development Environment
```bash
# .env.development
ENVIRONMENT=development
DEBUG_MODE=true
WEATHER_API_KEY=dev_api_key
FIREBASE_PROJECT_ID=safecom-dev
LOG_LEVEL=debug
```

### Production Environment
```bash
# .env.production
ENVIRONMENT=production
DEBUG_MODE=false
WEATHER_API_KEY=prod_api_key
FIREBASE_PROJECT_ID=safecom-prod
LOG_LEVEL=error
```

## 🔧 Troubleshooting

### Common Issues

#### Firebase Connection Issues
```bash
# Check Firebase configuration
flutter doctor

# Verify Firebase project
firebase projects:list

# Re-download config files
# Android: google-services.json
# iOS: GoogleService-Info.plist
```

#### Location Permission Issues
```dart
// Check location permissions
Future<void> checkLocationPermissions() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Handle permanently denied
    await Geolocator.openAppSettings();
  }
}
```

#### Build Issues
```bash
# Clean build
flutter clean
flutter pub get

# Reset iOS pods
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..

# Clear Android cache
cd android && ./gradlew clean && cd ..
```

## 📚 Additional Resources

### Documentation Links
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [WeatherAPI Documentation](https://www.weatherapi.com/docs/)

### Development Tools
- [Flutter Inspector](https://docs.flutter.dev/development/tools/flutter-inspector)
- [Firebase Console](https://console.firebase.google.com/)
- [Android Studio](https://developer.android.com/studio)
- [VS Code Flutter Extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)

---

Next: [API Reference](./08-api-reference.md)
