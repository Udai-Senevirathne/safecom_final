# 4. Services Documentation

## 🏗️ Service Architecture Overview

SafeCom's service layer provides the core infrastructure for data management, external integrations, and business logic. All services follow singleton patterns and provide async operations with comprehensive error handling.

## 🔐 Authentication Services

### AuthService (Local Authentication)
**Location**: `lib/Core/services/auth_service.dart`

**Purpose**: Manages local authentication state and user data storage

**Key Methods**:
```dart
class AuthService {
  // Authentication Operations
  static Future<bool> signUp(String name, String email, String phone, String password)
  static Future<bool> signIn(String identifier, String password)
  static Future<void> signOut()
  
  // User Data Management
  static Future<Map<String, String?>> getUserData()
  static Future<bool> updateProfile({String? name, String? email, String? phone})
  static Future<bool> saveUserData(String name, String email, String phone)
  static Future<bool> clearUserData()
  
  // Session Management
  static Future<bool> isLoggedIn()
  static Future<bool> setLoginStatus(bool isLoggedIn)
  
  // Data Streaming
  static Stream<Map<String, String?>> get userDataStream
}
```

**Storage Strategy**:
- **Primary**: SharedPreferences for persistent storage
- **Fallback**: In-memory storage for testing/development
- **Data Encryption**: Local data protection
- **Stream Updates**: Real-time data synchronization

**Error Handling**:
```dart
try {
  final success = await AuthService.signIn(email, password);
  if (success) {
    // Handle successful authentication
  }
} catch (e) {
  // Handle authentication errors
}
```

### FirebaseService (Cloud Authentication)
**Location**: `lib/Core/services/firebase_service.dart`

**Purpose**: Firebase integration for authentication, data storage, and cloud operations

**Authentication Methods**:
```dart
class FirebaseService {
  // User Registration
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  })
  
  // User Authentication
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  })
  
  // Session Management
  static Future<void> signOut()
  static User? getCurrentUser()
  static bool isSignedIn()
  
  // Account Management
  static Future<Map<String, dynamic>> deleteUserAccount()
}
```

**Data Operations**:
```dart
// User Profile Management
static Future<bool> updateUserProfile(Map<String, dynamic> userData)

// Emergency Report Submission
static Future<Map<String, dynamic>> submitEmergencyReport({
  required String type,
  required String description,
  String? selectedOption,
  String? location,
  File? image,
})

// Data Retrieval
static Stream<QuerySnapshot> getUserReports()
static Stream<QuerySnapshot> getAllReports({int limit = 50})
```

**Account Deletion Process**:
1. Delete user's emergency reports from Firestore
2. Delete user's safety incidents
3. Delete user's SOS alerts
4. Delete user profile from Firestore
5. Delete user's uploaded files from Storage
6. Clear local authentication data
7. Disconnect Google Sign-In if applicable
8. Delete Firebase Auth account

### GoogleSignInService
**Location**: `lib/Core/services/google_signin_service.dart`

**Purpose**: Google authentication integration

**Key Features**:
```dart
class GoogleSignInService {
  static Future<Map<String, dynamic>> signInWithGoogle()
  static Future<void> signOutFromGoogle()
  
  // Timeout handling for better UX
  static const Duration signInTimeout = Duration(seconds: 30)
}
```

## 🌤️ Weather Service

### WeatherService
**Location**: `lib/Core/services/weather_service.dart`

**Purpose**: Real-time weather data integration with WeatherAPI

**API Integration**:
```dart
class WeatherService {
  static const String baseUrl = 'http://api.weatherapi.com/v1';
  static const String apiKey = 'YOUR_API_KEY';
  
  // Current Weather
  Future<Map<String, dynamic>> getCurrentWeather({
    required double latitude,
    required double longitude,
  })
  
  // Weather Forecast
  Future<Map<String, dynamic>> getWeatherForecast({
    required double latitude,
    required double longitude,
    int days = 3,
  })
}
```

**Data Structure**:
```dart
{
  'location': {
    'name': 'City Name',
    'region': 'State/Region',
    'country': 'Country',
    'lat': 0.0,
    'lon': 0.0,
  },
  'current': {
    'temp_c': 25.0,
    'condition': {
      'text': 'Partly cloudy',
      'icon': 'weather_icon_url',
    },
    'humidity': 65,
    'wind_kph': 10.5,
    'vis_km': 15.0,
  }
}
```

**Error Handling**:
- Network connectivity checks
- API rate limiting handling
- Fallback weather data
- Graceful degradation

## 🛡️ Safety Data Service

### SafetyDataService
**Location**: `lib/Core/services/safety_data_service.dart`

**Purpose**: Real-time safety monitoring and incident management

**Real-time Safety Status**:
```dart
class SafetyDataService {
  // Safety Monitoring
  static Stream<Map<String, dynamic>> getSafetyStatusStream({String? category})
  
  // Incident Reporting
  static Future<Map<String, dynamic>> reportIncident({
    required String type,
    required String description,
    String? category,
    File? image,
  })
  
  // SOS Alerts
  static Future<Map<String, dynamic>> triggerSOS({String category = 'general'})
  static Future<bool> deactivateSOS(String sosId)
  
  // Location Tracking
  static void _startLocationTracking(String sosId)
  static void _stopLocationTracking()
}
```

