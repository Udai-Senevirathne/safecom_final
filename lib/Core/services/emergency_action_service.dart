import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:safecom_final/Core/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyActionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Handle Emergency Call Button
  static Future<void> handleEmergencyCall(
    BuildContext context,
    String category,
  ) async {
    try {
      // Show confirmation dialog first
      final confirmed = await _showEmergencyConfirmation(
        context,
        'Emergency Call',
        'This will call emergency services (${AppConstants.emergencyNumber}). Continue?',
        Icons.phone,
        Colors.red,
      );

      if (!confirmed) return;

      // Get current location
      final position = await _getCurrentLocation();

      // Log emergency call attempt
      await _logEmergencyAction(
        type: 'emergency_call',
        category: category,
        location: position,
        details: {'emergency_number': AppConstants.emergencyNumber},
      );

      // Make the call
      await _makeEmergencyCall(AppConstants.emergencyNumber);

      // Send notification to emergency contacts
      await _notifyEmergencyContacts(
        'Emergency call initiated',
        'I have called emergency services at ${DateTime.now().toString()}',
        position,
      );

      // Show success message
      _showSuccessSnackBar(context, 'Emergency call initiated successfully');
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to initiate emergency call: $e');
    }
  }

  /// Handle Police Alert Button
  static Future<void> handlePoliceAlert(
    BuildContext context,
    String category,
  ) async {
    try {
      // Show incident type selection for police
      final incidentType = await _showIncidentTypeDialog(context, [
        'Harassment',
        'Robbery',
        'Assault',
        'Suspicious Activity',
        'Domestic Violence',
        'Other Emergency',
      ]);

      if (incidentType == null) return;

      // Get current location immediately
      final position = await _getCurrentLocation();

      // Log police alert
      await _logEmergencyAction(
        type: 'police_alert',
        category: category,
        location: position,
        details: {
          'incident_type': incidentType,
          'police_number': AppConstants.policeNumber,
        },
      );

      // Show confirmation with auto-dial option
      final shouldCall = await _showEmergencyConfirmation(
        context,
        'Police Alert',
        'Incident: $incidentType\nCall Police (${AppConstants.policeNumber}) now?',
        Icons.local_police,
        Colors.blue,
      );

      if (shouldCall) {
        await _makeEmergencyCall(AppConstants.policeNumber);
      }

      // Send location and incident to emergency contacts
      await _notifyEmergencyContacts(
        'Police Alert - $incidentType',
        'I have reported a $incidentType incident to police. Location attached.',
        position,
      );

      _showSuccessSnackBar(context, 'Police alert sent successfully');
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to send police alert: $e');
    }
  }

  /// Handle Medical Help Button
  static Future<void> handleMedicalHelp(
    BuildContext context,
    String category,
  ) async {
    try {
      // Show medical emergency type selection
      final medicalType = await _showIncidentTypeDialog(context, [
        'Heart Attack',
        'Stroke',
        'Severe Injury',
        'Unconscious Person',
        'Allergic Reaction',
        'Other Medical Emergency',
      ]);

      if (medicalType == null) return;

      // Get current location
      final position = await _getCurrentLocation();

      // Log medical emergency
      await _logEmergencyAction(
        type: 'medical_emergency',
        category: category,
        location: position,
        details: {
          'medical_type': medicalType,
          'ambulance_number': AppConstants.ambulanceNumber,
        },
      );

      // Show confirmation and auto-dial ambulance
      final shouldCall = await _showEmergencyConfirmation(
        context,
        'Medical Emergency',
        'Medical Type: $medicalType\nCall Ambulance (${AppConstants.ambulanceNumber}) now?',
        Icons.local_hospital,
        Colors.red,
      );

      if (shouldCall) {
        await _makeEmergencyCall(AppConstants.ambulanceNumber);
      }

      // Send medical alert to emergency contacts
      await _notifyEmergencyContacts(
        'Medical Emergency - $medicalType',
        'I need medical assistance for $medicalType. Ambulance called. Location attached.',
        position,
      );

      _showSuccessSnackBar(context, 'Medical emergency alert sent');
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to send medical alert: $e');
    }
  }

  /// Handle Fire Service Button
  static Future<void> handleFireService(
    BuildContext context,
    String category,
  ) async {
    try {
      // Show fire emergency details
      final fireType = await _showIncidentTypeDialog(context, [
        'Building Fire',
        'Forest Fire',
        'Vehicle Fire',
        'Gas Leak',
        'Electrical Fire',
        'Other Fire Emergency',
      ]);

      if (fireType == null) return;

      // Get current location
      final position = await _getCurrentLocation();

      // Log fire emergency
      await _logEmergencyAction(
        type: 'fire_emergency',
        category: category,
        location: position,
        details: {
          'fire_type': fireType,
          'fire_number': AppConstants.fireServiceNumber,
        },
      );

      // Show confirmation and auto-dial fire service
      final shouldCall = await _showEmergencyConfirmation(
        context,
        'Fire Emergency',
        'Fire Type: $fireType\nCall Fire Service (${AppConstants.fireServiceNumber}) now?',
        Icons.local_fire_department,
        Colors.orange,
      );

      if (shouldCall) {
        await _makeEmergencyCall(AppConstants.fireServiceNumber);
      }

      // Alert nearby users about fire danger
      await _alertNearbyUsers(position, fireType);

      // Send fire alert to emergency contacts
      await _notifyEmergencyContacts(
        'Fire Emergency - $fireType',
        'Fire emergency reported: $fireType. Fire service called. Location attached.',
        position,
      );

      _showSuccessSnackBar(context, 'Fire emergency alert sent');
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to send fire alert: $e');
    }
  }

  /// Handle Safe Contact Button
  static Future<void> handleSafeContact(
    BuildContext context,
    String category,
  ) async {
    try {
      // Show safe contact options
      final action = await _showSafeContactDialog(context);
      if (action == null) return;

      // Get current location
      final position = await _getCurrentLocation();

      String message;
      String alertType;

      switch (action) {
        case 'safe':
          message =
              "I'm safe at my current location as of ${DateTime.now().toString()}";
          alertType = 'Safe Check-in';
          break;
        case 'help':
          message = "I need help at my current location. Please check on me.";
          alertType = 'Help Request';
          break;
        case 'location':
          message = "Sharing my current location with you for safety.";
          alertType = 'Location Share';
          break;
        default:
          return;
      }

      // Log safe contact action
      await _logEmergencyAction(
        type: 'safe_contact',
        category: category,
        location: position,
        details: {'action': action, 'message': message},
      );

      // Send to emergency contacts
      await _notifyEmergencyContacts(alertType, message, position);

      _showSuccessSnackBar(context, 'Message sent to emergency contacts');
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to contact safe contacts: $e');
    }
  }

  // PRIVATE HELPER METHODS

  /// Get current location with proper error handling
  static Future<Position> _getCurrentLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      // Return default location (Colombo) if GPS fails
      return Position(
        latitude: AppConstants.defaultLatitude,
        longitude: AppConstants.defaultLongitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
  }

  /// Make emergency call
  static Future<void> _makeEmergencyCall(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        // Fallback: Copy number to clipboard
        await Clipboard.setData(ClipboardData(text: phoneNumber));
        throw Exception(
          'Copied $phoneNumber to clipboard. Please dial manually.',
        );
      }
    } catch (e) {
      // Fallback: Copy number to clipboard and show instructions
      await Clipboard.setData(ClipboardData(text: phoneNumber));
      throw Exception(
        'Phone dialer unavailable. Number copied to clipboard: $phoneNumber',
      );
    }
  }

  /// Log emergency action to Firebase
  static Future<void> _logEmergencyAction({
    required String type,
    required String category,
    required Position location,
    required Map<String, dynamic> details,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('emergency_actions').add({
        'userId': user.uid,
        'type': type,
        'category': category,
        'location': GeoPoint(location.latitude, location.longitude),
        'timestamp': FieldValue.serverTimestamp(),
        'details': details,
        'status': 'active',
      });
    } catch (e) {
      print('Failed to log emergency action: $e');
    }
  }

  /// Notify emergency contacts
  static Future<void> _notifyEmergencyContacts(
    String title,
    String message,
    Position position,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Create notification record
      await _firestore.collection('emergency_notifications').add({
        'userId': user.uid,
        'title': title,
        'message': message,
        'location': GeoPoint(position.latitude, position.longitude),
        'timestamp': FieldValue.serverTimestamp(),
        'sent': true,
      });

      // Here you would integrate with your emergency contacts system
      // and send actual SMS/notifications
    } catch (e) {
      print('Failed to notify emergency contacts: $e');
    }
  }

  /// Alert nearby users about danger (for fire emergencies)
  static Future<void> _alertNearbyUsers(
    Position position,
    String fireType,
  ) async {
    try {
      await _firestore.collection('area_alerts').add({
        'type': 'fire_danger',
        'fireType': fireType,
        'location': GeoPoint(position.latitude, position.longitude),
        'radius': 1000, // 1km radius
        'timestamp': FieldValue.serverTimestamp(),
        'active': true,
      });
    } catch (e) {
      print('Failed to alert nearby users: $e');
    }
  }

  // UI HELPER METHODS

  /// Show emergency confirmation dialog
  static Future<bool> _showEmergencyConfirmation(
    BuildContext context,
    String title,
    String message,
    IconData icon,
    Color color,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(icon, color: color, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Text(message, style: const TextStyle(fontSize: 16)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirm'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  /// Show incident type selection dialog
  static Future<String?> _showIncidentTypeDialog(
    BuildContext context,
    List<String> options,
  ) async {
    return await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Select Incident Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  options
                      .map(
                        (option) => ListTile(
                          title: Text(option),
                          onTap: () => Navigator.of(context).pop(option),
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  /// Show safe contact action dialog
  static Future<String?> _showSafeContactDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Contact Emergency Contacts',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text("I'm Safe"),
                  subtitle: const Text("Send safe check-in message"),
                  onTap: () => Navigator.of(context).pop('safe'),
                ),
                ListTile(
                  leading: const Icon(Icons.help, color: Colors.orange),
                  title: const Text("Need Help"),
                  subtitle: const Text("Request assistance"),
                  onTap: () => Navigator.of(context).pop('help'),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: const Text("Share Location"),
                  subtitle: const Text("Send current location"),
                  onTap: () => Navigator.of(context).pop('location'),
                ),
              ],
            ),
          ),
    );
  }

  /// Show success snackbar
  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Show error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
