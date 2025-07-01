import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/safety_status_model.dart';
import '../models/incident_model.dart';
import '../../../../Core/error/exceptions.dart';

abstract class SafetyRemoteDataSource {
  Future<SafetyStatusModel> getSafetyStatus({
    required double latitude,
    required double longitude,
    String? category,
  });

  Future<IncidentModel> submitIncident({
    required String type,
    required String description,
    required double latitude,
    required double longitude,
    String? userId,
    String? imageUrl,
  });

  Future<List<IncidentModel>> getRecentIncidents({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    String? category,
  });

  Stream<SafetyStatusModel> getSafetyStatusStream({
    required double latitude,
    required double longitude,
    String? category,
  });
}

class SafetyRemoteDataSourceImpl implements SafetyRemoteDataSource {
  final FirebaseFirestore firestore;

  SafetyRemoteDataSourceImpl({required this.firestore});

  @override
  Future<SafetyStatusModel> getSafetyStatus({
    required double latitude,
    required double longitude,
    String? category,
  }) async {
    try {
      // Calculate area bounds (approximate 5km radius)
      const double kmToDegree = 0.009; // Rough conversion
      const double radius = 5 * kmToDegree;

      Query query = firestore
          .collection('incidents')
          .where('latitude', isGreaterThan: latitude - radius)
          .where('latitude', isLessThan: latitude + radius)
          .where('longitude', isGreaterThan: longitude - radius)
          .where('longitude', isLessThan: longitude + radius)
          .where(
            'timestamp',
            isGreaterThan: DateTime.now().subtract(const Duration(hours: 24)),
          );

      if (category != null) {
        query = query.where('type', isEqualTo: category);
      }

      final snapshot = await query.get();
      final incidents =
          snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

      return SafetyStatusModel.fromIncidents(
        incidents: incidents,
        areaId:
            '${latitude.toStringAsFixed(3)}_${longitude.toStringAsFixed(3)}',
      );
    } catch (e) {
      throw ServerException('Failed to get safety status: ${e.toString()}');
    }
  }

  @override
  Future<IncidentModel> submitIncident({
    required String type,
    required String description,
    required double latitude,
    required double longitude,
    String? userId,
    String? imageUrl,
  }) async {
    try {
      final incidentData = {
        'type': type,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
        if (userId != null) 'userId': userId,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

      final docRef = await firestore.collection('incidents').add(incidentData);

      // Get the created document to return the incident with server timestamp
      final doc = await docRef.get();
      final data = doc.data()!;
      data['id'] = doc.id;

      return IncidentModel.fromJson(data);
    } catch (e) {
      throw ServerException('Failed to submit incident: ${e.toString()}');
    }
  }

  @override
  Future<List<IncidentModel>> getRecentIncidents({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    String? category,
  }) async {
    try {
      const double kmToDegree = 0.009;
      final radius = radiusKm * kmToDegree;

      Query query = firestore
          .collection('incidents')
          .where('latitude', isGreaterThan: latitude - radius)
          .where('latitude', isLessThan: latitude + radius)
          .where(
            'timestamp',
            isGreaterThan: DateTime.now().subtract(const Duration(hours: 48)),
          )
          .orderBy('timestamp', descending: true)
          .limit(50);

      if (category != null) {
        query = query.where('type', isEqualTo: category);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return IncidentModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw ServerException('Failed to get recent incidents: ${e.toString()}');
    }
  }

  @override
  Stream<SafetyStatusModel> getSafetyStatusStream({
    required double latitude,
    required double longitude,
    String? category,
  }) {
    const double kmToDegree = 0.009;
    const double radius = 5 * kmToDegree;

    Query query = firestore
        .collection('incidents')
        .where('latitude', isGreaterThan: latitude - radius)
        .where('latitude', isLessThan: latitude + radius)
        .where(
          'timestamp',
          isGreaterThan: DateTime.now().subtract(const Duration(hours: 24)),
        );

    if (category != null) {
      query = query.where('type', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      final incidents =
          snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

      return SafetyStatusModel.fromIncidents(
        incidents: incidents,
        areaId:
            '${latitude.toStringAsFixed(3)}_${longitude.toStringAsFixed(3)}',
      );
    });
  }
}
