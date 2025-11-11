import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  group('AuthUserModel', () {
    test('hasRole returns true for admin', () {
      final user = AuthUserModel(
        uid: 'test',
        email: 'admin@test.com',
        role: 'admin',
      );

      expect(user.hasRole('user'), true);
      expect(user.hasRole('admin'), true);
      expect(user.hasRole('any-role'), true);
    });

    test('hasRole checks specific role', () {
      final user = AuthUserModel(
        uid: 'test',
        email: 'user@test.com',
        role: 'user',
      );

      expect(user.hasRole('user'), true);
      expect(user.hasRole('admin'), false);
    });

    test('hasAnyRole works correctly', () {
      final user = AuthUserModel(
        uid: 'test',
        email: 'recruiter@test.com',
        role: 'recruiter',
      );

      expect(user.hasAnyRole(['admin', 'recruiter']), true);
      expect(user.hasAnyRole(['admin', 'user']), false);
    });

    test('toString includes uid, email, and role', () {
      final user = AuthUserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        role: 'user',
      );

      final result = user.toString();
      expect(result.contains('test-uid'), true);
      expect(result.contains('test@example.com'), true);
      expect(result.contains('user'), true);
    });
  });

  group('FirebaseInitService', () {
    test('isInitialized returns false initially', () {
      expect(FirebaseInitService.isInitialized, false);
    });
  });
}
