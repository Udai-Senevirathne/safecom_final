# 9. Function Documentation

## 🔍 Function Reference Guide

This document provides detailed explanations of all important functions implemented in the SafeCom Emergency Reporting System. Each function is documented with its purpose, parameters, return values, and usage examples.

## 📋 Table of Contents

1. [Authentication Functions](#authentication-functions)
2. [Firebase Service Functions](#firebase-service-functions)
3. [Weather Service Functions](#weather-service-functions)
4. [Safety Data Service Functions](#safety-data-service-functions)
5. [Location Service Functions](#location-service-functions)
6. [UI Helper Functions](#ui-helper-functions)
7. [Navigation Functions](#navigation-functions)
8. [Utility Functions](#utility-functions)
9. [BLoC Functions](#bloc-functions)
10. [Security Functions](#security-functions)

---

## 🔐 Authentication Functions

### AuthService Functions

#### `signUp(String name, String email, String phone, String password)`
**Purpose**: Register a new user with local authentication storage

**Parameters**:
- `name` (String): User's full name
- `email` (String): User's email address
- `phone` (String): User's phone number
- `password` (String): User's password

**Returns**: `Future<bool>` - Success status

**Implementation Details**:
```dart
static Future<bool> signUp(
  String name,
  String email,
  String phone,
  String password,
) async {
  try {
    // Validate inputs
    if (name.trim().isEmpty) return false;
    if (email.trim().isEmpty) return false;
    if (phone.trim().isEmpty) return false;
    if (password.isEmpty) return false;

    // Initialize storage
    await _initStorage();

    // Save user data using robust storage
    final loginResult = await _setValue(_keyIsLoggedIn, true);
    final nameResult = await _setValue(_keyUserName, name.trim());
    final emailResult = await _setValue(_keyUserEmail, email.trim());
    final phoneResult = await _setValue(_keyUserPhone, phone.trim());

    if (loginResult && nameResult && emailResult && phoneResult) {
      // Notify listeners about the new user
      final userData = await getUserData();
      _userDataController.add(userData);
      return true;
    }
    
    return false;
  } catch (e) {
    debugPrint('Sign up error: $e');
    return false;
  }
}
```

**Usage Example**:
```dart
final success = await AuthService.signUp(
  'John Doe',
  'john@example.com',
  '+1234567890',
  'securepassword',
);

if (success) {
  // Navigate to home screen
} else {
  // Show error message
}
```

#### `signIn(String identifier, String password)`
**Purpose**: Authenticate existing user with email or phone

**Parameters**:
- `identifier` (String): Email address or phone number
- `password` (String): User's password

**Returns**: `Future<bool>` - Authentication success status

**Logic Flow**:
1. Validate input parameters
2. Initialize storage system
3. Determine if identifier is email or phone
4. Save authentication state
5. Notify listeners of successful sign-in

#### `signOut()`
**Purpose**: Sign out current user and clear session data

**Returns**: `Future<void>`

**Implementation**:
```dart
static Future<void> signOut() async {
  try {
    await _initStorage();
    await _setValue(_keyIsLoggedIn, false);

    if (_useMemoryStorage) {
      _memoryStorage.remove(_keyUserName);
      _memoryStorage.remove(_keyUserEmail);
      _memoryStorage.remove(_keyUserPhone);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyUserPhone);
    }

    // Notify listeners about sign out
    _userDataController.add({'name': null, 'email': null, 'phone': null});
  } catch (e) {
    debugPrint('Sign out error: $e');
  }
}
```

#### `getUserData()`
**Purpose**: Retrieve current user's stored data

**Returns**: `Future<Map<String, String?>>` - User data map

**Data Structure**:
```dart
{
  'name': String?,
  'email': String?,
  'phone': String?,
}
```

#### `clearUserData()`
**Purpose**: Complete data clearing for account deletion

**Returns**: `Future<bool>` - Success status

**Clears**:
- User profile data (name, email, phone)
- Login status
- App preferences (notifications, privacy settings)
- Gender selection
- All locally stored user data

---

## 🔥 Firebase Service Functions

### User Authentication Functions

#### `signUp({required String email, required String password, required String fullName, required String phone})`
**Purpose**: Create Firebase authentication account and user profile

**Implementation Flow**:
```dart
static Future<Map<String, dynamic>> signUp({
  required String email,
  required String password,
  required String fullName,
  required String phone,
}) async {
  try {
    // Create user account
    UserCredential userCredential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);

    // Save user profile to Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });

    // Save login status and user data locally
    await AuthService.setLoginStatus(true);
    await AuthService.saveUserData(fullName, email, phone);

    return {
      'success': true,
      'message': 'Account created successfully',
      'user': userCredential.user,
    };
  } on FirebaseAuthException catch (e) {
    return {'success': false, 'message': _getAuthErrorMessage(e.code)};
  } catch (e) {
    return {
      'success': false,
      'message': 'An error occurred. Please try again.',
    };
  }
}
```

#### `deleteUserAccount()`
**Purpose**: Permanently delete user account and all associated data

**Deletion Process**:
1. **Emergency Reports**: Delete from 'emergency_reports' collection
2. **Safety Incidents**: Delete from 'safety_incidents' collection  
3. **SOS Alerts**: Delete from 'sos_alerts' collection
4. **User Profile**: Delete from 'users' collection
5. **Storage Files**: Delete all user files from Firebase Storage
6. **Local Data**: Clear all locally stored data
7. **External Accounts**: Disconnect Google Sign-In if applicable
8. **Auth Account**: Delete Firebase Auth account

**Error Handling**: Handles re-authentication requirements and provides detailed error messages

### Emergency Report Functions

#### `submitEmergencyReport({required String type, required String description, String? selectedOption, String? location, File? image})`
**Purpose**: Submit emergency incident report to Firestore

**Parameters**:
- `type` (String): 'disaster' or 'harassment'
- `description` (String): Detailed incident description
- `selectedOption` (String?): Disaster type or gender for harassment
- `location` (String?): Custom location description
- `image` (File?): Optional image attachment

**Implementation Logic**:
```dart
static Future<Map<String, dynamic>> submitEmergencyReport({
  required String type,
  required String description,
  String? selectedOption,
  String? location,
  File? image,
}) async {
  try {
    User? user = _auth.currentUser;
    if (user == null) {
      return {
        'success': false,
        'message': 'Please sign in to submit a report',
      };
    }

    Map<String, dynamic> reportData = {
      'type': type,
      'description': description,
      'userId': user.uid,
      'userEmail': user.email,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'active',
      'location': location,
    };

    // Add type-specific data
    if (type == 'disaster') {
      reportData['disasterType'] = selectedOption;
    } else if (type == 'harassment') {
      reportData['gender'] = selectedOption;
    }

    // Upload image if provided
    if (image != null) {
      String imageUrl = await _uploadReportImage(image, type);
      reportData['imageUrl'] = imageUrl;
    }

    // Save to Firestore
    DocumentReference docRef = await _firestore
        .collection('emergency_reports')
        .add(reportData);

    return {
      'success': true,
      'message': 'Report submitted successfully',
      'reportId': docRef.id,
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Failed to submit report. Please try again.',
    };
  }
}
```

#### `_uploadReportImage(File image, String reportType)`
**Purpose**: Upload image attachment to Firebase Storage

**Parameters**:
- `image` (File): Image file to upload
- `reportType` (String): Type of report for file organization

**Returns**: `Future<String>` - Download URL of uploaded image

**File Naming**: `{timestamp}_{reportType}.jpg`

---

## 🌤️ Weather Service Functions

#### `getCurrentWeather({required double latitude, required double longitude})`
**Purpose**: Fetch current weather data for specified coordinates

**API Integration**: WeatherAPI.com

**Implementation**:
```dart
Future<Map<String, dynamic>> getCurrentWeather({
  required double latitude,
  required double longitude,
}) async {
  try {
    final url = '$baseUrl/current.json?key=$apiKey&q=$latitude,$longitude&aqi=no';
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw WeatherException('Failed to fetch weather data');
    }
  } catch (e) {
    throw WeatherException('Weather service error: $e');
  }
}
```

**Response Data Structure**:
```dart
{
  'location': {
    'name': 'City Name',
    'region': 'State/Region',
    'country': 'Country',
    'lat': double,
    'lon': double,
  },
  'current': {
    'temp_c': double,
    'temp_f': double,
    'condition': {
      'text': 'Weather condition',
      'icon': 'icon_url',
    },
    'humidity': int,
    'wind_kph': double,
    'vis_km': double,
  }
}
```

#### `getWeatherForecast({required double latitude, required double longitude, int days = 3})`
**Purpose**: Fetch weather forecast for specified location

**Parameters**:
- `days` (int): Number of forecast days (1-10, default: 3)

**Usage**: Future enhancement for weather-based safety alerts

---

## 🛡️ Safety Data Service Functions

#### `getSafetyStatusStream({String? category})`
**Purpose**: Provide real-time safety status based on recent incidents

**Parameters**:
- `category` (String?): Filter by 'disaster', 'harassment', or null for all

**Returns**: `Stream<Map<String, dynamic>>` - Real-time safety data

**Safety Calculation Algorithm**:
```dart
Map<String, dynamic> _calculateSafetyStatus(
  List<Map<String, dynamic>> incidents,
  Position position,
  String? category,
) {
  int highSeverityCount = 0;
  int totalIncidents = incidents.length;
  
  // Count high-severity incidents
  for (var incident in incidents) {
    if (incident['severity'] == 'high' || incident['severity'] == 'critical') {
      highSeverityCount++;
    }
  }
  
  // Determine risk level
  String riskLevel;
  if (totalIncidents == 0) {
    riskLevel = 'safe';
  } else if (highSeverityCount > 0 || totalIncidents > 5) {
    riskLevel = 'high_risk';
  } else if (totalIncidents > 2) {
    riskLevel = 'moderate';
  } else {
    riskLevel = 'safe';
  }
  
  return {
    'status': riskLevel,
    'riskLevel': _getRiskDescription(riskLevel),
    'incidentCount': totalIncidents,
    'lastUpdated': DateTime.now(),
    'location': 'Current Location',
    'message': _getSafetyMessage(riskLevel, totalIncidents),
  };
}
```

#### `triggerSOS({String category = 'general'})`
**Purpose**: Activate emergency SOS alert with location tracking

**Categories**: 'general', 'disaster', 'harassment'

**SOS Process Flow**:
1. Validate user authentication
2. Capture current location
3. Create SOS alert in 'sos_alerts' collection
4. Add to 'safety_incidents' for area monitoring
5. Start real-time location tracking
6. Return SOS ID for tracking

**Implementation**:
```dart
static Future<Map<String, dynamic>> triggerSOS({String category = 'general'}) async {
  try {
    User? user = _auth.currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Please sign in to use SOS'};
    }

    Position? position = await _getCurrentLocation();

    Map<String, dynamic> sosData = {
      'userId': user.uid,
      'userEmail': user.email,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'sos',
      'category': category,
      'status': 'active',
      'urgency': 'critical',
      'latitude': position?.latitude,
      'longitude': position?.longitude,
      'accuracy': position?.accuracy,
      'responseRequested': true,
    };

    DocumentReference sosRef = await _firestore
        .collection('sos_alerts')
        .add(sosData);

    // Also add to safety_incidents for area safety tracking
    await _firestore.collection('safety_incidents').add({
      ...sosData,
      'description': 'SOS Alert Triggered - ${category.toUpperCase()}',
      'type': 'emergency',
    });

    // Start real-time location tracking
    _startLocationTracking(sosRef.id);

    return {
      'success': true,
      'message': 'SOS Alert sent! Help is on the way.',
      'sosId': sosRef.id,
    };
  } catch (e) {
    return {'success': false, 'message': 'Failed to send SOS alert'};
  }
}
```

#### `_startLocationTracking(String sosId)`
**Purpose**: Begin continuous location updates for active SOS

**Tracking Features**:
- 30-second location updates
- High accuracy GPS
- Automatic stop when SOS deactivated
- Location history storage

#### `deactivateSOS(String sosId)`
**Purpose**: Stop active SOS alert and location tracking

**Deactivation Process**:
1. Update SOS status to 'deactivated'
2. Stop location tracking
3. Update safety incidents
4. Notify emergency services of resolution

---

## 📍 Location Service Functions

#### `_getCurrentLocation()`
**Purpose**: Get current device location with error handling

**Location Settings**:
```dart
const LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 10, // meters
  timeLimit: Duration(seconds: 10),
);
```

**Permission Handling**:
```dart
static Future<Position?> _getCurrentLocation() async {
  try {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Get location with timeout
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 10),
    );
  } catch (e) {
    print('Location error: $e');
    return null;
  }
}
```

#### `_checkLocationPermission()`
**Purpose**: Verify and request location permissions

**Permission Flow**:
1. Check if location services are enabled
2. Check current permission status
3. Request permission if needed
4. Handle denied/forever denied cases
5. Return permission status

---

## 🎨 UI Helper Functions

#### `_buildModernMenuItem({required String label, required String subtitle, required IconData icon, required Color iconColor, required VoidCallback onTap, bool isDestructive = false})`
**Purpose**: Create consistent menu items with modern styling

**Usage in Profile Screen**:
```dart
_buildModernMenuItem(
  label: 'Security & Privacy',
  subtitle: 'Manage your privacy settings',
  icon: Icons.security_outlined,
  iconColor: Colors.green,
  onTap: () {
    AppNavigator.push(AppRoutes.securityPrivacy);
  },
),
```

**Styling Features**:
- Consistent card design
- Icon color theming
- Destructive action styling
- Hover/tap effects

#### `_buildSectionHeader(String title)`
**Purpose**: Create consistent section headers in UI

**Implementation**:
```dart
Widget _buildSectionHeader(String title) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    ),
  );
}
```

#### `_buildSettingCard({required String title, required String subtitle, required IconData icon, required Color iconColor, required bool value, required Function(bool)? onChanged})`
**Purpose**: Create toggle setting cards for privacy controls

**Features**:
- Toggle switch integration
- Disabled state handling
- Consistent styling
- Icon theming

---

## 🧭 Navigation Functions

#### `generateRoute(RouteSettings settings)`
**Purpose**: Central route generation for app navigation

**Route Handling**:
```dart
static Route<dynamic> generateRoute(RouteSettings settings) {
  debugPrint('Generating route for: ${settings.name}');

  switch (settings.name) {
    case AppRoutes.splash:
      return MaterialPageRoute(builder: (_) => const SplashScreen());

    case AppRoutes.signIn:
      return MaterialPageRoute(builder: (_) => const SignInScreen());

    case AppRoutes.homeHarass:
      return MaterialPageRoute(builder: (_) => const HarassHome());

    case AppRoutes.securityPrivacy:
      return MaterialPageRoute(builder: (_) => const SecurityPrivacyScreen());

    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ),
      );
  }
}
```

#### `push(String routeName, {Object? arguments})`
**Purpose**: Navigate to new screen with optional arguments

#### `pushReplacement(String routeName, {Object? arguments})`
**Purpose**: Replace current screen with new screen

#### `pushAndClearStack(String routeName, {Object? arguments})`
**Purpose**: Navigate to screen and clear navigation stack (used for logout)

---

## 🔧 Utility Functions

#### `isValidEmail(String email)`
**Purpose**: Validate email format using regex

**Regex Pattern**: `r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'`

#### `isValidPhone(String phone)`
**Purpose**: Validate phone number format

**Regex Pattern**: `r'^\+?[\d\s\-\(\)]{10,}$'`

#### `isValidPassword(String password)`
**Purpose**: Validate password strength

**Requirements**: Minimum 6 characters (expandable for complex requirements)

#### `_getAuthErrorMessage(String errorCode)`
**Purpose**: Convert Firebase error codes to user-friendly messages

**Error Code Mapping**:
```dart
switch (errorCode) {
  case 'user-not-found':
    return 'No user found with this email address.';
  case 'wrong-password':
    return 'Incorrect password.';
  case 'email-already-in-use':
    return 'An account already exists with this email.';
  case 'weak-password':
    return 'Password should be at least 6 characters.';
  case 'invalid-email':
    return 'Please enter a valid email address.';
  case 'too-many-requests':
    return 'Too many attempts. Please try again later.';
  default:
    return 'An error occurred. Please try again.';
}
```

---

## 🏗️ BLoC Functions

### Weather BLoC Functions

#### `_onGetWeather(GetWeather event, Emitter<WeatherState> emit)`
**Purpose**: Handle weather data fetching events

**Event Processing Flow**:
```dart
Future<void> _onGetWeather(GetWeather event, Emitter<WeatherState> emit) async {
  emit(WeatherLoading());
  
  try {
    final position = await _getCurrentPosition();
    final weatherData = await weatherService.getCurrentWeather(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    
    emit(WeatherLoaded(Weather.fromMap(weatherData)));
  } catch (e) {
    emit(WeatherError(e.toString()));
  }
}
```

### Auth BLoC Functions

#### `_onSignUpRequested(AuthSignUpRequested event, Emitter<AuthState> emit)`
**Purpose**: Handle user registration through Clean Architecture

**Use Case Integration**:
```dart
Future<void> _onSignUpRequested(
  AuthSignUpRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());

  final result = await signUpUseCase(
    email: event.email,
    password: event.password,
    name: event.name,
    phone: event.phone,
  );

  result.fold(
    (failure) => emit(AuthError(failure.message)),
    (user) => emit(AuthSuccess(user)),
  );
}
```

---

## 🔒 Security Functions

#### `_performAccountDeletion()`
**Purpose**: Execute complete account deletion with user feedback

**Deletion Flow**:
```dart
Future<void> _performAccountDeletion() async {
  // Show loading dialog
  showDialog(/* loading UI */);

  try {
    // Perform real-time account deletion
    final result = await FirebaseService.deleteUserAccount();

    if (mounted) {
      Navigator.pop(context); // Close loading

      if (result['success']) {
        // Show success and navigate to sign-in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.signIn,
          (route) => false,
        );
      } else {
        // Handle errors (re-authentication, etc.)
        if (result['requiresReauth'] == true) {
          _showReauthenticationDialog();
        } else {
          // Show error message
        }
      }
    }
  } catch (e) {
    // Handle unexpected errors
  }
}
```

#### `_showReauthenticationDialog()`
**Purpose**: Handle Firebase re-authentication requirement for sensitive operations

**Re-auth Process**:
1. Explain re-authentication requirement
2. Sign out current user
3. Redirect to sign-in screen
4. Allow user to sign in again
5. Retry sensitive operation

---

## 🔄 Stream Management Functions

#### `userDataStream`
**Purpose**: Provide real-time user data updates across the app

**Stream Controller**: `StreamController<Map<String, String?>>.broadcast()`

**Usage**:
```dart
StreamBuilder<Map<String, String?>>(
  stream: AuthService.userDataStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final userData = snapshot.data!;
      return UserProfileWidget(userData: userData);
    }
    return CircularProgressIndicator();
  },
)
```

#### `getSafetyStatusStream()`
**Purpose**: Real-time safety status monitoring with location filtering

**Stream Features**:
- Real-time Firestore listeners
- Location-based filtering (5km radius)
- Category-specific monitoring
- Automatic risk calculation

---

## 🛠️ Dependency Injection Functions

#### `init()`
**Purpose**: Initialize all application dependencies using GetIt

**Registration Order**:
```dart
Future<void> init() async {
  // External dependencies
  sl.registerLazySingleton(() => http.Client());
  
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  
  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  
  // BLoCs
  sl.registerFactory(() => AuthBloc(
    signInUseCase: sl(),
    signUpUseCase: sl(),
    signOutUseCase: sl(),
  ));
  
  // Services
  sl.registerLazySingleton(() => WeatherService());
  sl.registerLazySingleton(() => SafetyDataService());
}
```

---

This comprehensive function documentation covers all major functions in the SafeCom application, providing developers with detailed understanding of implementation, usage patterns, and integration points. Each function is explained with its purpose, parameters, return values, and practical examples.
