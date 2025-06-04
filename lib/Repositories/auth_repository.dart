import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // 📱 Phone number sign-in (step 1: send code)
  Future<void> loginWithPhone(
    String phoneNumber, {
    required Function(String verificationId) codeSent,
    required Function(FirebaseAuthException error) onFailed,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification (optional)
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: onFailed,
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // 📱 Phone number sign-in (step 2: verify OTP)
  Future<void> verifyOtp(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _firebaseAuth.signInWithCredential(credential);
  }

  // 📧 Email/password login
  Future<void> loginWithEmail(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 🚪 Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // 🧑‍🦱 Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }
}
