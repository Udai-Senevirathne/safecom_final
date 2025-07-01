import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'dart:math';

class SafetyDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================================
  // REAL-TIME SAFETY STATUS
  // ================================

  /// Get real-time safety status for current location and category
  static Stream<Map<String, dynamic>> getSafetyStatusStream({
    String? category,
  }) async* {
    try {
      // Get current location
      Position? position = await _getCurrentLocation();

      if (position == null) {
        yield {
          'status': 'unknown',
          'location': 'Location unavailable',
          'riskLevel': 'medium',
          'message': 'Enable location for safety updates',
          'lastUpdated': DateTime.now(),
        };
        return;
      }

      // Build query with optional category filter
      Query query = _firestore
          .collection('safety_incidents')
          .where(
            'timestamp',
            isGreaterThan: DateTime.now().subtract(const Duration(hours: 24)),
          );

      // Add category filter if specified
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      // Stream real-time incident data near user location
      await for (QuerySnapshot snapshot in query.snapshots()) {
        List<Map<String, dynamic>> nearbyIncidents = [];

        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          if (data['latitude'] != null && data['longitude'] != null) {
            double distance = _calculateDistance(
              position.latitude,
              position.longitude,
              data['latitude'],
              data['longitude'],
            );

            // Include incidents within 5km
            if (distance <= 5.0) {
              data['distance'] = distance;
              nearbyIncidents.add(data);
            }
          }
        }

        // Calculate safety score based on nearby incidents
        String safetyStatus = _calculateSafetyStatus(nearbyIncidents);
        String riskLevel = _calculateRiskLevel(nearbyIncidents);
        String location = await _getLocationName(
          position.latitude,
          position.longitude,
        );

        yield {
          'status': safetyStatus,
          'location': location,
          'riskLevel': riskLevel,
          'message': _getSafetyMessage(safetyStatus, nearbyIncidents.length),
          'nearbyIncidents': nearbyIncidents.length,
          'lastUpdated': DateTime.now(),
          'incidents': nearbyIncidents,
        };
      }
    } catch (e) {
      print('Error getting safety status: $e');
      yield {
        'status': 'error',
        'location': 'Error getting location',
        'riskLevel': 'medium',
        'message': 'Unable to get safety data',
        'lastUpdated': DateTime.now(),
      };
    }
  }

  // ================================
  // REAL-TIME INCIDENT REPORTS
  // ================================

  /// Submit incident report with real-time updates
  static Future<Map<String, dynamic>> submitIncidentReport({
    required String type,
    required String description,
    String? selectedOption,
    String? location,
    String? imageUrl,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'Please sign in to report'};
      }

      Position? position = await _getCurrentLocation();

      Map<String, dynamic> reportData = {
        'type': type,
        'category': type, // Add category field for filtering
        'description': description,
        'userId': user.uid,
        'userEmail': user.email,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
        'urgency': 'high',
        'verified': false,
        'responseTime': null,
        'location': location,
        'latitude': position?.latitude,
        'longitude': position?.longitude,
      };

      if (type == 'disaster') {
        reportData['disasterType'] = selectedOption;
      } else if (type == 'harassment') {
        reportData['gender'] = selectedOption;
      }

      if (imageUrl != null) {
        reportData['imageUrl'] = imageUrl;
      }

      // Save to safety_incidents collection for real-time safety tracking
      DocumentReference incidentRef = await _firestore
          .collection('safety_incidents')
          .add(reportData);

      // Also save to emergency_reports for admin tracking
      await _firestore.collection('emergency_reports').add(reportData);

      // Trigger real-time alerts to nearby users
      await _triggerNearbyAlerts(position, type, description);

      return {
        'success': true,
        'message': 'Report submitted successfully',
        'reportId': incidentRef.id,
      };
    } catch (e) {
      print('Error submitting incident: $e');
      return {
        'success': false,
        'message': 'Failed to submit report. Please try again.',
      };
    }
  }

  /// Get real-time incident reports stream
  static Stream<List<Map<String, dynamic>>> getIncidentReportsStream({
    String? type,
  }) {
    Query query = _firestore
        .collection('safety_incidents')
        .where(
          'timestamp',
          isGreaterThan: DateTime.now().subtract(const Duration(hours: 48)),
        )
        .orderBy('timestamp', descending: true);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // REAL-TIME SOS FUNCTIONALITY

  /// Trigger SOS alert with real-time location sharing
  static Future<Map<String, dynamic>> triggerSOSAlert({
    String category = 'general',
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'Please sign in to use SOS'};
      }

      Position? position = await _getCurrentLocation();

      Map<String, dynamic> sosData = {
        'userId': user.uid,
        'userEmail': user.email,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'sos',
        'category': category, // Add category to distinguish SOS type
        'status': 'active',
        'urgency': 'critical',
        'latitude': position?.latitude,
        'longitude': position?.longitude,
        'accuracy': position?.accuracy,
        'responseRequested': true,
      };

      DocumentReference sosRef = await _firestore
          .collection('sos_alerts')
          .add(sosData);

      // Also add to safety_incidents for area safety tracking with category
      await _firestore.collection('safety_incidents').add({
        ...sosData,
        'description': 'SOS Alert Triggered - ${category.toUpperCase()}',
        'type': 'emergency',
      });
      await _firestore.collection('safety_incidents').add({
        ...sosData,
        'description': 'SOS Alert Triggered',
        'type': 'emergency',
      });

      // Start real-time location updates
      _startLocationTracking(sosRef.id);

      return {
        'success': true,
        'message': 'SOS Alert sent! Help is on the way.',
        'sosId': sosRef.id,
      };
    } catch (e) {
      print('Error triggering SOS: $e');
      return {'success': false, 'message': 'Failed to send SOS alert'};
    }
  }

  /// Start real-time location tracking for SOS
  static void _startLocationTracking(String sosId) {
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        Position? position = await _getCurrentLocation();
        if (position != null) {
          await _firestore.collection('sos_alerts').doc(sosId).update({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'lastLocationUpdate': FieldValue.serverTimestamp(),
            'accuracy': position.accuracy,
          });
        }
      } catch (e) {
        print('Error updating location: $e');
        timer.cancel();
      }
    });
  }

  // ================================
  // HELPER METHODS
  // ================================

  static Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions permanently denied');
        return null;
      }

      Position? position;

      try {
        // Try high accuracy first
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (e) {
        try {
          // Fallback to medium accuracy
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 20),
          );
        } catch (e2) {
          try {
            // Final fallback to low accuracy
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 25),
            );
          } catch (e3) {
            // Use last known position
            position = await Geolocator.getLastKnownPosition();
            if (position != null) {
              print('Using last known location');
            }
          }
        }
      }

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  static String _calculateSafetyStatus(List<Map<String, dynamic>> incidents) {
    if (incidents.isEmpty) return 'safe';
    if (incidents.length <= 2) return 'caution';
    return 'danger';
  }

  static String _calculateRiskLevel(List<Map<String, dynamic>> incidents) {
    if (incidents.isEmpty) return 'low';
    if (incidents.length <= 2) return 'medium';
    return 'high';
  }

  static String _getSafetyMessage(String status, int incidentCount) {
    switch (status) {
      case 'safe':
        return 'Area appears safe • No recent incidents';
      case 'caution':
        return 'Exercise caution • $incidentCount recent incidents';
      case 'danger':
        return 'High risk area • $incidentCount recent incidents';
      default:
        return 'Stay alert • Monitor your surroundings';
    }
  }

  static Future<String> _getLocationName(
    double latitude,
    double longitude,
  ) async {
    try {
      // Use reverse geocoding to get actual location name
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String location = '';

        if (place.locality != null && place.locality!.isNotEmpty) {
          location = place.locality!;
        } else if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          location = place.subAdministrativeArea!;
        } else if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          location = place.administrativeArea!;
        } else if (place.country != null && place.country!.isNotEmpty) {
          location = place.country!;
        } else {
          location = 'Unknown Area';
        }

        return location;
      }
    } catch (e) {
      print('Error getting location name: $e');
    }

    // Fallback to coordinates if reverse geocoding fails
    return '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
  }

  static Future<void> _triggerNearbyAlerts(
    Position? position,
    String type,
    String description,
  ) async {
    // This would send push notifications to nearby users
    // Implementation depends on your notification service (FCM, etc.)
    print('Alert triggered: $type incident reported');
  }
}
