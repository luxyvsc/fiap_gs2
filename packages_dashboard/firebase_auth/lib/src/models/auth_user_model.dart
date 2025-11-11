import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

/// Model representing an authenticated user with custom claims
class AuthUserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  final String? phoneNumber;
  
  // Custom claims
  final String? role;
  final String? tenantId;
  final Map<String, dynamic> customClaims;

  const AuthUserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
    this.phoneNumber,
    this.role,
    this.tenantId,
    this.customClaims = const {},
  });

  /// Create AuthUserModel from Firebase User
  static Future<AuthUserModel> fromFirebaseUser(fb_auth.User user) async {
    // Get ID token result to access custom claims
    final idTokenResult = await user.getIdTokenResult();
    final claims = idTokenResult.claims ?? {};

    return AuthUserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      emailVerified: user.emailVerified,
      phoneNumber: user.phoneNumber,
      role: claims['role'] as String?,
      tenantId: claims['tenant_id'] as String?,
      customClaims: Map<String, dynamic>.from(claims),
    );
  }

  /// Check if user has a specific role
  bool hasRole(String requiredRole) {
    return role == requiredRole || role == 'admin';
  }

  /// Check if user has any of the specified roles
  bool hasAnyRole(List<String> roles) {
    if (role == 'admin') return true;
    return roles.contains(role);
  }

  @override
  String toString() {
    return 'AuthUserModel(uid: $uid, email: $email, role: $role)';
  }
}
