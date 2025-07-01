import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/disaster_report_model.dart';
import '../models/harassment_report_model.dart';
import '../../../../Core/error/exceptions.dart';

abstract class ReportingRemoteDataSource {
  Future<DisasterReportModel> submitDisasterReport({
    required String disasterType,
    required String description,
    required double latitude,
    required double longitude,
    String? location,
    required String userId,
    String? imageUrl,
  });

  Future<HarassmentReportModel> submitHarassmentReport({
    required String description,
    required double latitude,
    required double longitude,
    String? location,
    String? userId,
    String? gender,
    required bool isAnonymous,
  });

  Future<List<DisasterReportModel>> getUserDisasterReports(String userId);
  Future<List<HarassmentReportModel>> getUserHarassmentReports(String userId);
}

class ReportingRemoteDataSourceImpl implements ReportingRemoteDataSource {
  final FirebaseFirestore firestore;

  ReportingRemoteDataSourceImpl({required this.firestore});

  @override
  Future<DisasterReportModel> submitDisasterReport({
    required String disasterType,
    required String description,
    required double latitude,
    required double longitude,
    String? location,
    required String userId,
    String? imageUrl,
  }) async {
    try {
      final reportData = {
        'type': 'disaster',
        'disasterType': disasterType,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
        'status': 'submitted',
        if (location != null) 'location': location,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

      final docRef = await firestore
          .collection('emergency_reports')
          .add(reportData);

      // Get the created document
      final doc = await docRef.get();
      final data = doc.data()!;
      data['id'] = doc.id;

      return DisasterReportModel.fromJson(data);
    } catch (e) {
      throw ServerException(
        'Failed to submit disaster report: ${e.toString()}',
      );
    }
  }

  @override
  Future<HarassmentReportModel> submitHarassmentReport({
    required String description,
    required double latitude,
    required double longitude,
    String? location,
    String? userId,
    String? gender,
    required bool isAnonymous,
  }) async {
    try {
      final reportData = {
        'type': 'harassment',
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'submitted',
        'isAnonymous': isAnonymous,
        if (!isAnonymous && userId != null) 'userId': userId,
        if (location != null) 'location': location,
        if (gender != null) 'gender': gender,
      };

      final docRef = await firestore
          .collection('emergency_reports')
          .add(reportData);

      // Get the created document
      final doc = await docRef.get();
      final data = doc.data()!;
      data['id'] = doc.id;

      return HarassmentReportModel.fromJson(data);
    } catch (e) {
      throw ServerException(
        'Failed to submit harassment report: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<DisasterReportModel>> getUserDisasterReports(
    String userId,
  ) async {
    try {
      final snapshot =
          await firestore
              .collection('emergency_reports')
              .where('type', isEqualTo: 'disaster')
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return DisasterReportModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw ServerException(
        'Failed to get user disaster reports: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<HarassmentReportModel>> getUserHarassmentReports(
    String userId,
  ) async {
    try {
      final snapshot =
          await firestore
              .collection('emergency_reports')
              .where('type', isEqualTo: 'harassment')
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return HarassmentReportModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw ServerException(
        'Failed to get user harassment reports: ${e.toString()}',
      );
    }
  }
}
