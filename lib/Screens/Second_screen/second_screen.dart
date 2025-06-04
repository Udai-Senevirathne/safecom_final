import 'package:flutter/material.dart';
import 'package:safecom_final/Core/navigation/appnavigator.dart';
import 'package:safecom_final/Core/navigation/app_routes.dart';

class SecondScreen extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const SecondScreen({super.key, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        FadeTransition(
          opacity: fadeAnimation,
          child: Center(
            child: Image.asset(
              'Images/third.png',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
        ),
        // Overlay with a message
        Positioned(
          bottom: 300,
          left: 20,
          right: 20,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: const Text(
              'Report your emergency',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Overlay with a message
        Positioned(
          bottom: 160,
          left: 20,
          right: 20,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: const Text(
              'Report any emergency, whether it\'s a harassment incident or '
              'a disaster situation, to ensure a swift response',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        // Button to navigate to the next screen
        Positioned(
          bottom: 40,
          right: 20,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ElevatedButton(
              onPressed: () {
                AppNavigator.pushReplacement(AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}