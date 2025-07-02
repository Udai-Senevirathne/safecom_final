import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:safecom_final/Core/services/auth_service.dart';
import 'package:safecom_final/Core/services/google_signin_service.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // ================================
  // AUTHENTICATION
  // ================================

  /// Sign up new user
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      // Create user account
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Try to save user profile to Firestore, but don't fail if it doesn't work
      try {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });
        print('User data saved to Firestore successfully');
      } catch (firestoreError) {
        print('Failed to save to Firestore: $firestoreError');
        // Continue anyway since the user account was created
      }

      // Save login status and user data locally
      await AuthService.setLoginStatus(true);
      await AuthService.saveUserData(
        fullName,
        email,
        phone,
        emailVerified: userCredential.user?.emailVerified.toString(),
        signInMethod: 'email',
      );

      return {
        'success': true,
        'message': 'Account created successfully',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getAuthErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  /// Sign in existing user
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save login status locally
      await AuthService.setLoginStatus(true);

      // Try to get user data from Firestore and save locally
      try {
        final userDoc =
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          await AuthService.saveUserData(
            userData['fullName'] ?? '',
            userData['email'] ?? email,
            userData['phone'] ?? '',
          );
        }
      } catch (firestoreError) {
        print('Failed to get user data from Firestore: $firestoreError');
        // Continue anyway since sign-in was successful
      }

      return {
        'success': true,
        'message': 'Signed in successfully',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getAuthErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  /// Sign out current user
  static Future<void> signOut() async {
    try {
      print('🔵 [Firebase] Starting sign out process...');

      // 1. Sign out from Firebase Auth (with timeout)
      await _auth.signOut().timeout(Duration(seconds: 5));
      print('🟢 [Firebase] Firebase Auth sign out completed');

      // 2. Sign out from Google (with timeout and error handling)
      try {
        await GoogleSignInService.signOutFromGoogle().timeout(
          Duration(seconds: 5),
        );
        print('🟢 [Firebase] Google sign out completed');
      } catch (e) {
        print('🟠 [Firebase] Google sign out error (continuing anyway): $e');
        // Don't throw - continue with local cleanup
      }

      // 3. Clear local authentication status
      await AuthService.setLoginStatus(false);
      print('🟢 [Firebase] Login status cleared');

      // 4. Clear local user data
      await AuthService.signOut();
      print('🟢 [Firebase] Local user data cleared');

      print('🟢 [Firebase] Sign out process completed successfully');
    } catch (e) {
      print('🔴 [Firebase] Sign out error: $e');

      // Even if sign out fails, try to clear local data
      try {
        await AuthService.setLoginStatus(false);
        await AuthService.signOut();
        print('🟠 [Firebase] Local cleanup completed despite sign out error');
      } catch (localError) {
        print('🔴 [Firebase] Local cleanup also failed: $localError');
      }

      // Re-throw the original error
      rethrow;
    }
  }

  /// Delete user account and all associated data
  static Future<Map<String, dynamic>> deleteUserAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'No user is currently signed in'};
      }

      final userId = user.uid;
      print('Starting account deletion for user: $userId');

      // 1. Delete user's reports from Firestore
      try {
        final reportsQuery =
            await _firestore
                .collection('emergency_reports')
                .where('userId', isEqualTo: userId)
                .get();

        for (var doc in reportsQuery.docs) {
          await doc.reference.delete();
        }
        print('Deleted ${reportsQuery.docs.length} emergency reports');
      } catch (e) {
        print('Error deleting reports: $e');
      }

      // 1a. Delete user's safety incidents
      try {
        final incidentsQuery =
            await _firestore
                .collection('safety_incidents')
                .where('userId', isEqualTo: userId)
                .get();

        for (var doc in incidentsQuery.docs) {
          await doc.reference.delete();
        }
        print('Deleted ${incidentsQuery.docs.length} safety incidents');
      } catch (e) {
        print('Error deleting safety incidents: $e');
      }

      // 1b. Delete user's SOS alerts
      try {
        final sosQuery =
            await _firestore
                .collection('sos_alerts')
                .where('userId', isEqualTo: userId)
                .get();

        for (var doc in sosQuery.docs) {
          await doc.reference.delete();
        }
        print('Deleted ${sosQuery.docs.length} SOS alerts');
      } catch (e) {
        print('Error deleting SOS alerts: $e');
      }

      // 2. Delete user profile from Firestore
      try {
        await _firestore.collection('users').doc(userId).delete();
        print('Deleted user profile from Firestore');
      } catch (e) {
        print('Error deleting user profile: $e');
      }

      // 3. Delete user's uploaded images from Storage
      try {
        final storageRef = _storage.ref().child('users').child(userId);
        final listResult = await storageRef.listAll();
        for (var item in listResult.items) {
          await item.delete();
        }
        print('Deleted user storage files');
      } catch (e) {
        print('Error deleting storage files: $e');
      }

      // 4. Clear local data and disconnect Google Sign-In if applicable
      await AuthService.clearUserData();
      await AuthService.setLoginStatus(false);

      // Disconnect Google Sign-In if user signed in with Google
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.disconnect();
          print('Disconnected Google Sign-In');
        }
      } catch (e) {
        print('Error disconnecting Google Sign-In: $e');
        // Continue with account deletion even if Google disconnect fails
      }

      print('Cleared local user data and disconnected external accounts');

      // 5. Delete Firebase Auth account (must be last)
      await user.delete();
      print('Deleted Firebase Auth account');

      return {'success': true, 'message': 'Account deleted successfully'};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return {
          'success': false,
          'message': 'Please sign in again to delete your account',
          'requiresReauth': true,
        };
      }
      return {'success': false, 'message': _getAuthErrorMessage(e.code)};
    } catch (e) {
      print('Error deleting account: $e');
      return {
        'success': false,
        'message': 'Failed to delete account. Please try again.',
      };
    }
  }

  /// Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Check if user is signed in
  static bool isSignedIn() {
    return _auth.currentUser != null;
  }

  // USER PROFILE

  /// Get user profile data
  static Future<Map<String, String?>> getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return {
          'fullName': null,
          'email': null,
          'phone': null,
          'address': null,
          'dateOfBirth': null,
          'gender': null,
        };
      }

      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'fullName': data['fullName']?.toString(),
          'email': data['email']?.toString(),
          'phone': data['phone']?.toString(),
          'address': data['address']?.toString(),
          'dateOfBirth': data['dateOfBirth']?.toString(),
          'gender': data['gender']?.toString(),
        };
      } else {
        // Create basic profile if doesn't exist
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });

        return {
          'fullName': null,
          'email': user.email,
          'phone': null,
          'address': null,
          'dateOfBirth': null,
          'gender': null,
        };
      }
    } catch (e) {
      print('Error getting user data: $e');
      return {
        'fullName': null,
        'email': null,
        'phone': null,
        'address': null,
        'dateOfBirth': null,
        'gender': null,
      };
    }
  }

  /// Update user profile
  static Future<bool> updateProfile(Map<String, String?> userData) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      // Remove null values
      Map<String, dynamic> cleanData = {};
      userData.forEach((key, value) {
        if (value != null && value.isNotEmpty) {
          cleanData[key] = value;
        }
      });

      cleanData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(user.uid).update(cleanData);

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // EMERGENCY REPORTS

  /// Submit emergency report
  static Future<Map<String, dynamic>> submitEmergencyReport({
    required String type, // 'disaster' or 'harassment'
    required String description,
    String? selectedOption, // disaster type or gender
    String? location,
    File? image,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Please sign in to submit a report',
        };
      }

      Map<String, dynamic> reportData = {
        'type': type,
        'description': description,
        'userId': user.uid,
        'userEmail': user.email,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
        'location': location,
      };

      // Add type-specific data
      if (type == 'disaster') {
        reportData['disasterType'] = selectedOption;
      } else if (type == 'harassment') {
        reportData['gender'] = selectedOption;
      }

      // Upload image if provided
      if (image != null) {
        String imageUrl = await _uploadReportImage(image, type);
        reportData['imageUrl'] = imageUrl;
      }

      // Save to Firestore
      DocumentReference docRef = await _firestore
          .collection('emergency_reports')
          .add(reportData);

      return {
        'success': true,
        'message': 'Report submitted successfully',
        'reportId': docRef.id,
      };
    } catch (e) {
      print('Error submitting report: $e');
      return {
        'success': false,
        'message': 'Failed to submit report. Please try again.',
      };
    }
  }

  /// Get user's reports
  static Stream<QuerySnapshot> getUserReports() {
    User? user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('emergency_reports')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Get all recent reports (for admin/monitoring)
  static Stream<QuerySnapshot> getAllReports({int limit = 50}) {
    return _firestore
        .collection('emergency_reports')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  // HELPER METHODS

  static Future<String> _uploadReportImage(
    File image,
    String reportType,
  ) async {
    try {
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$reportType.jpg';
      Reference ref = _storage.ref().child('reports').child(fileName);

      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  static String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Upload profile image to Firebase Storage
  static Future<String?> uploadProfileImage(File imageFile) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final String fileName =
          'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child(
        'profile_images/$fileName',
      );

      print('🔵 [Firebase] Uploading profile image: $fileName');

      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('🟢 [Firebase] Profile image uploaded successfully: $downloadUrl');

      // Update user profile in Firestore
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'photoUrl': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('🟢 [Firebase] User profile updated with new photo URL');
      } catch (firestoreError) {
        print(
          '🟠 [Firebase] Firestore update failed, but image uploaded: $firestoreError',
        );
        // Return URL anyway since image was uploaded successfully
      }

      return downloadUrl;
    } catch (e) {
      print('🔴 [Firebase] Error uploading profile image: $e');
      return null;
    }
  }

  /// Remove profile image from user profile
  static Future<void> removeProfileImage() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      print('🔵 [Firebase] Removing profile image for user: ${user.uid}');

      // Get current photo URL to delete from storage
      try {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data()!['photoUrl'] != null) {
          final String photoUrl = userDoc.data()!['photoUrl'];

          // Delete from Firebase Storage if it's a Firebase Storage URL
          if (photoUrl.contains('firebase') &&
              photoUrl.contains('profile_images')) {
            try {
              final Reference photoRef = _storage.refFromURL(photoUrl);
              await photoRef.delete();
              print('🟢 [Firebase] Profile image deleted from storage');
            } catch (storageError) {
              print(
                '🟠 [Firebase] Could not delete from storage (may not exist): $storageError',
              );
            }
          }
        }
      } catch (e) {
        print(
          '🟠 [Firebase] Could not retrieve current photo for deletion: $e',
        );
      }

      // Remove photo URL from Firestore
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'photoUrl': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('🟢 [Firebase] Photo URL removed from user profile');
      } catch (firestoreError) {
        print('🟠 [Firebase] Firestore update failed: $firestoreError');
      }
    } catch (e) {
      print('🔴 [Firebase] Error removing profile image: $e');
      rethrow;
    }
  }
}
