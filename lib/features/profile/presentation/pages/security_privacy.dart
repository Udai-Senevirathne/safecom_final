import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safecom_final/Core/services/firebase_service.dart';
import 'package:safecom_final/Core/navigation/app_routes.dart';

class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  bool notificationsEnabled = true;
  bool emergencyAlertsEnabled = true;
  bool safetyUpdatesEnabled = true;
  bool locationSharingEnabled = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      emergencyAlertsEnabled =
          prefs.getBool('emergency_alerts_enabled') ?? true;
      safetyUpdatesEnabled = prefs.getBool('safety_updates_enabled') ?? true;
      locationSharingEnabled =
          prefs.getBool('location_sharing_enabled') ?? true;
      isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', notificationsEnabled);
    await prefs.setBool('emergency_alerts_enabled', emergencyAlertsEnabled);
    await prefs.setBool('safety_updates_enabled', safetyUpdatesEnabled);
    await prefs.setBool('location_sharing_enabled', locationSharingEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back, color: Colors.red.shade600, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Security & Privacy',
          style: TextStyle(
            color: Colors.red.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification Settings Section
                    _buildSectionHeader('Notification Settings'),
                    const SizedBox(height: 16),

                    _buildSettingCard(
                      title: 'All Notifications',
                      subtitle: 'Enable or disable all app notifications',
                      icon: Icons.notifications_outlined,
                      iconColor: Colors.blue,
                      value: notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          notificationsEnabled = value;
                          if (!value) {
                            // Turn off all notification types when main toggle is off
                            emergencyAlertsEnabled = false;
                            safetyUpdatesEnabled = false;
                          }
                        });
                        _saveSettings();
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildSettingCard(
                      title: 'Emergency Alerts',
                      subtitle: 'Critical safety and emergency notifications',
                      icon: Icons.warning_amber_outlined,
                      iconColor: Colors.red,
                      value: emergencyAlertsEnabled && notificationsEnabled,
                      onChanged:
                          notificationsEnabled
                              ? (value) {
                                setState(() {
                                  emergencyAlertsEnabled = value;
                                });
                                _saveSettings();
                              }
                              : null,
                    ),

                    const SizedBox(height: 12),

                    _buildSettingCard(
                      title: 'Safety Updates',
                      subtitle: 'General safety tips and area updates',
                      icon: Icons.shield_outlined,
                      iconColor: Colors.green,
                      value: safetyUpdatesEnabled && notificationsEnabled,
                      onChanged:
                          notificationsEnabled
                              ? (value) {
                                setState(() {
                                  safetyUpdatesEnabled = value;
                                });
                                _saveSettings();
                              }
                              : null,
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      title: 'View Past Alerts',
                      subtitle: 'See your notification history',
                      icon: Icons.history,
                      iconColor: Colors.orange,
                      onTap: _showPastAlerts,
                    ),

                    const SizedBox(height: 32),

                    // Account Security Section
                    _buildSectionHeader('Account Security'),
                    const SizedBox(height: 16),

                    _buildActionCard(
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      icon: Icons.lock_outline,
                      iconColor: Colors.indigo,
                      onTap: _showChangePassword,
                    ),

                    const SizedBox(height: 32),

                    // Data Privacy Section
                    _buildSectionHeader('Data Privacy'),
                    const SizedBox(height: 16),

                    _buildSettingCard(
                      title: 'Location Sharing',
                      subtitle: 'Share location during emergencies',
                      icon: Icons.location_on_outlined,
                      iconColor: Colors.teal,
                      value: locationSharingEnabled,
                      onChanged: (value) {
                        if (!value) {
                          _showLocationWarningDialog(value);
                        } else {
                          setState(() {
                            locationSharingEnabled = value;
                          });
                          _saveSettings();
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      title: 'Data Usage',
                      subtitle: 'See how your data is used',
                      icon: Icons.info_outline,
                      iconColor: Colors.blue,
                      onTap: _showDataUsage,
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      title: 'Export My Data',
                      subtitle: 'Download your personal data',
                      icon: Icons.download_outlined,
                      iconColor: Colors.green,
                      onTap: _showExportData,
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      title: 'Delete Account',
                      subtitle: 'Permanently delete your account',
                      icon: Icons.delete_outline,
                      iconColor: Colors.red,
                      isDestructive: true,
                      onTap: _showDeleteAccount,
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required Function(bool)? onChanged,
  }) {
    return Container(
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
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.red.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
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
                    title,
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

  void _showPastAlerts() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Past Alerts',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAlertItem(
                  'Emergency Alert',
                  'Tsunami warning in your area',
                  '2 days ago',
                ),
                _buildAlertItem(
                  'Safety Update',
                  'New safety tip available',
                  '1 week ago',
                ),
                _buildAlertItem(
                  'Incident Report',
                  'Report submitted successfully',
                  '2 weeks ago',
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

  Widget _buildAlertItem(String title, String message, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(message, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showChangePassword() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Change Password',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully'),
                    ),
                  );
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  void _showLocationWarningDialog(bool value) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Disable Location Sharing?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Disabling location sharing may reduce the effectiveness of emergency services. Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    locationSharingEnabled = value;
                  });
                  _saveSettings();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Disable',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showDataUsage() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Data Usage',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'SafeCom collects location data for emergency services, incident reports for safety analysis, and user preferences for app functionality. All data is encrypted and used solely for safety purposes.',
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

  void _showExportData() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Export Data',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Your data export will include profile information, incident reports, and settings. This may take a few minutes to prepare.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Data export started. You will be notified when ready.',
                      ),
                    ),
                  );
                },
                child: const Text('Start Export'),
              ),
            ],
          ),
    );
  }

  void _showDeleteAccount() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Delete Account',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            content: const Text(
              'This action cannot be undone. All your data will be permanently deleted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Show confirmation
                  _showFinalDeleteConfirmation();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showFinalDeleteConfirmation() {
    final TextEditingController deleteController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Final Confirmation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Type "DELETE" to confirm account deletion:'),
                      const SizedBox(height: 16),
                      TextField(
                        controller: deleteController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Type DELETE here',
                        ),
                        onChanged: (value) {
                          setState(() {}); // Rebuild dialog when text changes
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed:
                          deleteController.text.toUpperCase() == 'DELETE'
                              ? () async {
                                Navigator.pop(context);
                                await _performAccountDeletion();
                              }
                              : null, // Disable button if DELETE not typed correctly
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            deleteController.text.toUpperCase() == 'DELETE'
                                ? Colors.red
                                : Colors.grey,
                      ),
                      child: const Text(
                        'Confirm Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _performAccountDeletion() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Deleting your account...',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This may take a few moments',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
    );

    try {
      // Perform real-time account deletion
      final result = await FirebaseService.deleteUserAccount();

      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        if (result['success']) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to sign-in screen and clear all routes
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
        } else {
          // Handle specific errors
          if (result['requiresReauth'] == true) {
            _showReauthenticationDialog();
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Failed to delete account'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReauthenticationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Re-authentication Required',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'For security reasons, you need to sign in again before deleting your account. You will be redirected to the sign-in screen.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Sign out and redirect to login
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
                },
                child: const Text('Sign In Again'),
              ),
            ],
          ),
    );
  }
}
