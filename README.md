# SafeCom - Community Safety & Emergency Response App

SafeCom is a comprehensive Flutter-based mobile application designed to enhance community safety through real-time reporting, weather monitoring, and emergency response coordination. The app empowers users to report incidents, access safety tips, and stay informed about local safety conditions.

## 🌟 Features

### Core Functionality
- **🚨 Incident Reporting**: Report harassment and disaster incidents with location data
- **🌤️ Weather Integration**: Real-time weather monitoring and alerts
- **🛡️ Safety Tips**: Access comprehensive safety guidelines and tips
- **👤 User Profile Management**: Secure user authentication and profile customization
- **📍 Location Services**: GPS-based incident reporting and weather data
- **🔔 Push Notifications**: Real-time alerts and safety notifications

### Authentication & Security
- **Multi-provider Authentication**: Email/password and Google Sign-In
- **Firebase Integration**: Secure cloud storage and real-time database
- **Privacy Controls**: User-controlled data sharing and privacy settings
- **Secure Data Storage**: Encrypted local and cloud data storage

## 🏗️ Architecture

SafeCom follows **Clean Architecture** principles with feature-based organization:

```
lib/
├── Core/                    # Core utilities and services
│   ├── dependency_injection/
│   ├── navigation/
│   ├── services/
│   └── utils/
├── features/               # Feature-based modules
│   ├── authentication/    # User auth & registration
│   ├── home/             # Dashboard screens
│   ├── onboarding/       # App introduction flow
│   ├── profile/          # User profile management
│   ├── tips/             # Safety tips & guidelines
│   ├── reporting/        # Incident reporting
│   ├── safety/           # Safety monitoring
│   └── weather/          # Weather integration
└── shared/               # Shared components & themes
```

### State Management
- **BLoC Pattern**: Reactive state management with flutter_bloc
- **Dependency Injection**: Service locator pattern with GetIt
- **Clean Architecture**: Separation of concerns across domain, data, and presentation layers

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/safecom_final.git
   cd safecom_final
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Add your `google-services.json` to `android/app/`
   - Add your `GoogleService-Info.plist` to `ios/Runner/`
   - Configure Firebase Authentication, Firestore, and Cloud Messaging

4. **Run the app**
   ```bash
   flutter run
   ```

### Build Configuration
- **Development**: `flutter run --debug`
- **Production**: `flutter build apk --release`
- **iOS**: `flutter build ios --release`

## 📚 Documentation

Comprehensive documentation is available in the `docs/` folder:

- **[01-Overview](docs/01-overview.md)**: Project overview and objectives
- **[02-Architecture](docs/02-architecture.md)**: Clean architecture implementation
- **[03-Features](docs/03-features.md)**: Detailed feature descriptions
- **[04-Services](docs/04-services.md)**: Core services and integrations
- **[05-Data Flow](docs/05-data-flow.md)**: Data architecture and flow
- **[06-Security & Privacy](docs/06-security-privacy.md)**: Security measures
- **[07-Setup & Installation](docs/07-setup-installation.md)**: Detailed setup guide
- **[08-API Reference](docs/08-api-reference.md)**: API documentation
- **[09-Function Documentation](docs/09-function-documentation.md)**: Code reference

## 🛠️ Technical Stack

### Frontend
- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language
- **BLoC**: State management
- **Material Design**: UI/UX framework

### Backend & Services
- **Firebase Auth**: User authentication
- **Cloud Firestore**: NoSQL database
- **Firebase Storage**: File storage
- **Firebase Messaging**: Push notifications
- **Google Maps API**: Location services
- **Weather API**: Weather integration

### Development Tools
- **GetIt**: Dependency injection
- **Dio**: HTTP client
- **Geolocator**: Location services
- **Image Picker**: Media handling
- **Shared Preferences**: Local storage

## 🎯 Project Status

### Recent Migration (2025)
The project has undergone a major architectural refactoring:
- ✅ Migrated from legacy `Screens/` structure to feature-based Clean Architecture
- ✅ Implemented BLoC pattern for state management
- ✅ Updated all navigation and import paths
- ✅ Reorganized code into domain, data, and presentation layers
- ✅ Updated documentation to reflect new structure

### Current Features Status
- **Authentication**: ✅ Complete (Sign-in, Sign-up, Google Auth)
- **Onboarding**: ✅ Complete (Splash, Welcome screens)
- **Home Dashboard**: ✅ Complete (Disaster & Harassment reporting)
- **Profile Management**: ✅ Complete (Edit profile, Security settings)
- **Safety Tips**: ✅ Complete (Tips display, Detailed views)
- **Weather Integration**: 🔄 In Development
- **Incident Reporting**: 🔄 In Development
- **Safety Monitoring**: 🔄 In Development

### Code Standards
- Follow Dart/Flutter style guidelines
- Implement Clean Architecture principles
- Write comprehensive tests
- Document all public APIs
- Use BLoC for state management

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Check the [documentation](docs/)
- Review the [API reference](docs/08-api-reference.md)

## 🎉 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Community contributors and testers
- Open source packages and libraries used in this project
