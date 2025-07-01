import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safecom_final/Core/navigation/appnavigator.dart';
import 'package:safecom_final/Core/navigation/app_routes.dart';
import 'package:safecom_final/shared/theme/app_theme.dart';
import 'package:safecom_final/core/dependency_injection/service_locator.dart'
    as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init(); // Initialize dependency injection
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeCom Final',
      theme: AppTheme.lightTheme, // Use new theme
      navigatorKey: AppNavigator.navigatorKey,
      onGenerateRoute: AppNavigator.generateRoute,
      initialRoute: AppRoutes.splash, // Start with splash screen
      debugShowCheckedModeBanner: false,
    );
  }
}
