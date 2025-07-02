# 8. API Reference

## 🔌 API Overview

SafeCom integrates with multiple APIs and services to provide comprehensive emergency and safety features. This document provides complete API reference for all service integrations.

## 🔐 Authentication APIs

### Firebase Authentication API

#### Sign Up
```dart
static Future<Map<String, dynamic>> signUp({
  required String email,
  required String password,
  required String fullName,
  required String phone,
})
```

**Parameters:**
- `email` (String): User's email address
- `password` (String): User's password (min 6 characters)
- `fullName` (String): User's full name
- `phone` (String): User's phone number

**Returns:**
```dart
{
  'success': bool,
  'message': String,
  'user': User?, // Firebase User object
}
```

**Example:**
```dart
final result = await FirebaseService.signUp(
  email: 'user@example.com',
  password: 'securepassword',
  fullName: 'John Doe',
  phone: '+1234567890',
);

if (result['success']) {
  // Handle successful registration
  final user = result['user'];
} else {
  // Handle error
  final errorMessage = result['message'];
}
```

#### Sign In
```dart
static Future<Map<String, dynamic>> signIn({
  required String email,
  required String password,
})
```

**Parameters:**
- `email` (String): User's email address
- `password` (String): User's password

**Returns:**
```dart
{
  'success': bool,
  'message': String,
  'user': User?, // Firebase User object
}
```

#### Sign Out
```dart
static Future<void> signOut()
```

**Returns:** `void`

**Example:**
```dart
try {
  await FirebaseService.signOut();
  // User successfully signed out
} catch (e) {
  // Handle sign out error
}
```

### Local Authentication API

#### Check Login Status
```dart
static Future<bool> isLoggedIn()
```

**Returns:** `bool` - Whether user is currently logged in

#### Get User Data
```dart
static Future<Map<String, String?>> getUserData()
```

**Returns:**
```dart
{
  'name': String?,
  'email': String?,
  'phone': String?,
}
```

#### Update Profile
```dart
static Future<bool> updateProfile({
  String? name,
  String? email,
  String? phone,
})
```

**Parameters:** Any combination of name, email, or phone
**Returns:** `bool` - Success status

## 🌤️ Weather API

### WeatherAPI Integration

#### Get Current Weather
```dart
Future<Map<String, dynamic>> getCurrentWeather({
  required double latitude,
  required double longitude,
})
```

**Parameters:**
- `latitude` (double): Geographic latitude
- `longitude` (double): Geographic longitude

**Returns:**
```dart
{
  'location': {
    'name': String,
    'region': String,
    'country': String,
    'lat': double,
    'lon': double,
    'tz_id': String,
    'localtime': String,
  },
  'current': {
    'last_updated': String,
    'temp_c': double,
    'temp_f': double,
    'is_day': int,
    'condition': {
      'text': String,
      'icon': String,
      'code': int,
    },
    'wind_mph': double,
    'wind_kph': double,
    'wind_degree': int,
    'wind_dir': String,
    'pressure_mb': double,
    'pressure_in': double,
    'precip_mm': double,
    'precip_in': double,
    'humidity': int,
    'cloud': int,
    'feelslike_c': double,
    'feelslike_f': double,
    'vis_km': double,
    'vis_miles': double,
    'uv': double,
    'gust_mph': double,
    'gust_kph': double,
  }
}
```

**Example:**
```dart
final weather = await weatherService.getCurrentWeather(
  latitude: 40.7128,
  longitude: -74.0060,
);

final temperature = weather['current']['temp_c'];
final condition = weather['current']['condition']['text'];
final location = weather['location']['name'];
```

#### Get Weather Forecast
```dart
Future<Map<String, dynamic>> getWeatherForecast({
  required double latitude,
  required double longitude,
  int days = 3,
})
```

**Parameters:**
- `latitude` (double): Geographic latitude
- `longitude` (double): Geographic longitude
- `days` (int): Number of forecast days (1-10)

**Returns:** Extended weather data with forecast array

## 🚨 Emergency Services API

### Emergency Report Submission

#### Submit Emergency Report
```dart
static Future<Map<String, dynamic>> submitEmergencyReport({
  required String type,
  required String description,
  String? selectedOption,
  String? location,
  File? image,
})
```

**Parameters:**
- `type` (String): 'disaster' or 'harassment'
- `description` (String): Incident description
- `selectedOption` (String?): Disaster type or gender for harassment
- `location` (String?): Custom location description
- `image` (File?): Optional image attachment

**Returns:**
```dart
{
  'success': bool,
  'message': String,
  'reportId': String?, // Firestore document ID
}
```

**Example:**
```dart
final result = await FirebaseService.submitEmergencyReport(
  type: 'disaster',
  description: 'Flooding on Main Street',
  selectedOption: 'flood',
  location: 'Downtown area',
  image: imageFile,
);

if (result['success']) {
  final reportId = result['reportId'];
  // Report submitted successfully
}
```

