class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Splash and Onboarding
  static const String splash = '/';
  static const String firstScreen = '/first';
  static const String secondScreen = '/second';

  // Authentication
  static const String signIn = '/sign_in';
  static const String signup = '/signup';

  // Home Screens
  static const String homeHarass = '/home_harass';
  static const String homeDisaster = '/home_disaster';

  // Tips
  static const String tips = '/tips';
  static const String tipsDetail = '/tips_detail';

  // Profile & Settings
  static const String profile = '/profile';
  static const String personalInfo = '/personal_info';
  static const String personalEdit = '/personal_edit';
  static const String securityPrivacy = '/security_privacy';
  static const String settings = '/settings';

  // Reports
  static const String disasterReport = '/disaster_report';
  static const String harassmentReport = '/harassment_report';

  // Utility method to get all routes
  static List<String> getAllRoutes() {
    return [
      splash,
      firstScreen,
      secondScreen,
      signIn,
      signup,
      homeHarass,
      homeDisaster,
      tips,
      tipsDetail,
      profile,
      personalInfo,
      personalEdit,
      securityPrivacy,
      settings,
      disasterReport,
      harassmentReport,
    ];
  }
}
