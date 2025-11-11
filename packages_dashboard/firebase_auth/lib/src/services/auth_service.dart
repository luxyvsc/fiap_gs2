import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';

import '../models/auth_user_model.dart';

/// Service for handling Firebase Authentication operations
class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth;

  AuthService({fb_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance;

  /// Get current Firebase user
  fb_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Get current authenticated user with custom claims
  Future<AuthUserModel?> get currentUser async {
    final fbUser = currentFirebaseUser;
    if (fbUser == null) return null;
    return await AuthUserModel.fromFirebaseUser(fbUser);
  }

  /// Stream of authentication state changes
  Stream<fb_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Stream of AuthUserModel changes
  Stream<AuthUserModel?> get userChanges {
    return authStateChanges.asyncMap((fbUser) async {
      if (fbUser == null) return null;
      return await AuthUserModel.fromFirebaseUser(fbUser);
    });
  }

  /// Check if user is currently signed in
  bool get isSignedIn => currentFirebaseUser != null;

  /// Get Firebase ID token for API authentication
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = currentFirebaseUser;
      if (user == null) return null;
      return await user.getIdToken(forceRefresh);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get ID token: $e');
      }
      return null;
    }
  }

  /// Sign in with email and password
  Future<AuthUserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed: No user returned');
      }

      if (kDebugMode) {
        print('✅ User signed in: ${credential.user!.email}');
      }
      return await AuthUserModel.fromFirebaseUser(credential.user!);
    } on fb_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase auth error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign in error: $e');
      }
      rethrow;
    }
  }

  /// Create user with email and password
  Future<AuthUserModel> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('User creation failed: No user returned');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      // Send email verification
      await credential.user!.sendEmailVerification();

      if (kDebugMode) {
        print('✅ User created: ${credential.user!.email}');
      }
      return await AuthUserModel.fromFirebaseUser(
        _firebaseAuth.currentUser!,
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase auth error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Create user error: $e');
      }
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      if (kDebugMode) {
        print('✅ Password reset email sent to: $email');
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase auth error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Password reset error: $e');
      }
      rethrow;
    }
  }

  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
        if (kDebugMode) {
          print('✅ Email verification sent to: ${user.email}');
        }
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase auth error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Email verification error: $e');
      }
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      if (kDebugMode) {
        print('✅ User signed out');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign out error: $e');
      }
      rethrow;
    }
  }

  /// Handle Firebase Authentication exceptions
  Exception _handleAuthException(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Nenhum usuário encontrado com este email.');
      case 'wrong-password':
        return Exception('Senha incorreta.');
      case 'email-already-in-use':
        return Exception('Já existe uma conta com este email.');
      case 'invalid-email':
        return Exception('Email inválido.');
      case 'weak-password':
        return Exception('A senha é muito fraca. Use pelo menos 6 caracteres.');
      case 'user-disabled':
        return Exception('Esta conta foi desabilitada.');
      case 'too-many-requests':
        return Exception('Muitas tentativas. Tente novamente mais tarde.');
      case 'operation-not-allowed':
        return Exception('Operação não permitida.');
      case 'requires-recent-login':
        return Exception(
          'Esta operação requer autenticação recente. Faça login novamente.',
        );
      case 'invalid-credential':
        return Exception('Credenciais inválidas.');
      default:
        return Exception('Erro de autenticação: ${e.message ?? e.code}');
    }
  }
}