#### Get User Reports
```dart
static Stream<QuerySnapshot> getUserReports()
```

**Returns:** `Stream<QuerySnapshot>` - Real-time stream of user's reports

**Example:**
```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseService.getUserReports(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final reports = snapshot.data!.docs;
      return ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index].data() as Map<String, dynamic>;
          return ReportCard(report: report);
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

## 🛡️ Safety Data API

### Real-time Safety Status

#### Get Safety Status Stream
```dart
static Stream<Map<String, dynamic>> getSafetyStatusStream({
  String? category,
})
```

**Parameters:**
- `category` (String?): Filter by 'disaster', 'harassment', or null for all

**Returns:**
```dart
Stream<Map<String, dynamic>> {
  'status': String, // 'safe', 'moderate', 'high_risk', 'critical'
  'location': String,
  'riskLevel': String,
  'message': String,
  'incidentCount': int,
  'lastUpdated': DateTime,
  'nearbyIncidents': List<Map<String, dynamic>>,
}
```

**Example:**
```dart
StreamBuilder<Map<String, dynamic>>(
  stream: SafetyDataService.getSafetyStatusStream(category: 'disaster'),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final safetyData = snapshot.data!;
      return SafetyStatusCard(
        status: safetyData['status'],
        riskLevel: safetyData['riskLevel'],
        incidentCount: safetyData['incidentCount'],
      );
    }
    return CircularProgressIndicator();
  },
)
```

#### Report Safety Incident
```dart
static Future<Map<String, dynamic>> reportIncident({
  required String type,
  required String description,
  String? category,
  File? image,
})
```

**Parameters:**
- `type` (String): Incident type
- `description` (String): Incident description
- `category` (String?): Category classification
- `image` (File?): Optional image

**Returns:** Standard success/error response

### SOS Alert System

#### Trigger SOS Alert
```dart
static Future<Map<String, dynamic>> triggerSOS({
  String category = 'general',
})
```

**Parameters:**
- `category` (String): 'general', 'disaster', or 'harassment'

**Returns:**
```dart
{
  'success': bool,
  'message': String,
  'sosId': String?, // SOS alert ID for tracking
}
```

**Example:**
```dart
final result = await SafetyDataService.triggerSOS(category: 'harassment');

if (result['success']) {
  final sosId = result['sosId'];
  // SOS alert active, show tracking UI
  showSOSTrackingDialog(sosId);
}
```

#### Deactivate SOS Alert
```dart
static Future<bool> deactivateSOS(String sosId)
```

**Parameters:**
- `sosId` (String): SOS alert ID to deactivate

**Returns:** `bool` - Success status

## 📍 Location Services API

### Location Access

#### Get Current Location
```dart
static Future<Position?> _getCurrentLocation()
```

**Returns:** `Position?` - Current device location or null

**Position Object:**
```dart
Position {
  latitude: double,
  longitude: double,
  timestamp: DateTime,
  accuracy: double,
  altitude: double,
  heading: double,
  speed: double,
  speedAccuracy: double,
}
```

#### Check Location Permissions
```dart
Future<LocationPermission> checkPermission()
Future<LocationPermission> requestPermission()
```

**LocationPermission Enum:**
- `denied`: Permission denied
- `deniedForever`: Permission permanently denied
- `whileInUse`: Permission granted while app is in use
- `always`: Permission granted always

**Example:**
```dart
LocationPermission permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    // Handle denied permission
    return;
  }
}

if (permission == LocationPermission.deniedForever) {
  // Open app settings
  await Geolocator.openAppSettings();
  return;
}

// Permission granted, get location
final position = await Geolocator.getCurrentPosition();
```

## 🔔 Push Notification API

### Firebase Cloud Messaging

#### Subscribe to Topics
```dart
await FirebaseMessaging.instance.subscribeToTopic('emergency_alerts');
await FirebaseMessaging.instance.subscribeToTopic('safety_updates');
```

#### Unsubscribe from Topics
```dart
await FirebaseMessaging.instance.unsubscribeFromTopic('emergency_alerts');
```

#### Handle Foreground Messages
```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Handle foreground message
  showNotificationDialog(message);
});
```

#### Handle Background Messages
```dart
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message
}
```

#### Get FCM Token
```dart
String? token = await FirebaseMessaging.instance.getToken();
```

## 📱 Google Sign-In API

### Google Authentication

#### Sign In with Google
```dart
static Future<Map<String, dynamic>> signInWithGoogle()
```

**Returns:**
```dart
{
  'success': bool,
  'message': String,
  'user': User?, // Firebase User object
}
```

**Example:**
```dart
final result = await GoogleSignInService.signInWithGoogle();

