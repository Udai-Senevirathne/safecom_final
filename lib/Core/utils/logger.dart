import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Custom logger utility for SafeCom app
/// Uses proper logging instead of print() statements
class AppLogger {
  static const String _appName = 'SafeCom';

  /// Log debug information
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _appName,
        level: 500, // Debug level
        time: DateTime.now(),
      );
    }
  }

  /// Log info messages
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _appName,
        level: 800, // Info level
        time: DateTime.now(),
      );
    }
  }

  /// Log warning messages
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _appName,
        level: 900, // Warning level
        time: DateTime.now(),
      );
    }
  }

  /// Log error messages
  static void error(
    String message, [
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _appName,
        level: 1000, // Error level
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }

  /// Log success messages
  static void success(String message, [String? tag]) {
    if (kDebugMode) {
      developer.log(
        '✅ $message',
        name: _appName,
        level: 800, // Info level
        time: DateTime.now(),
      );
    }
  }

  /// Log profile-specific messages
  static void profile(String message) {
    debug('🔍 [Profile] $message');
  }

  /// Log auth-specific messages
  static void auth(String message) {
    debug('🔐 [Auth] $message');
  }

  /// Log firebase-specific messages
  static void firebase(String message) {
    debug('🔥 [Firebase] $message');
  }

  /// Log navigation-specific messages
  static void navigation(String message) {
    debug('🧭 [Navigation] $message');
  }
}