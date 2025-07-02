import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'auth_service.dart';

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

        String fullName = user.displayName ?? '';
        String email = user.email ?? '';
        String phone = user.phoneNumber ?? '';

        if (!userDoc.exists) {
          print('🔵 [GoogleSignIn] Creating new user profile in Firestore...');
          // Create user profile for new Google user
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set({
                'fullName': fullName,
                'email': email,
                'phone': phone,
                'profilePicture': user.photoURL ?? '',
                'createdAt': FieldValue.serverTimestamp(),
                'isActive': true,
                'signInMethod': 'google',
              })
              .timeout(Duration(seconds: 5));
          print('🟢 [GoogleSignIn] New user profile created successfully');
        } else {
          print('🔵 [GoogleSignIn] Updating existing user profile...');
          // Get existing user data from Firestore
          final userData = userDoc.data() as Map<String, dynamic>;
          fullName = userData['fullName'] ?? fullName;
          email = userData['email'] ?? email;
          phone = userData['phone'] ?? phone;

          // Update last sign in time for existing user
          await _firestore
              .collection('users')
              .doc(user.uid)
              .update({'lastSignIn': FieldValue.serverTimestamp()})
              .timeout(Duration(seconds: 5));
          print('🟢 [GoogleSignIn] User profile updated successfully');
        }

        // CRITICAL: Save user data to local AuthService storage
        print('🔵 [GoogleSignIn] Saving user data to local storage...');
        await AuthService.setLoginStatus(true);
        await AuthService.saveUserData(
          fullName,
          email,
          phone,
          photoUrl: user.photoURL,
          googleId: user.uid,
          emailVerified: user.emailVerified.toString(),
          signInMethod: 'google',
        );
        print(
          '🟢 [GoogleSignIn] User data saved to local storage successfully',
        );
      } catch (timeoutError) {
        print('🟠 [GoogleSignIn] Firestore operation timed out: $timeoutError');
        print(
          '🟠 [GoogleSignIn] But user is signed in to Firebase, proceeding...',
        );

        // Even if Firestore operations fail, save basic user data locally
        await AuthService.setLoginStatus(true);
        await AuthService.saveUserData(
          user.displayName ?? 'Google User',
          user.email ?? '',
          user.phoneNumber ?? '',
          photoUrl: user.photoURL,
          googleId: user.uid,
          emailVerified: user.emailVerified.toString(),
          signInMethod: 'google',
        );
        print('🟢 [GoogleSignIn] Basic user data saved to local storage');
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
      print('🔵 [GoogleSignOut] Starting Google sign out...');

      // Check if user is currently signed in
      final currentUser = _googleSignIn.currentUser;
      if (currentUser == null) {
        print('🟠 [GoogleSignOut] No Google user currently signed in');
        return;
      }

      print('🔵 [GoogleSignOut] Signing out user: ${currentUser.email}');
      await _googleSignIn.signOut();
      print('🟢 [GoogleSignOut] Google sign out completed successfully');
    } catch (e) {
      print('🔴 [GoogleSignOut] Google sign out error: $e');
      // Don't re-throw - let the calling function handle this gracefully
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
