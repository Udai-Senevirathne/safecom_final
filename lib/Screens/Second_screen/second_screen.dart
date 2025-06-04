import 'package:flutter/material.dart';
import 'package:safecom_final/Core/navigation/app_routes.dart';
import 'package:safecom_final/Core/navigation/appnavigator.dart';

class SecondScreen extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const SecondScreen({super.key, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with fade effect
          FadeTransition(
            opacity: fadeAnimation,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('Images/third.png'), // Building image
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // White overlay gradient for better text readability
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.95),
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // Title positioned exactly as in your original code
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

          // Subtitle positioned exactly as in your original code
          Positioned(
            bottom: 160,
            left: 20,
            right: 20,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: const Text(
                '"Report any emergency, whether it\'s a harassment incident or a disaster situation, to ensure a swift response."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),

          // Continue button positioned on the right as in screenshot
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
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}