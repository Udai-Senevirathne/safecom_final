# 2. Architecture Overview

## 🏗️ Clean Architecture Implementation

SafeCom follows Clean Architecture principles, ensuring separation of concerns, testability, and maintainability. The architecture is organized into distinct layers with clear dependencies.

## 📁 Project Structure

```
lib/
├── main.dart                      # Application entry point
├── Core/                          # Core utilities and infrastructure
│   ├── dependency_injection/      # Service locator (GetIt)
│   ├── navigation/               # Custom navigation system
│   ├── services/                 # Infrastructure services
│   ├── constants/                # App-wide constants
│   ├── errors/                   # Error handling
│   └── utils/                    # Utility functions
├── features/                     # Feature-based organization (Clean Architecture)
│   ├── authentication/           # Authentication feature
│   │   ├── domain/              # Business logic layer
│   │   │   ├── entities/        # Business objects
│   │   │   ├── repositories/    # Repository contracts
│   │   │   └── usecases/        # Business use cases
│   │   ├── data/                # Data layer
│   │   │   ├── datasources/     # Data sources (remote/local)
│   │   │   ├── models/          # Data models
│   │   │   └── repositories/    # Repository implementations
│   │   └── presentation/        # Presentation layer
│   │       ├── bloc/            # BLoC state management
│   │       ├── pages/           # UI pages (sign_in.dart, signup_screen.dart)
│   │       └── widgets/         # Reusable widgets
│   ├── home/                    # Home/Dashboard features
│   │   └── presentation/
│   │       └── pages/           # Home screens (harass_home.dart, disaster_home.dart)
│   ├── onboarding/              # App onboarding flow
│   │   └── presentation/
│   │       └── pages/           # Onboarding screens (splash_screen.dart, first_screen.dart, second_screen.dart)
│   ├── profile/                 # User profile management
│   │   └── presentation/
│   │       └── pages/           # Profile screens (profile_edit.dart, personal_edit.dart, security_privacy.dart)
│   ├── tips/                    # Safety tips feature
│   │   └── presentation/
│   │       ├── pages/           # Tips screens (tips_main.dart, tips_detail.dart)
│   │       └── widgets/         # Tips widgets (swipeable_tips_popup.dart)
│   ├── reporting/               # Incident reporting
│   ├── safety/                  # Safety monitoring
│   └── weather/                 # Weather integration
├── shared/                      # Shared components
│   ├── theme/                   # App theming
│   └── widgets/                 # Common widgets
```

## 🔄 Clean Architecture Layers

### 1. Domain Layer (Business Logic)
**Location**: `lib/features/{feature}/domain/`

**Components**:
- **Entities**: Core business objects
- **Repositories**: Abstract contracts for data access
- **Use Cases**: Business rules and operations

**Example**:
```dart
// Entity
class User {
  final String id;
  final String name;
  final String email;
}

// Repository Contract
abstract class AuthRepository {
  Future<Result<User>> signIn(String email, String password);
}

// Use Case
class SignInUseCase {
  Future<Result<User>> call(String email, String password) {
    return repository.signIn(email, password);
  }
}
```

### 2. Data Layer (Data Management)
**Location**: `lib/features/{feature}/data/`

**Components**:
- **Data Sources**: Remote (Firebase) and Local (SharedPreferences)
- **Models**: Data transfer objects
- **Repository Implementations**: Concrete data access

**Example**:
```dart
// Data Source
class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
}

// Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Result<User>> signIn(String email, String password) {
    // Implementation using data sources
  }
}
```

### 3. Presentation Layer (UI & State)
**Location**: `lib/features/{feature}/presentation/`

**Components**:
- **BLoC**: State management
- **Pages**: UI screens
- **Widgets**: UI components

## 🎯 BLoC Pattern Implementation

### State Management Architecture
```dart
// Events
abstract class AuthEvent {}
class AuthSignInRequested extends AuthEvent {
  final String email, password;
}

// States
abstract class AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final User user;
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  
  AuthBloc({required this.signInUseCase}) : super(AuthInitial()) {
    on<AuthSignInRequested>(_onSignInRequested);
  }
}
```

## 📋 Current Feature Implementation Status

### Fully Migrated Features (Clean Architecture)
The following features have been successfully migrated to the new clean architecture structure:

1. **Authentication** (`lib/features/authentication/presentation/pages/`)
   - `sign_in.dart` - User sign-in screen
   - `signup_screen.dart` - User registration screen

2. **Onboarding** (`lib/features/onboarding/presentation/pages/`)
   - `splash_screen.dart` - App splash screen
   - `first_screen.dart` - Onboarding welcome screen
   - `second_screen.dart` - Onboarding tutorial screen

3. **Home/Dashboard** (`lib/features/home/presentation/pages/`)
   - `harass_home.dart` - Harassment reporting dashboard
   - `disaster_home.dart` - Disaster reporting dashboard

