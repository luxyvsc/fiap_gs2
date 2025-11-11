import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_user_model.dart';
import '../services/auth_service.dart';

/// Provider for AuthService singleton
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for Firebase User stream
final firebaseUserStreamProvider = StreamProvider<fb_auth.User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for AuthUserModel stream with custom claims
final authUserStreamProvider = StreamProvider<AuthUserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.userChanges;
});

/// Provider for current AuthUserModel (async)
final currentAuthUserProvider = FutureProvider<AuthUserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.currentUser;
});

/// Provider for authentication state (is user signed in?)
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(firebaseUserStreamProvider);
  return userAsync.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for checking if user is signed in (synchronous)
final isSignedInProvider = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isSignedIn;
});

/// StateNotifier for managing auth operations and loading states
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(const AuthState());

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Create new user account
  Future<void> register(
    String email,
    String password,
    String displayName,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signOut();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth state model
class AuthState {
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider for AuthStateNotifier
final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService);
});
