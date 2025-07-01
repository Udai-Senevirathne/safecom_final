import 'package:flutter/material.dart';
import 'package:safecom_final/Core/navigation/appnavigator.dart';
import 'package:safecom_final/Core/navigation/app_routes.dart';

class TipsDetail extends StatelessWidget {
  const TipsDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // Tips selected
        selectedItemColor: const Color(0xFF10B981), // Green theme for tips
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              AppNavigator.pushReplacement(AppRoutes.homeHarass);
              break;
            case 1:
              AppNavigator.pushReplacement(AppRoutes.homeDisaster);
              break;
            case 2:
              AppNavigator.pushReplacement(AppRoutes.tips);
              break;
            case 3:
              AppNavigator.push(AppRoutes.profile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.woman), label: 'Harassment'),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber),
            label: 'Disaster',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Tips',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with tabs
            Container(
              color: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _buildTab('Harassment', true),
                  const SizedBox(width: 40),
                  _buildTab('Disaster', false),
                ],
              ),
            ),

            // Content Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tips to avoid',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              AppNavigator.pop();
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Personal Safety Section
                            _buildSectionHeader('Personal Safety'),
                            const SizedBox(height: 16),

                            _buildTipItem(
                              '1. Trust Your Instincts',
                              'If a situation feels uncomfortable, remove yourself.',
                            ),

                            _buildTipItem(
                              '2. Stay Aware of Your Surroundings',
                              'Avoid distractions like excessive phone use in unfamiliar places.',
                            ),

                            _buildTipItem(
                              '3. Set Boundaries',
                              'Clearly communicate your limits and stand firm if someone crosses them',
                            ),

                            const SizedBox(height: 32),

                            // Workplace & Public Spaces Section
                            _buildSectionHeader('Workplace & Public Spaces'),
                            const SizedBox(height: 16),

                            _buildTipItem(
                              '1. Speak Up',
                              'If you experience harassment, document it and report it to the appropriate authorities.',
                            ),

                            _buildTipItem(
                              '2. Seek Support',
                              'Talk to a trusted colleague, HR, or support groups if needed.',
                            ),

                            const SizedBox(height: 40),

                            // Progress indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        if (isActive) Container(height: 2, width: 40, color: Colors.red),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTipItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '– $description',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
