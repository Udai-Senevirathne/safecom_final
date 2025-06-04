import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safecom_final/Screens/auth/login_page.dart';
import 'package:safecom_final/Screens/home/harass_home.dart';
import 'package:safecom_final/Screens/home/disaster_home.dart';
import 'package:safecom_final/Screens/Splash_screen/splash_screen.dart';
import 'package:safecom_final/Screens/First_screen/first_screen.dart';
import 'package:safecom_final/Screens/Second_screen/second_screen.dart';
import 'package:safecom_final/Core/navigation/appnavigator.dart';
import 'package:safecom_final/Core/navigation/app_routes.dart';
import 'package:safecom_final/blocs/auth/auth_bloc.dart';
import 'package:safecom_final/Repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    RepositoryProvider(
      create: (_) => AuthRepository(),
      child: BlocProvider(
        create: (context) => AuthBloc(authRepository: context.read<AuthRepository>()),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeCom Final',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: AppNavigator.onGenerateRoute,
      initialRoute: AppRoutes.splashScreen, // This defines the starting screen
    );
  }
}
