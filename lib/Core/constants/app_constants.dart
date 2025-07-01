class AppConstants {
  // App Info
  static const String appName = 'SafeCom';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Emergency Reporting System';

  // Emergency Response Times
  static const int sosResponseTimeMs = 200;
  static const int emergencyTimeoutSeconds = 30;
  static const int locationUpdateIntervalSeconds = 10;

  // Storage Keys
  static const String userLoginKey = 'user_logged_in';
  static const String userDataKey = 'user_data';
  static const String locationPermissionKey = 'location_permission';
  static const String notificationPermissionKey = 'notification_permission';

  // Emergency Types
  static const String harassmentType = 'harassment';
  static const String disasterType = 'disaster';
  static const String medicalType = 'medical';
  static const String fireType = 'fire';
  static const String policeType = 'police';

  // Emergency Contact Numbers (Sri Lanka)
  static const String policeNumber = '0772321706';
  static const String fireServiceNumber = '0772321706';
  static const String ambulanceNumber = '0772321706';
  static const String emergencyNumber = '0772321706';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int otpLength = 6;
  static const int phoneOtpLength = 4;

  // Network
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;

  // Location
  static const double defaultLatitude = 6.9271; // Colombo
  static const double defaultLongitude = 79.8612; // Colombo
  static const double locationAccuracyMeters = 10.0;

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double buttonHeight = 48.0;
  static const double sosButtonSize = 120.0;
}
