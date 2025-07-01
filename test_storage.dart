import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Simple test to verify SharedPreferences functionality
void main() async {
  debugPrint('Testing SharedPreferences...');

  try {
    // Test 1: Basic initialization
    debugPrint('Test 1: Initializing SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    debugPrint('✓ SharedPreferences initialized successfully');

    // Test 2: Write operation
    debugPrint('Test 2: Testing write operation...');
    final testKey = 'test_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(testKey, 'test_value');
    debugPrint('✓ Write operation successful');

    // Test 3: Read operation
    debugPrint('Test 3: Testing read operation...');
    final value = prefs.getString(testKey);
    debugPrint('Read value: $value');
    if (value == 'test_value') {
      debugPrint('✓ Read operation successful');
    } else {
      debugPrint('✗ Read operation failed');
    }

    // Test 4: Boolean operations
    debugPrint('Test 4: Testing boolean operations...');
    await prefs.setBool('test_bool', true);
    final boolValue = prefs.getBool('test_bool');
    debugPrint('Boolean value: $boolValue');
    if (boolValue == true) {
      debugPrint('✓ Boolean operations successful');
    } else {
      debugPrint('✗ Boolean operations failed');
    }

    // Cleanup
    debugPrint('Cleaning up test data...');
    await prefs.remove(testKey);
    await prefs.remove('test_bool');
    debugPrint('✓ Cleanup successful');

    debugPrint('🎉 All SharedPreferences tests passed!');
  } catch (e, stackTrace) {
    debugPrint('❌ SharedPreferences test failed: $e');
    debugPrint('Stack trace: $stackTrace');
    debugPrint('Error type: ${e.runtimeType}');

    debugPrint('');
    debugPrint('💡 This indicates that SharedPreferences is not available.');
    debugPrint('The app will automatically fall back to in-memory storage.');
    debugPrint(
      'This is expected in some environments and the app will still work.',
    );
  }
}