if (result['success']) {
  final user = result['user'];
  // Handle successful Google sign-in
} else {
  final error = result['message'];
  // Handle sign-in error
}
```

#### Sign Out from Google
```dart
static Future<void> signOutFromGoogle()
```

## 🗄️ Firestore Database API

### Collections Structure

#### Users Collection (`users`)
```dart
{
  'fullName': String,
  'email': String,
  'phone': String,
  'createdAt': Timestamp,
  'isActive': bool,
  'profileImageUrl': String?, // Optional
}
```

#### Emergency Reports Collection (`emergency_reports`)
```dart
{
  'type': String, // 'disaster' or 'harassment'
  'description': String,
  'userId': String,
  'userEmail': String,
  'timestamp': Timestamp,
  'status': String, // 'active', 'resolved', 'investigating'
  'location': String?,
  'disasterType': String?, // For disasters
  'gender': String?, // For harassment
  'imageUrl': String?, // Optional
}
```

#### Safety Incidents Collection (`safety_incidents`)
```dart
{
  'userId': String,
  'userEmail': String,
  'timestamp': Timestamp,
  'type': String, // 'incident', 'sos', 'report'
  'category': String, // 'disaster', 'harassment', 'general'
  'description': String,
  'latitude': double,
  'longitude': double,
  'severity': String, // 'low', 'medium', 'high', 'critical'
  'status': String, // 'active', 'resolved'
}
```

#### SOS Alerts Collection (`sos_alerts`)
```dart
{
  'userId': String,
  'userEmail': String,
  'timestamp': Timestamp,
  'type': String, // 'sos'
  'category': String, // 'harassment', 'disaster', 'general'
  'status': String, // 'active', 'deactivated', 'resolved'
  'urgency': String, // 'critical'
  'latitude': double,
  'longitude': double,
  'accuracy': double,
  'responseRequested': bool,
  'responseTime': Timestamp?, // When help arrived
}
```

### Firestore Queries

#### Query Recent Incidents
```dart
Query query = FirebaseFirestore.instance
    .collection('safety_incidents')
    .where('timestamp', isGreaterThan: DateTime.now().subtract(Duration(hours: 24)))
    .where('category', isEqualTo: 'disaster')
    .orderBy('timestamp', descending: true)
    .limit(50);
```

#### Real-time Listeners
```dart
StreamSubscription<QuerySnapshot> listener = FirebaseFirestore.instance
    .collection('safety_incidents')
    .snapshots()
    .listen((QuerySnapshot snapshot) {
      for (DocumentChange change in snapshot.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            // Handle new incident
            break;
          case DocumentChangeType.modified:
            // Handle updated incident
            break;
          case DocumentChangeType.removed:
            // Handle removed incident
            break;
        }
      }
    });
```

## 🔒 Error Handling

### Standard Error Response Format
```dart
{
  'success': false,
  'message': String, // Human-readable error message
  'errorCode': String?, // Optional error code
  'details': dynamic, // Optional additional details
}
```

### Common Error Codes
- `AUTH_INVALID_CREDENTIALS`: Invalid login credentials
- `AUTH_USER_NOT_FOUND`: User account not found
- `AUTH_EMAIL_ALREADY_EXISTS`: Email already registered
- `LOCATION_PERMISSION_DENIED`: Location access denied
- `NETWORK_ERROR`: Network connectivity issue
- `WEATHER_API_ERROR`: Weather service unavailable
- `FIRESTORE_PERMISSION_DENIED`: Insufficient database permissions

### Error Handling Example
```dart
try {
  final result = await FirebaseService.signIn(email: email, password: password);
  
  if (result['success']) {
    // Handle success
  } else {
    // Handle error
    final errorMessage = result['message'];
    final errorCode = result['errorCode'];
    
    switch (errorCode) {
      case 'AUTH_INVALID_CREDENTIALS':
        showDialog(context, 'Invalid email or password');
        break;
      case 'NETWORK_ERROR':
        showDialog(context, 'Please check your internet connection');
        break;
      default:
        showDialog(context, errorMessage);
    }
  }
} catch (e) {
  // Handle unexpected errors
  showDialog(context, 'An unexpected error occurred');
}
```

## 🔧 Configuration Constants

### API Endpoints
```dart
class ApiConstants {
  // Weather API
  static const String weatherBaseUrl = 'http://api.weatherapi.com/v1';
  static const String weatherApiKey = 'YOUR_API_KEY';
  
  // Firebase Project
  static const String firebaseProjectId = 'safecom-emergency-system';
  
  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 10);
  
  // Limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDescriptionLength = 1000;
}
```

### Feature Flags
```dart
class FeatureFlags {
  static const bool enableGoogleSignIn = true;
  static const bool enableWeatherAlerts = true;
  static const bool enableBackgroundLocation = false;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = false;
}
```

---

This completes the comprehensive API reference for the SafeCom Emergency Reporting System. Each API endpoint includes detailed parameters, return types, and usage examples to facilitate development and integration.
