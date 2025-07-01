import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Add timeout for better user experience
    scopes: ['email', 'profile'],
  );
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign in with Google
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print('🔵 [GoogleSignIn] Starting Google Sign-In process...');

      // Add a timeout to the entire Google Sign-In process
      return await _performGoogleSignIn().timeout(Duration(seconds: 30));
    } on TimeoutException catch (e) {
      print('🔴 [GoogleSignIn] TIMEOUT: Google Sign-In took too long: $e');
      return {
        'success': false,
        'message': 'Google sign-in timed out. Please try again.',
      };
    } catch (e) {
      print('🔴 [GoogleSignIn] ERROR: $e');
      print('🔴 [GoogleSignIn] Error type: ${e.runtimeType}');
      return {
        'success': false,
        'message': 'Google sign-in failed: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> _performGoogleSignIn() async {
    print('🔵 [GoogleSignIn] Triggering authentication flow...');

    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    print('🔵 [GoogleSignIn] Google Sign-In dialog completed');

    if (googleUser == null) {
      print('🟠 [GoogleSignIn] Google Sign-In was cancelled by user');
      return {'success': false, 'message': 'Google sign-in was cancelled'};
    }

    print('🔵 [GoogleSignIn] User selected: ${googleUser.email}');
    print('🔵 [GoogleSignIn] Getting Google authentication credentials...');

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    print('🔵 [GoogleSignIn] Got authentication tokens');

    print('🔵 [GoogleSignIn] Creating Firebase credential...');
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print('🔵 [GoogleSignIn] Firebase credential created');

    print('🔵 [GoogleSignIn] Signing in to Firebase...');
    // Sign in to Firebase with the credential
    UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );
    User? user = userCredential.user;
    print('🟢 [GoogleSignIn] Firebase sign-in successful: ${user?.email}');

    if (user != null) {
      print('🔵 [GoogleSignIn] Managing user profile in Firestore...');

      // Use a timeout for Firestore operations to prevent hanging
      try {
        // Check if user profile exists in Firestore
        print('🔵 [GoogleSignIn] Checking existing user profile...');
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(Duration(seconds: 5));

        if (!userDoc.exists) {
          print('🔵 [GoogleSignIn] Creating new user profile in Firestore...');
          // Create user profile for new Google user
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set({
                'fullName': user.displayName ?? '',
                'email': user.email ?? '',
                'phone': user.phoneNumber ?? '',
                'profilePicture': user.photoURL ?? '',
                'createdAt': FieldValue.serverTimestamp(),
                'isActive': true,
                'signInMethod': 'google',
              })
              .timeout(Duration(seconds: 5));
          print('🟢 [GoogleSignIn] New user profile created successfully');
        } else {
          print('🔵 [GoogleSignIn] Updating existing user profile...');
          // Update last sign in time for existing user
          await _firestore
              .collection('users')
              .doc(user.uid)
              .update({'lastSignIn': FieldValue.serverTimestamp()})
              .timeout(Duration(seconds: 5));
          print('🟢 [GoogleSignIn] User profile updated successfully');
        }
      } catch (timeoutError) {
        print('🟠 [GoogleSignIn] Firestore operation timed out: $timeoutError');
        print(
          '🟠 [GoogleSignIn] But user is signed in to Firebase, proceeding...',
        );
        // Even if Firestore operations fail, the user is authenticated in Firebase
        // We can still proceed with the sign-in
      }

      print('🟢 [GoogleSignIn] Google Sign-In process completed successfully');
      return {
        'success': true,
        'message': 'Google sign-in successful',
        'user': user,
      };
    }

    print('🔴 [GoogleSignIn] Firebase sign-in failed - no user returned');
    return {'success': false, 'message': 'Failed to sign in with Google'};
  }

  /// Sign out from Google
  static Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Google sign out error: $e');
    }
  }

  /// Check if signed in with Google
  static Future<bool> isSignedInWithGoogle() async {
    try {
      return _googleSignIn.currentUser != null;
    } catch (e) {
      return false;
    }
  }
}
