import 'package:flutter/material.dart';

class FirstScreen extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const FirstScreen({super.key, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('Images/second.png'), // Make sure path is correct
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Dark gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.white.withOpacity(0.9),
              ],
              stops: const [0.3, 0.9],
            ),
          ),
        ),

        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Title
                FadeTransition(
                  opacity: fadeAnimation,
                  child: const Text(
                    'Create emergency SOS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle
                FadeTransition(
                  opacity: fadeAnimation,
                  child: const Text(
                    '"If you are in a threatening situation, press the SOS button to instantly alert your trusted contacts and report the incident."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip button
                    FadeTransition(
                      opacity: fadeAnimation,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement navigation
                        },
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    // Get Start button
                    FadeTransition(
                      opacity: fadeAnimation,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement navigation
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Get Start'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
