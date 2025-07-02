import 'package:flutter/material.dart';
import 'package:safecom_final/Core/navigation/app_routes.dart';
import 'package:safecom_final/features/onboarding/presentation/pages/splash_screen.dart';
import 'package:safecom_final/features/onboarding/presentation/pages/second_screen.dart';
import 'package:safecom_final/features/onboarding/presentation/pages/first_screen.dart';
import 'package:safecom_final/features/home/presentation/pages/harass_home.dart';
import 'package:safecom_final/features/home/presentation/pages/disaster_home.dart';

import 'package:safecom_final/features/authentication/presentation/pages/sign_in.dart';
import 'package:safecom_final/features/authentication/presentation/pages/signup_screen.dart';
import 'package:safecom_final/features/profile/presentation/pages/personal_edit.dart';
import 'package:safecom_final/features/profile/presentation/pages/profile_edit.dart';
import 'package:safecom_final/features/profile/presentation/pages/security_privacy.dart';
import 'package:safecom_final/features/tips/presentation/pages/tips_main.dart';
import 'package:safecom_final/features/tips/presentation/pages/tips_detail.dart';
import 'package:safecom_final/features/reporting/presentation/pages/disaster_report_page.dart';
import 'package:safecom_final/features/reporting/presentation/pages/harassment_report_page.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint('Generating route for: ${settings.name}');

    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.firstScreen:
        return MaterialPageRoute(
          builder:
              (_) =>
                  FirstScreen(fadeAnimation: const AlwaysStoppedAnimation(1.0)),
        );

      case AppRoutes.secondScreen:
        return MaterialPageRoute(
          builder:
              (_) => SecondScreen(
                fadeAnimation: const AlwaysStoppedAnimation(1.0),
              ),
        );

      case AppRoutes.signIn:
        return MaterialPageRoute(builder: (_) => const SignInScreen());

      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case AppRoutes.homeHarass:
        debugPrint('🏠 Creating HarassHome route');
        return MaterialPageRoute(builder: (_) => const HarassHome());

      case AppRoutes.homeDisaster:
        return MaterialPageRoute(builder: (_) => const DisasterHome());

      case AppRoutes.tips:
        final category = settings.arguments as String? ?? 'harassment';
        return MaterialPageRoute(
          builder: (_) => TipsMain(initialCategory: category),
        );

      case AppRoutes.tipsDetail:
        return MaterialPageRoute(builder: (_) => const TipsDetail());

      case AppRoutes.personalEdit:
        return MaterialPageRoute(builder: (_) => const PersonalInfoContent());

      case AppRoutes.personalInfo:
        return MaterialPageRoute(builder: (_) => const PersonalInfoContent());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const EditProfileContent());

      case AppRoutes.securityPrivacy:
        return MaterialPageRoute(builder: (_) => const SecurityPrivacyScreen());

      case AppRoutes.disasterReport:
        return MaterialPageRoute(builder: (_) => const DisasterReport());

      case AppRoutes.harassmentReport:
        return MaterialPageRoute(builder: (_) => const HarassmentReport());

      default:
        debugPrint('No route defined for ${settings.name}');
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }

  // Basic navigation helpers
  static Future<dynamic>? push(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  static Future<dynamic>? pushReplacement(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState?.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  static void pop([Object? result]) {
    navigatorKey.currentState?.pop(result);
  }

  static Future<dynamic>? pushAndClearStack(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static bool canPop() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  static void popUntil(String routeName) {
    navigatorKey.currentState?.popUntil(ModalRoute.withName(routeName));
  }
}

/// This class defines routes, handles navigation actions, and provides a centralized way to manage screen transitions.