**Safety Status Calculation**:
```dart
Map<String, dynamic> _calculateSafetyStatus(
  List<Map<String, dynamic>> incidents,
  Position position,
  String? category,
) {
  // Algorithm factors:
  // - Number of recent incidents (24 hours)
  // - Distance from incidents
  // - Incident severity
  // - Time of day
  // - Weather conditions
  
  final riskLevel = _assessRiskLevel(incidents, position);
  return {
    'status': riskLevel,
    'riskLevel': _getRiskDescription(riskLevel),
    'incidentCount': incidents.length,
    'lastUpdated': DateTime.now(),
  };
}
```

**SOS Alert System**:
```dart
// SOS Data Structure
{
  'userId': 'user_id',
  'userEmail': 'user@email.com',
  'timestamp': FieldValue.serverTimestamp(),
  'type': 'sos',
  'category': 'harassment|disaster|general',
  'status': 'active',
  'urgency': 'critical',
  'latitude': 0.0,
  'longitude': 0.0,
  'accuracy': 5.0,
  'responseRequested': true,
}
```

## 🗄️ Data Management Services

### Firestore Collections Structure

**Users Collection** (`users`):
```dart
{
  'fullName': 'User Name',
  'email': 'user@email.com',
  'phone': '+1234567890',
  'createdAt': Timestamp,
  'isActive': true,
  'profileImageUrl': 'optional_url',
}
```

**Emergency Reports Collection** (`emergency_reports`):
```dart
{
  'type': 'disaster|harassment',
  'description': 'Incident description',
  'userId': 'user_id',
  'userEmail': 'user@email.com',
  'timestamp': Timestamp,
  'status': 'active|resolved|investigating',
  'location': GeoPoint,
  'disasterType': 'flood|fire|earthquake|etc', // for disasters
  'gender': 'male|female|other', // for harassment
  'imageUrl': 'optional_image_url',
}
```

**Safety Incidents Collection** (`safety_incidents`):
```dart
{
  'userId': 'user_id',
  'userEmail': 'user@email.com',
  'timestamp': Timestamp,
  'type': 'incident|sos|report',
  'category': 'disaster|harassment|general',
  'description': 'Description',
  'latitude': 0.0,
  'longitude': 0.0,
  'severity': 'low|medium|high|critical',
  'status': 'active|resolved',
}
```

**SOS Alerts Collection** (`sos_alerts`):
```dart
{
  'userId': 'user_id',
  'userEmail': 'user@email.com',
  'timestamp': Timestamp,
  'type': 'sos',
  'category': 'harassment|disaster|general',
  'status': 'active|deactivated|resolved',
  'urgency': 'critical',
  'latitude': 0.0,
  'longitude': 0.0,
  'accuracy': 5.0,
  'responseRequested': true,
  'responseTime': Timestamp, // when help arrived
}
```

## 📍 Location Services

### Geolocator Integration
```dart
// Location Permissions
Future<LocationPermission> _checkLocationPermission()
Future<Position?> _getCurrentLocation()

// Location Settings
const LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 10, // meters
);

// Location Streaming
Stream<Position> getPositionStream() {
  return Geolocator.getPositionStream(
    locationSettings: locationSettings,
  );
}
```

**Privacy Controls**:
- User permission management
- Location sharing preferences
- Emergency-only location access
- Location data encryption

## 🔄 Service Communication Patterns

### Service-to-Service Communication
```dart
// Weather + Safety Integration
final weatherData = await WeatherService.getCurrentWeather(
  latitude: position.latitude,
  longitude: position.longitude,
);

final safetyStatus = await SafetyDataService.getSafetyStatus(
  position: position,
  weather: weatherData,
);
```

### Error Propagation
```dart
// Standardized Error Response
{
  'success': false,
  'message': 'Human-readable error message',
  'errorCode': 'ERROR_CODE',
  'details': 'Technical details for debugging',
}
```

### Service Health Monitoring
```dart
class ServiceHealth {
  static Future<Map<String, bool>> checkAllServices() async {
    return {
      'firebase': await _checkFirebaseConnection(),
      'weather': await _checkWeatherAPI(),
      'location': await _checkLocationServices(),
      'network': await _checkNetworkConnectivity(),
    };
  }
}
```

## 🔒 Security Implementation

### Data Encryption
- **In Transit**: HTTPS/TLS for all API communications
- **At Rest**: Firebase native encryption
- **Local Storage**: SharedPreferences encryption
- **File Storage**: Firebase Storage encryption

### Authentication Security
- **Password Requirements**: Minimum 6 characters
- **Session Management**: Secure token handling
- **Multi-provider Support**: Email, Google
- **Account Lockout**: Protection against brute force

### Privacy Protection
- **Data Minimization**: Collect only necessary data
- **User Consent**: Explicit permission for data usage
- **Right to Deletion**: Complete account and data removal
- **Anonymization**: Optional anonymous reporting

---

Next: [Data Flow Documentation](./05-data-flow.md)
