import 'package:flutter/material.dart';
import 'package:safecom_final/Core/navigation/appnavigator.dart';
import 'package:safecom_final/Core/navigation/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeCom Final',
      navigatorKey: AppNavigator.navigatorKey,
      onGenerateRoute: AppNavigator.generateRoute,
      initialRoute: AppRoutes.personalInfo, // Set to your starting screen route
      debugShowCheckedModeBanner: false,
    );
  }
}
