import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Service to initialize Firebase
class FirebaseInitService {
  static bool _initialized = false;

  /// Initialize Firebase with the provided options
  /// 
  /// Example:
  /// ```dart
  /// await FirebaseInitService.initialize(
  ///   apiKey: 'your-api-key',
  ///   authDomain: 'your-project.firebaseapp.com',
  ///   projectId: 'your-project-id',
  ///   storageBucket: 'your-project.appspot.com',
  ///   messagingSenderId: '123456789',
  ///   appId: '1:123456789:web:abcdef',
  /// );
  /// ```
  static Future<void> initialize({
    required String apiKey,
    required String authDomain,
    required String projectId,
    required String storageBucket,
    required String messagingSenderId,
    required String appId,
    String? measurementId,
  }) async {
    if (_initialized) {
      if (kDebugMode) {
        print('Firebase already initialized');
      }
      return;
    }

    try {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: apiKey,
          authDomain: authDomain,
          projectId: projectId,
          storageBucket: storageBucket,
          messagingSenderId: messagingSenderId,
          appId: appId,
          measurementId: measurementId,
        ),
      );
      _initialized = true;
      if (kDebugMode) {
        print('✅ Firebase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize Firebase: $e');
      }
      rethrow;
    }
  }

  /// Initialize Firebase from environment variables
  /// 
  /// Requires the following environment variables to be defined:
  /// - FIREBASE_API_KEY
  /// - FIREBASE_AUTH_DOMAIN
  /// - FIREBASE_PROJECT_ID
  /// - FIREBASE_STORAGE_BUCKET
  /// - FIREBASE_MESSAGING_SENDER_ID
  /// - FIREBASE_APP_ID
  /// - FIREBASE_MEASUREMENT_ID (optional)
  static Future<void> initializeFromEnvironment() async {
    await initialize(
      apiKey: const String.fromEnvironment('FIREBASE_API_KEY'),
      authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
      projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
      storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
      messagingSenderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
      appId: const String.fromEnvironment('FIREBASE_APP_ID'),
      measurementId: const String.fromEnvironment('FIREBASE_MEASUREMENT_ID', defaultValue: ''),
    );
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => _initialized;
}