4. **Profile Management** (`lib/features/profile/presentation/pages/`)
   - `profile_edit.dart` - Main profile editing screen
   - `personal_edit.dart` - Personal information editing
   - `security_privacy.dart` - Security and privacy settings

5. **Safety Tips** (`lib/features/tips/`)
   - `presentation/pages/tips_main.dart` - Tips main screen
   - `presentation/pages/tips_detail.dart` - Detailed tips view
   - `presentation/widgets/swipeable_tips_popup.dart` - Interactive tips widget

### Existing Features (Legacy Structure)
The following features maintain their current structure under the features directory:

- **Reporting** (`lib/features/reporting/`) - Incident reporting functionality
- **Safety** (`lib/features/safety/`) - Safety monitoring and alerts
- **Weather** (`lib/features/weather/`) - Weather integration services

All navigation has been updated to reference the new file locations, ensuring seamless operation.

## 🔧 Dependency Injection

### Service Locator Pattern (GetIt)
**Location**: `lib/core/dependency_injection/service_locator.dart`

**Structure**:
```dart
final sl = GetIt.instance;

Future<void> init() async {
  // Use Cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl())
  );
  
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl()
  );
  
  // BLoCs
  sl.registerFactory(() => AuthBloc(signInUseCase: sl()));
  
  // Services
  sl.registerLazySingleton(() => WeatherService());
}
```

## 🗂️ Core Services Architecture

### Infrastructure Services
**Location**: `lib/Core/services/`

1. **FirebaseService**: Firebase integration (Auth, Firestore, Storage)
2. **AuthService**: Local authentication management
3. **WeatherService**: Weather API integration
4. **SafetyDataService**: Real-time safety data management
5. **GoogleSignInService**: Google authentication

### Service Characteristics
- **Singleton Pattern**: Single instance per service
- **Interface Abstraction**: Clean separation of concerns
- **Error Handling**: Comprehensive error management
- **Async Operations**: Future/Stream based operations

## 🚦 Navigation Architecture

### Custom Navigation System
**Location**: `lib/Core/navigation/`

**Components**:
```dart
// Route Definitions (app_routes.dart)
class AppRoutes {
  static const String splash = '/';
  static const String firstScreen = '/first_screen';
  static const String secondScreen = '/second_screen';
  static const String signIn = '/sign_in';
  static const String signUp = '/sign_up';
  static const String homeDisaster = '/home_disaster';
  static const String homeHarass = '/home_harass';
  static const String profileEdit = '/profile_edit';
  static const String personalEdit = '/personal_edit';
  static const String securityPrivacy = '/security_privacy';
  static const String tipsMain = '/tips_main';
  static const String tipsDetail = '/tips_detail';
}

// Navigation Logic (appnavigator.dart)
class AppNavigator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      case AppRoutes.signIn:
        return MaterialPageRoute(
          builder: (_) => const SignInScreen(),
        );
      case AppRoutes.homeDisaster:
        return MaterialPageRoute(
          builder: (_) => const DisasterHomeScreen(),
        );
      // ... other routes
    }
  }
}
```

### Migration Status
All navigation routes have been successfully updated to reference the new feature-based file structure. The legacy `Screens/` directory references have been completely removed and replaced with feature-specific imports from `lib/features/`.

## 🎨 Theme Architecture

### Centralized Theming
**Location**: `lib/shared/theme/`

**Structure**:
- **AppTheme**: Main theme configuration
- **Colors**: Color palette definitions
- **Typography**: Text styles
- **Component Themes**: Widget-specific themes

## 🔐 Security Architecture

### Data Protection Layers
1. **Firebase Security Rules**: Server-side data protection
2. **Authentication**: Multi-provider auth (Email, Google)
3. **Local Storage**: Encrypted local data storage
4. **Network Security**: HTTPS/TLS communication
5. **Privacy Controls**: User-controlled data sharing

## 🔄 Data Flow Architecture

### Request Flow
```
UI → BLoC → Use Case → Repository → Data Source → Firebase
```

### Response Flow
```
Firebase → Data Source → Repository → Use Case → BLoC → UI
```

### Real-time Data Flow
```
Firebase Streams → Service → BLoC → UI (Auto-update)
```

## 📊 Error Handling Architecture

### Structured Error Management
```dart
// Result Pattern
abstract class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final Failure failure;
  const Failure(this.failure);
}
```

## 🚀 Scalability Considerations

### Modular Design
- **Feature-based**: Each feature is independent
- **Plugin Architecture**: Easy addition of new features
- **Microservices Ready**: Services can be extracted
- **Multi-platform**: Supports multiple Flutter targets

### Performance Optimizations
- **Lazy Loading**: Services loaded on demand
- **Caching**: Local data caching strategies
- **Pagination**: Large data set handling
- **Background Processing**: Non-blocking operations

---

Next: [Features Documentation](./03-features.md)
