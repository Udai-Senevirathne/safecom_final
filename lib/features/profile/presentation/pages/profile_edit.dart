import 'package:flutter/material.dart';
import 'package:safecom_final/Core/navigation/appnavigator.dart';
import 'package:safecom_final/Core/navigation/app_routes.dart';
import 'package:safecom_final/Core/services/auth_service.dart';
import 'package:safecom_final/Core/services/firebase_service.dart';

class EditProfileContent extends StatefulWidget {
  const EditProfileContent({super.key});

  @override
  State<EditProfileContent> createState() => _EditProfileContentState();
}

class _EditProfileContentState extends State<EditProfileContent> {
  Map<String, String?> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      final data = await AuthService.getUserData();
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Profile selected
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) {
          switch (index) {
            case 0:
              AppNavigator.pushReplacement(AppRoutes.homeHarass);
              break;
            case 1:
              AppNavigator.pushReplacement(AppRoutes.homeDisaster);
              break;
            case 2:
              AppNavigator.pushReplacement(
                AppRoutes.tips,
                arguments: 'harassment',
              );
              break;
            case 3:
              // Already on profile
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Modern Header with gradient background
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.red.shade50, Colors.red.shade100],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Profile Picture with modern styling
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(
                            Icons.person,
                            size: 70,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // User Info - now using loaded data
                      Text(
                        userData['name'] ?? 'User Name',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Display email if available
                      if (userData['email']?.isNotEmpty == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.email,
                                size: 16,
                                color: Colors.red.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                userData['email']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Display phone if available
                      if (userData['phone']?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone,
                                size: 16,
                                color: Colors.red.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                userData['phone']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Account Section
                    _buildSectionHeader('Account'),
                    const SizedBox(height: 16),

                    _buildModernMenuItem(
                      label: 'Personal Information',
                      subtitle: 'Update your profile details',
                      icon: Icons.person_outline,
                      iconColor: Colors.blue,
                      onTap: () {
                        AppNavigator.push(AppRoutes.personalInfo);
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildModernMenuItem(
                      label: 'Security & Privacy',
                      subtitle: 'Manage your privacy settings',
                      icon: Icons.security_outlined,
                      iconColor: Colors.green,
                      onTap: () {
                        AppNavigator.push(AppRoutes.securityPrivacy);
                      },
                    ),

                    const SizedBox(height: 32),

                    // Support Section
                    _buildSectionHeader('Support'),
                    const SizedBox(height: 16),

                    _buildModernMenuItem(
                      label: 'Help Center',
                      subtitle: 'Get help and support',
                      icon: Icons.help_outline,
                      iconColor: Colors.orange,
                      onTap: () {
                        _showHelpCenter();
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildModernMenuItem(
                      label: 'Report a Bug',
                      subtitle: 'Help us improve the app',
                      icon: Icons.bug_report_outlined,
                      iconColor: Colors.amber,
                      onTap: () {
                        _showBugReport();
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildModernMenuItem(
                      label: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      icon: Icons.policy_outlined,
                      iconColor: Colors.purple,
                      onTap: () {
                        _showPrivacyPolicy();
                      },
                    ),

                    const SizedBox(height: 32),

                    // Logout Section
                    _buildModernMenuItem(
                      label: 'Logout',
                      subtitle: 'Sign out of your account',
                      icon: Icons.logout,
                      iconColor: Colors.red,
                      isDestructive: true,
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildModernMenuItem({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) =>
                          const Center(child: CircularProgressIndicator()),
                );

                try {
                  // Use FirebaseService to logout (this will also clear local data)
                  await FirebaseService.signOut();

                  if (context.mounted) {
                    // Close loading dialog
                    Navigator.of(context).pop();

                    // Navigate to login screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.signIn,
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    // Close loading dialog
                    Navigator.of(context).pop();

                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHelpCenter() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.help_outline, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text('Help Center'),
              ],
            ),
            content: const SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need assistance? ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  
                  SizedBox(height: 16),
                  Text('📧 Email: support@safecom.app'),
                  SizedBox(height: 8),
                  Text('💬 Live Chat: Available 9 AM - 6 PM EST'),
                  SizedBox(height: 8),
                  Text('📞 Phone Support: 1-800-SAFECOM'),
                  SizedBox(height: 8),
                  Text('🌐 Website: www.safecom.app/support'),
                  SizedBox(height: 16),
                  Text(
                    'Response Time: 24-48 hours',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showBugReport() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.bug_report_outlined, color: Colors.amber.shade600),
                const SizedBox(width: 8),
                const Text('Report a Bug'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Help us improve SafeCom:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 16),
                Text('🐛 Report app crashes or freezes'),
                SizedBox(height: 8),
                Text('🔧 Suggest feature improvements'),
                SizedBox(height: 8),
                Text('⚡ Report performance issues'),
                SizedBox(height: 8),
                Text('🎨 Report UI/UX problems'),
                SizedBox(height: 16),
                Text(
                  'Email: support@safecom.app\nSubject: Bug Report - [Brief Description]',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.policy_outlined, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                const Text('Privacy Policy'),
              ],
            ),
            content: const SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Privacy Matters',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text('🔒 Data Encryption & Security'),
                  SizedBox(height: 8),
                  Text('🚫 No Data Selling or Sharing'),
                  SizedBox(height: 8),
                  Text('📍 Location Data Protection'),
                  SizedBox(height: 8),
                  Text('🗑️ Data Deletion Rights'),
                  SizedBox(height: 8),
                  Text('📱 Minimal Data Collection'),
                  SizedBox(height: 16),
                  Text(
                    'Last Updated: January 2025\n\nFor full policy details, visit:\nwww.safecom.app/privacy',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
