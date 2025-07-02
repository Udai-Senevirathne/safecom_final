import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:safecom_final/Core/navigation/appnavigator.dart';
import 'package:safecom_final/Core/navigation/app_routes.dart';
import 'package:safecom_final/Core/services/auth_service.dart';
import 'package:safecom_final/Core/services/firebase_service.dart';
import 'package:safecom_final/Core/utils/logger.dart';

class EditProfileContent extends StatefulWidget {
  const EditProfileContent({super.key});

  @override
  State<EditProfileContent> createState() => _EditProfileContentState();
}

class _EditProfileContentState extends State<EditProfileContent> {
  Map<String, String?> userData = {};
  bool isLoading = true;
  StreamSubscription<Map<String, String?>>? _userDataSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Listen for user data changes
    _userDataSubscription = AuthService.userDataStream.listen((
      updatedUserData,
    ) {
      AppLogger.profile('Received user data update: ${updatedUserData.keys}');
      setState(() {
        userData = updatedUserData;
      });
    });
  }

  // Add lifecycle listener to refresh when returning from other pages
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when coming back from other screens
    ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      _loadUserData();
      return true;
    });
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    super.dispose();
  }

  void _loadUserData() async {
    try {
      AppLogger.profile('Loading user data...');
      final data = await AuthService.getUserData();
      AppLogger.profile('User data loaded: ${data.keys}');
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading user data', 'Profile', e);
      setState(() {
        isLoading = false;
      });
    }
  }

  // Add a refresh method that can be called when returning from other screens
  void _refreshUserData() {
    AppLogger.profile('Refreshing user data...');
    _loadUserData();
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
                      // Profile Picture with modern styling and edit button
                      Stack(
                        children: [
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
                              backgroundImage:
                                  userData['photoUrl']?.isNotEmpty == true
                                      ? NetworkImage(userData['photoUrl']!)
                                      : null,
                              child:
                                  userData['photoUrl']?.isNotEmpty != true
                                      ? Icon(
                                        Icons.person,
                                        size: 70,
                                        color: Colors.grey.shade600,
                                      )
                                      : null,
                            ),
                          ),
                          // Add Edit Profile Picture Button - Only show if there's already a profile image
                          if (userData['photoUrl']?.isNotEmpty == true)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _showImagePickerOptions(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade600,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                        ],
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

                      // Display sign-in method if available
                      if (userData['signInMethod']?.isNotEmpty == true) ...[
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
                                userData['signInMethod'] == 'google'
                                    ? Icons.g_mobiledata
                                    : Icons.login,
                                size: 16,
                                color: Colors.red.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Signed in with ${userData['signInMethod']?.toUpperCase() ?? 'Unknown'}',
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

                      // Display email verification status if available
                      if (userData['emailVerified']?.isNotEmpty == true) ...[
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
                                userData['emailVerified'] == 'true'
                                    ? Icons.verified_user
                                    : Icons.warning_amber,
                                size: 16,
                                color:
                                    userData['emailVerified'] == 'true'
                                        ? Colors.green.shade600
                                        : Colors.orange.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                userData['emailVerified'] == 'true'
                                    ? 'Email Verified'
                                    : 'Email Not Verified',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      userData['emailVerified'] == 'true'
                                          ? Colors.green.shade600
                                          : Colors.orange.shade600,
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
                      onTap: () async {
                        await AppNavigator.push(AppRoutes.personalInfo);
                        // Refresh user data when returning from personal info page
                        _refreshUserData();
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

                AppLogger.profile(
                  'NUCLEAR OPTION: Immediate logout without any delays',
                );

                // NUCLEAR OPTION: Skip loading dialog entirely and navigate immediately
                try {
                  // Immediately clear login status
                  await AuthService.setLoginStatus(false);
                  AppLogger.profile(
                    'NUCLEAR: Login status cleared immediately',
                  );
                } catch (e) {
                  AppLogger.warning(
                    'NUCLEAR: Could not clear login status',
                    'Profile',
                  );
                }

                // Immediately navigate without any loading dialog
                try {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
                  AppLogger.success(
                    'NUCLEAR: Immediate navigation to login successful!',
                  );

                  // Start background sign-out (non-blocking)
                  FirebaseService.signOut()
                      .then((_) {
                        print(' [Profile] Background sign-out completed');
                      })
                      .catchError((e) {
                        AppLogger.error(
                          'Background sign-out error',
                          'Profile',
                          e,
                        );
                      });

                  return; // Exit immediately after navigation
                } catch (e) {
                  AppLogger.error(
                    'NUCLEAR: Immediate navigation failed',
                    'Profile',
                    e,
                  );
                }

                // If immediate navigation fails, show minimal loading and force navigation
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (dialogContext) => const AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.red),
                            SizedBox(height: 16),
                            Text('Logging out...'),
                          ],
                        ),
                      ),
                );

                // Store context reference before async operations
                final navigatorContext = Navigator.of(context);

                // Force navigation after timeout regardless of sign-out result
                bool navigationHandled = false;

                // ULTRA AGGRESSIVE: Force navigation after just 2 seconds
                Timer(Duration(seconds: 2), () async {
                  if (!navigationHandled && context.mounted) {
                    AppLogger.warning(
                      'ULTRA AGGRESSIVE (2s) - forcing navigation NOW!',
                    );
                    navigationHandled = true;

                    // Force close loading dialog
                    try {
                      Navigator.of(context).pop();
                      AppLogger.debug('ULTRA: Dialog forcibly closed');
                    } catch (e) {
                      AppLogger.warning(
                        'ULTRA: Could not close dialog',
                        'Profile',
                      );
                    }

                    // Force clear login status
                    try {
                      await AuthService.setLoginStatus(false);
                      AppLogger.debug('ULTRA: Login status forcibly cleared');
                    } catch (e) {
                      AppLogger.warning(
                        'ULTRA: Could not clear login status',
                        'Profile',
                      );
                    }

                    // Force navigation
                    try {
                      navigatorContext.pushNamedAndRemoveUntil(
                        AppRoutes.signIn,
                        (route) => false,
                      );
                      AppLogger.success(
                        'ULTRA: Navigation to login successful!',
                      );
                    } catch (e) {
                      AppLogger.error('ULTRA: Navigation failed', 'Profile', e);
                      // Ultimate fallback
                      try {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.signIn,
                          (route) => false,
                        );
                        AppLogger.success(
                          'ULTRA: Fallback navigation successful!',
                        );
                      } catch (fallbackError) {
                        AppLogger.error(
                          'ULTRA: Even fallback failed',
                          'Profile',
                          fallbackError,
                        );
                      }
                    }
                  }
                });

                // INSTANT NAVIGATION: Start navigation process immediately
                Timer(Duration(milliseconds: 500), () async {
                  if (!navigationHandled && context.mounted) {
                    print(
                      '🚀 [Profile] INSTANT (0.5s) - starting navigation process',
                    );

                    // Force clear login status immediately
                    try {
                      await AuthService.setLoginStatus(false);
                      print(
                        '🚀 [Profile] INSTANT: Login status cleared immediately',
                      );
                    } catch (e) {
                      print(
                        '🟠 [Profile] INSTANT: Could not clear login status: $e',
                      );
                    }
                  }
                });

                // Immediate timeout - force navigation after 4 seconds
                Timer(Duration(seconds: 4), () {
                  if (!navigationHandled && context.mounted) {
                    print(
                      '⚡ [Profile] Quick timeout (4s) - forcing navigation',
                    );
                    navigationHandled = true;

                    // Force close any open dialogs
                    try {
                      Navigator.of(context).pop();
                      print('⚡ [Profile] Quick timeout: Dialog closed');
                    } catch (e) {
                      print(
                        '🟠 [Profile] Quick timeout: Could not close dialog: $e',
                      );
                    }

                    // Force navigation
                    try {
                      navigatorContext.pushNamedAndRemoveUntil(
                        AppRoutes.signIn,
                        (route) => false,
                      );
                      print(
                        '⚡ [Profile] Quick timeout: Navigation to login successful',
                      );
                    } catch (e) {
                      print(
                        '🔴 [Profile] Quick timeout: Navigation failed: $e',
                      );
                    }
                  }
                });

                // Backup timeout - force navigation after 8 seconds no matter what
                Timer(Duration(seconds: 8), () {
                  if (!navigationHandled && context.mounted) {
                    print(
                      '🚨 [Profile] Emergency timeout (8s) - forcing navigation',
                    );
                    navigationHandled = true;

                    // Force close any open dialogs
                    try {
                      print('🚨 [Profile] Emergency: Closing dialogs...');
                      Navigator.of(context).pop();
                    } catch (e) {
                      print('🟠 [Profile] Could not close dialog: $e');
                    }

                    // Force navigation with multiple fallbacks
                    try {
                      print(
                        '🚨 [Profile] Emergency: Attempting login navigation...',
                      );
                      navigatorContext.pushNamedAndRemoveUntil(
                        AppRoutes.signIn,
                        (route) => false,
                      );
                      print(
                        '🟢 [Profile] Emergency navigation to login successful',
                      );
                    } catch (e) {
                      print(
                        '🔴 [Profile] Emergency splash navigation failed: $e',
                      );

                      // Ultimate fallback
                      try {
                        print(
                          '🚨 [Profile] Ultimate fallback: Direct sign-in navigation...',
                        );
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.signIn,
                          (route) => false,
                        );
                        print('🟢 [Profile] Ultimate fallback successful');
                      } catch (ultimateError) {
                        print(
                          '🔴 [Profile] Ultimate fallback failed: $ultimateError',
                        );

                        // Last resort: Pop all and go to root
                        try {
                          print('🚨 [Profile] Last resort: Going to root...');
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/', (route) => false);
                        } catch (rootError) {
                          print(
                            '🔴 [Profile] Even root navigation failed: $rootError',
                          );
                        }
                      }
                    }
                  }
                });

                // Start sign-out process in the background (non-blocking)
                FirebaseService.signOut()
                    .then((_) {
                      print('🟢 [Profile] Background sign-out completed');
                    })
                    .catchError((e) {
                      print('🔴 [Profile] Background sign-out error: $e');
                    });

                try {
                  print('🔵 [Profile] Starting sign out process...');

                  // Use FirebaseService to logout with shorter timeout
                  await FirebaseService.signOut().timeout(
                    Duration(seconds: 8),
                    onTimeout: () {
                      print(
                        '🟠 [Profile] Sign out timed out - forcing navigation',
                      );
                      throw TimeoutException(
                        'Sign out timed out but will continue with navigation',
                        Duration(seconds: 8),
                      );
                    },
                  );

                  print('🟢 [Profile] Sign out completed successfully');

                  // Double-check login status to ensure it's cleared
                  final isStillLoggedIn = await AuthService.isLoggedIn();
                  print(
                    '🔍 [Profile] Post sign-out login status check: $isStillLoggedIn',
                  );

                  if (isStillLoggedIn) {
                    print(
                      '🟠 [Profile] Warning: Login status still true after sign out, forcing clear...',
                    );
                    await AuthService.setLoginStatus(false);
                  }

                  // IMMEDIATE NAVIGATION AFTER SUCCESSFUL SIGN-OUT
                  if (context.mounted && !navigationHandled) {
                    navigationHandled = true;
                    print(
                      '🚀 [Profile] IMMEDIATE: Handling navigation after sign-out success',
                    );

                    // Close loading dialog immediately
                    try {
                      Navigator.of(context).pop();
                      print('🚀 [Profile] IMMEDIATE: Loading dialog closed');
                    } catch (e) {
                      print('🟠 [Profile] IMMEDIATE: Error closing dialog: $e');
                    }

                    // Navigate immediately
                    try {
                      print(
                        '🚀 [Profile] IMMEDIATE: Navigating to login screen...',
                      );
                      navigatorContext.pushNamedAndRemoveUntil(
                        AppRoutes.signIn,
                        (route) => false,
                      );
                      print(
                        '🚀 [Profile] IMMEDIATE: Navigation to login successful!',
                      );
                      return; // Exit the function immediately after successful navigation
                    } catch (e) {
                      print('🔴 [Profile] IMMEDIATE: Navigation failed: $e');
                    }
                  }
                } catch (e) {
                  print('🔴 [Profile] Sign out error: $e');

                  // Force clear login status on error
                  try {
                    await AuthService.setLoginStatus(false);
                    print(
                      '🟠 [Profile] Forced login status clear due to sign out error',
                    );
                  } catch (clearError) {
                    print(
                      '🔴 [Profile] Failed to force clear login status: $clearError',
                    );
                  }

                  // IMMEDIATE NAVIGATION AFTER ERROR
                  if (context.mounted && !navigationHandled) {
                    navigationHandled = true;
                    print(
                      '🚀 [Profile] IMMEDIATE ERROR: Handling navigation after error',
                    );

                    // Close loading dialog immediately
                    try {
                      Navigator.of(context).pop();
                      print(
                        '🚀 [Profile] IMMEDIATE ERROR: Loading dialog closed',
                      );
                    } catch (dialogError) {
                      print(
                        '🟠 [Profile] IMMEDIATE ERROR: Error closing dialog: $dialogError',
                      );
                    }

                    // Navigate immediately
                    try {
                      print(
                        '🚀 [Profile] IMMEDIATE ERROR: Navigating to login screen...',
                      );
                      navigatorContext.pushNamedAndRemoveUntil(
                        AppRoutes.signIn,
                        (route) => false,
                      );
                      print(
                        '🚀 [Profile] IMMEDIATE ERROR: Navigation to login successful!',
                      );
                      return; // Exit the function immediately after navigation
                    } catch (navError) {
                      print(
                        '🔴 [Profile] IMMEDIATE ERROR: Navigation failed: $navError',
                      );
                    }
                  }
                } finally {
                  print('🔵 [Profile] Entering finally block...');
                  print('🔵 [Profile] Context mounted: ${context.mounted}');
                  print('🔵 [Profile] Navigation handled: $navigationHandled');

                  // Always ensure loading dialog is closed and navigation happens
                  if (context.mounted && !navigationHandled) {
                    navigationHandled = true;
                    print('🔵 [Profile] Setting navigationHandled to true');

                    // Close loading dialog with error handling
                    try {
                      print(
                        '🔵 [Profile] Attempting to close loading dialog...',
                      );
                      Navigator.of(context).pop();
                      print('🟢 [Profile] Loading dialog closed successfully');
                    } catch (e) {
                      print('🟠 [Profile] Error closing dialog: $e');
                    }

                    // Small delay to ensure dialog is closed
                    await Future.delayed(Duration(milliseconds: 100));

                    // Always navigate regardless of sign-out success (better UX)
                    print(
                      '🟢 [Profile] Navigating to login screen directly...',
                    );

                    try {
                      // Navigate to login screen directly
                      navigatorContext.pushNamedAndRemoveUntil(
                        AppRoutes.signIn,
                        (route) => false,
                      );
                      print(
                        '🟢 [Profile] Navigation to login initiated successfully',
                      );
                    } catch (e) {
                      print('� [Profile] Navigation error: $e');

                      // Fallback: try direct navigation to sign-in
                      try {
                        print(
                          '🟠 [Profile] Attempting fallback navigation to sign-in...',
                        );
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.signIn,
                          (route) => false,
                        );
                        print('🟢 [Profile] Fallback navigation successful');
                      } catch (fallbackError) {
                        print(
                          '🔴 [Profile] Fallback navigation also failed: $fallbackError',
                        );
                      }
                    }
                  } else {
                    print(
                      '🟠 [Profile] Finally block conditions not met - context.mounted: ${context.mounted}, navigationHandled: $navigationHandled',
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

  // Image picker functionality for profile photo
  final ImagePicker _picker = ImagePicker();

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Update Profile Photo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.blue),
                    ),
                    title: const Text('Take Photo'),
                    subtitle: const Text('Use camera to take a new photo'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        color: Colors.green,
                      ),
                    ),
                    title: const Text('Choose from Gallery'),
                    subtitle: const Text('Select from your photo gallery'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  if (userData['photoUrl']?.isNotEmpty == true)
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      title: const Text('Remove Photo'),
                      subtitle: const Text('Use default profile picture'),
                      onTap: () {
                        Navigator.pop(context);
                        _removeProfilePhoto();
                      },
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        await _uploadProfileImage(File(pickedFile.path));
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorSnackBar('Failed to select image. Please try again.');
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    // Show upload progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading profile photo...'),
              ],
            ),
          ),
    );

    try {
      // Upload image to Firebase Storage and update user profile
      final photoUrl = await FirebaseService.uploadProfileImage(imageFile);

      if (photoUrl != null) {
        // Update local user data
        setState(() {
          userData['photoUrl'] = photoUrl;
        });

        // Save updated photo URL to local storage
        await AuthService.updateUserPhotoUrl(photoUrl);

        Navigator.pop(context); // Close loading dialog
        _showSuccessSnackBar('Profile photo updated successfully!');
      } else {
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar('Failed to upload image. Please try again.');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      print('Error uploading image: $e');
      _showErrorSnackBar('Failed to upload image. Please try again.');
    }
  }

  Future<void> _removeProfilePhoto() async {
    try {
      // Remove photo URL from user profile
      await FirebaseService.removeProfileImage();

      // Update local user data
      setState(() {
        userData['photoUrl'] = null;
      });

      // Remove photo URL from local storage
      await AuthService.updateUserPhotoUrl('');

      _showSuccessSnackBar('Profile photo removed successfully!');
    } catch (e) {
      print('Error removing profile photo: $e');
      _showErrorSnackBar('Failed to remove photo. Please try again.');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
