import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserPhotoUrl = 'user_photo_url';
  static const String _keyUserGoogleId = 'user_google_id';
  static const String _keyUserEmailVerified = 'user_email_verified';
  static const String _keyUserSignInMethod = 'user_signin_method';

  // In-memory fallback storage
  static final Map<String, dynamic> _memoryStorage = {};
  static bool _useMemoryStorage = false;

  // Stream controller for profile updates
  static final StreamController<Map<String, String?>> _userDataController =
      StreamController<Map<String, String?>>.broadcast();

  // Stream to listen for profile updates
  static Stream<Map<String, String?>> get userDataStream =>
      _userDataController.stream;

  // Initialize storage
  static Future<void> _initStorage() async {
    if (_useMemoryStorage) return;

    try {
      await SharedPreferences.getInstance();
      debugPrint('SharedPreferences initialized successfully');
    } catch (e) {
      debugPrint('SharedPreferences failed, using memory storage: $e');
      _useMemoryStorage = true;
    }
  }

  // Get storage instance
  static Future<dynamic> _getStorage() async {
    await _initStorage();

    if (_useMemoryStorage) {
      return _memoryStorage;
    } else {
      return await SharedPreferences.getInstance();
    }
  }

  // Set value in storage
  static Future<bool> _setValue(String key, dynamic value) async {
    try {
      final storage = await _getStorage();

      if (_useMemoryStorage) {
        _memoryStorage[key] = value;
        debugPrint('Saved to memory storage: $key = $value');
        return true;
      } else {
        if (value is bool) {
          return await storage.setBool(key, value);
        } else if (value is String) {
          return await storage.setString(key, value);
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error setting value: $e');
      return false;
    }
  }

  // Get value from storage
  static Future<T?> _getValue<T>(String key) async {
    try {
      final storage = await _getStorage();

      if (_useMemoryStorage) {
        final value = _memoryStorage[key];
        debugPrint('Retrieved from memory storage: $key = $value');
        return value as T?;
      } else {
        if (T == bool) {
          return storage.getBool(key) as T?;
        } else if (T == String) {
          return storage.getString(key) as T?;
        }
        return null;
      }
    } catch (e) {
      debugPrint('Error getting value: $e');
      return null;
    }
  }

  // Sign up user
  static Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      debugPrint('Starting signup process...');
      debugPrint('Name: $name, Email: $email, Phone: $phone');

      // Validate inputs
      if (name.trim().isEmpty) {
        debugPrint('Signup failed: Name is empty');
        return false;
      }
      if (email.trim().isEmpty) {
        debugPrint('Signup failed: Email is empty');
        return false;
      }
      if (phone.trim().isEmpty) {
        debugPrint('Signup failed: Phone is empty');
        return false;
      }
      if (password.isEmpty) {
        debugPrint('Signup failed: Password is empty');
        return false;
      }

      // Initialize storage
      await _initStorage();
      debugPrint(
        'Storage initialized. Using memory storage: $_useMemoryStorage',
      );

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Save user data using robust storage
      debugPrint('Saving user data...');

      final loginResult = await _setValue(_keyIsLoggedIn, true);
      final nameResult = await _setValue(_keyUserName, name.trim());
      final emailResult = await _setValue(_keyUserEmail, email.trim());
      final phoneResult = await _setValue(_keyUserPhone, phone.trim());

      debugPrint(
        'Save results - Login: $loginResult, Name: $nameResult, Email: $emailResult, Phone: $phoneResult',
      );

      if (loginResult && nameResult && emailResult && phoneResult) {
        // Notify listeners about the new user
        final userData = await getUserData();
        _userDataController.add(userData);
        debugPrint('Signup completed successfully');
        return true;
      } else {
        debugPrint('Failed to save some user data');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Sign up error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  // Sign in user
  static Future<bool> signIn({
    required String identifier, // email or phone
    required String password,
  }) async {
    try {
      debugPrint('Starting sign in process...');
      debugPrint('Identifier: $identifier');

      // Validate inputs
      if (identifier.trim().isEmpty) {
        debugPrint('Sign in failed: Identifier is empty');
        return false;
      }
      if (password.isEmpty) {
        debugPrint('Sign in failed: Password is empty');
        return false;
      }

      // Initialize storage
      await _initStorage();
      debugPrint(
        'Storage initialized. Using memory storage: $_useMemoryStorage',
      );

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you would verify credentials with your backend
      // For now, we'll just check if user exists and mark as logged in
      debugPrint('Saving user data...');

      final loginResult = await _setValue(_keyIsLoggedIn, true);

      // You might get user data from API response
      final nameResult = await _setValue(_keyUserName, 'User Name');
      final emailResult = await _setValue(
        _keyUserEmail,
        identifier.contains('@') ? identifier.trim() : '',
      );
      final phoneResult = await _setValue(
        _keyUserPhone,
        identifier.contains('@') ? '' : identifier.trim(),
      );

      debugPrint(
        'Save results - Login: $loginResult, Name: $nameResult, Email: $emailResult, Phone: $phoneResult',
      );

      if (loginResult && nameResult && emailResult && phoneResult) {
        // Notify listeners about the user
        final userData = await getUserData();
        _userDataController.add(userData);
        debugPrint('Sign in completed successfully');
        return true;
      } else {
        debugPrint('Failed to save some user data');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Sign in error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  // Sign out user
  static Future<void> signOut() async {
    try {
      debugPrint('Starting sign out process...');

      // Initialize storage
      await _initStorage();
      debugPrint(
        'Storage initialized. Using memory storage: $_useMemoryStorage',
      );

      await _setValue(_keyIsLoggedIn, false);

      if (_useMemoryStorage) {
        _memoryStorage.remove(_keyUserName);
        _memoryStorage.remove(_keyUserEmail);
        _memoryStorage.remove(_keyUserPhone);
        _memoryStorage.remove(_keyUserPhotoUrl);
        _memoryStorage.remove(_keyUserGoogleId);
        _memoryStorage.remove(_keyUserEmailVerified);
        _memoryStorage.remove(_keyUserSignInMethod);
        debugPrint('Cleared user data from memory storage');
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_keyUserName);
        await prefs.remove(_keyUserEmail);
        await prefs.remove(_keyUserPhone);
        await prefs.remove(_keyUserPhotoUrl);
        await prefs.remove(_keyUserGoogleId);
        await prefs.remove(_keyUserEmailVerified);
        await prefs.remove(_keyUserSignInMethod);
        debugPrint('Cleared user data from SharedPreferences');
      }

      // Notify listeners about sign out
      _userDataController.add({
        'name': null,
        'email': null,
        'phone': null,
        'photoUrl': null,
        'googleId': null,
        'emailVerified': null,
        'signInMethod': null,
      });
      debugPrint('Sign out completed successfully');
    } catch (e, stackTrace) {
      debugPrint('Sign out error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = await _getValue<bool>(_keyIsLoggedIn);
      debugPrint('Login status: $isLoggedIn');
      return isLoggedIn ?? false;
    } catch (e) {
      debugPrint('Check login status error: $e');
      return false;
    }
  }

  // Get user data
  static Future<Map<String, String?>> getUserData() async {
    try {
      final name = await _getValue<String>(_keyUserName);
      final email = await _getValue<String>(_keyUserEmail);
      final phone = await _getValue<String>(_keyUserPhone);
      final photoUrl = await _getValue<String>(_keyUserPhotoUrl);
      final googleId = await _getValue<String>(_keyUserGoogleId);
      final emailVerified = await _getValue<String>(_keyUserEmailVerified);
      final signInMethod = await _getValue<String>(_keyUserSignInMethod);

      final userData = {
        'name': name,
        'email': email,
        'phone': phone,
        'photoUrl': photoUrl,
        'googleId': googleId,
        'emailVerified': emailVerified,
        'signInMethod': signInMethod,
      };

      debugPrint('Retrieved user data: $userData');
      return userData;
    } catch (e) {
      debugPrint('Get user data error: $e');
      return {
        'name': null,
        'email': null,
        'phone': null,
        'photoUrl': null,
        'googleId': null,
        'emailVerified': null,
        'signInMethod': null,
      };
    }
  }

  // Update user profile
  static Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      debugPrint('Starting profile update...');
      debugPrint('Name: $name, Email: $email, Phone: $phone');

      // Initialize storage
      await _initStorage();
      debugPrint(
        'Storage initialized. Using memory storage: $_useMemoryStorage',
      );

      bool success = true;

      if (name != null) {
        final result = await _setValue(_keyUserName, name.trim());
        success = success && result;
        debugPrint('Update name result: $result');
      }
      if (email != null) {
        final result = await _setValue(_keyUserEmail, email.trim());
        success = success && result;
        debugPrint('Update email result: $result');
      }
      if (phone != null) {
        final result = await _setValue(_keyUserPhone, phone.trim());
        success = success && result;
        debugPrint('Update phone result: $result');
      }

      if (success) {
        // Notify listeners about the update
        final userData = await getUserData();
        _userDataController.add(userData);
        debugPrint('Profile update completed successfully');
      } else {
        debugPrint('Failed to update some profile data');
      }

      return success;
    } catch (e, stackTrace) {
      debugPrint('Update profile error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  // Update user photo URL
  static Future<bool> updateUserPhotoUrl(String photoUrl) async {
    try {
      debugPrint('Updating user photo URL: $photoUrl');
      await _initStorage();

      bool success = await _setValue(_keyUserPhotoUrl, photoUrl);
      if (success) {
        debugPrint('Photo URL updated successfully in local storage');

        // Emit updated user data to stream listeners
        final userData = await getUserData();
        _userDataController.add(userData);
      }

      return success;
    } catch (e) {
      debugPrint('Error updating user photo URL: $e');
      return false;
    }
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone number format
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  // Validate password strength
  static bool isValidPassword(String password) {
    // At least 6 characters
    return password.length >= 6;
  }

  // Test SharedPreferences functionality
  static Future<bool> testSharedPreferences() async {
    try {
      debugPrint('Testing SharedPreferences...');

      // Add a small delay to ensure Flutter is ready
      await Future.delayed(const Duration(milliseconds: 100));

      final prefs = await SharedPreferences.getInstance();
      debugPrint('SharedPreferences instance created successfully');

      // Test write
      final testKey = 'test_key_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(testKey, 'test_value');
      debugPrint('Test write successful');

      // Test read
      final testValue = prefs.getString(testKey);
      debugPrint('Test read result: $testValue');

      // Clean up
      await prefs.remove(testKey);
      debugPrint('Test cleanup successful');

      return testValue == 'test_value';
    } catch (e, stackTrace) {
      debugPrint('SharedPreferences test failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  // Utility methods for Firebase integration
  static Future<bool> setLoginStatus(bool isLoggedIn) async {
    try {
      return await _setValue(_keyIsLoggedIn, isLoggedIn);
    } catch (e) {
      debugPrint('Failed to set login status: $e');
      return false;
    }
  }

  static Future<bool> saveUserData(
    String name,
    String email,
    String phone, {
    String? photoUrl,
    String? googleId,
    String? emailVerified,
    String? signInMethod,
  }) async {
    try {
      final nameResult = await _setValue(_keyUserName, name.trim());
      final emailResult = await _setValue(_keyUserEmail, email.trim());
      final phoneResult = await _setValue(_keyUserPhone, phone.trim());

      bool photoResult = true;
      bool googleIdResult = true;
      bool emailVerifiedResult = true;
      bool signInMethodResult = true;

      if (photoUrl != null) {
        photoResult = await _setValue(_keyUserPhotoUrl, photoUrl.trim());
      }
      if (googleId != null) {
        googleIdResult = await _setValue(_keyUserGoogleId, googleId.trim());
      }
      if (emailVerified != null) {
        emailVerifiedResult = await _setValue(
          _keyUserEmailVerified,
          emailVerified,
        );
      }
      if (signInMethod != null) {
        signInMethodResult = await _setValue(
          _keyUserSignInMethod,
          signInMethod,
        );
      }

      final success =
          nameResult &&
          emailResult &&
          phoneResult &&
          photoResult &&
          googleIdResult &&
          emailVerifiedResult &&
          signInMethodResult;
      if (success) {
        // Notify listeners about the updated user data
        final userData = await getUserData();
        _userDataController.add(userData);
      }
      return success;
    } catch (e) {
      debugPrint('Failed to save user data: $e');
      return false;
    }
  }

  // Clear all user data (for account deletion)
  static Future<bool> clearUserData() async {
    try {
      debugPrint('Starting user data clearing...');

      // Initialize storage
      await _initStorage();

      await _setValue(_keyIsLoggedIn, false);

      if (_useMemoryStorage) {
        _memoryStorage.remove(_keyUserName);
        _memoryStorage.remove(_keyUserEmail);
        _memoryStorage.remove(_keyUserPhone);
        _memoryStorage.remove(_keyUserPhotoUrl);
        _memoryStorage.remove(_keyUserGoogleId);
        _memoryStorage.remove(_keyUserEmailVerified);
        _memoryStorage.remove(_keyUserSignInMethod);
        debugPrint('Cleared all user data from memory storage');
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_keyUserName);
        await prefs.remove(_keyUserEmail);
        await prefs.remove(_keyUserPhone);
        await prefs.remove(_keyUserPhotoUrl);
        await prefs.remove(_keyUserGoogleId);
        await prefs.remove(_keyUserEmailVerified);
        await prefs.remove(_keyUserSignInMethod);

        // Also clear any other app-specific data for account deletion
        await prefs.remove('notifications_enabled');
        await prefs.remove('emergency_alerts_enabled');
        await prefs.remove('safety_updates_enabled');
        await prefs.remove('location_sharing_enabled');
        await prefs.remove('selected_gender');

        debugPrint('Cleared all user data from SharedPreferences');
      }

      // Notify listeners about data clearing
      _userDataController.add({
        'name': null,
        'email': null,
        'phone': null,
        'photoUrl': null,
        'googleId': null,
        'emailVerified': null,
        'signInMethod': null,
      });
      debugPrint('User data clearing completed successfully');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Clear user data error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }
}
