import 'package:flutter/material.dart';
import 'package:safecom_final/Core/navigation/app_routes.dart';
import 'package:safecom_final/Screens/Splash_screen/splash_screen.dart';
import 'package:safecom_final/Screens/Second_screen/second_screen.dart';
import 'package:safecom_final/Screens/First_screen/first_screen.dart';
import 'package:safecom_final/Screens/auth/login_page.dart';
import 'package:safecom_final/Screens/home/harass_home.dart';
import 'package:safecom_final/Screens/home/disaster_home.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint('Generating route for: ${settings.name}');
    
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.firstScreen:
        return MaterialPageRoute(builder: (_) => const FirstScreen());
      case AppRoutes.secondScreen:
        return MaterialPageRoute(builder: (_) => const SecondScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.homeHarass:
        return MaterialPageRoute(builder: (_) => const HarassHome());
      case AppRoutes.homeDisaster:
        return MaterialPageRoute(builder: (_) => const DisasterHome());
      default:
        debugPrint('No route defined for ${settings.name}');
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static Future<dynamic>? push(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic>? pushReplacement(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushReplacementNamed(routeName, arguments: arguments);
  }

  static void pop([Object? result]) {
    navigatorKey.currentState?.pop(result);
  }
}

