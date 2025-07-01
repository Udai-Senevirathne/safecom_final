import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';
import '../../../../Core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  });

  Future<UserModel> signIn({required String email, required String password});

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<bool> isSignedIn();

  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? address,
    String? dateOfBirth,
    String? gender,
  });

  Future<UserModel> getUserProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('Failed to create user account');
      }

      // Create user model from Firebase user
      final user = UserModel(
        id: credential.user!.uid,
        fullName: fullName,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
        isActive: true,
      );

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException('An unexpected error occurred during sign up');
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('Failed to sign in');
      }

      // Create user model from Firebase user
      final user = UserModel(
        id: credential.user!.uid,
        fullName: credential.user!.displayName ?? '',
        email: credential.user!.email ?? email,
        phone: '', // Will be fetched from Firestore in repository
        createdAt: credential.user!.metadata.creationTime,
        isActive: true,
      );

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException('An unexpected error occurred during sign in');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      return UserModel(
        id: firebaseUser.uid,
        fullName: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        phone: '', // Will be fetched from Firestore in repository
        createdAt: firebaseUser.metadata.creationTime,
        isActive: true,
      );
    } catch (e) {
      throw AuthException('Failed to get current user');
    }
  }

  @override
  Future<bool> isSignedIn() async {
    return firebaseAuth.currentUser != null;
  }

  @override
  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? address,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('No user is currently signed in');
      }

      await user.updateDisplayName(fullName);
    } catch (e) {
      throw AuthException('Failed to update profile');
    }
  }

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw AuthException('No user is currently signed in');
      }

      return UserModel(
        id: firebaseUser.uid,
        fullName: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        phone: '', // Will be fetched from Firestore in repository
        createdAt: firebaseUser.metadata.creationTime,
        isActive: true,
      );
    } catch (e) {
      throw AuthException('Failed to get user profile');
    }
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'The password provided is too weak';
      case 'invalid-email':
        return 'The email address is not valid';
      case 'user-disabled':
        return 'This user account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'invalid-credential':
        return 'The provided credentials are invalid';
      default:
        return 'An error occurred. Please try again';
    }
  }
}
