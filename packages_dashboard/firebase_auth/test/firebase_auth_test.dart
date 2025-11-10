import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  group('FirebaseConfig', () {
    test('creates from map', () {
      final map = {
        'apiKey': 'test-key',
        'authDomain': 'test.firebaseapp.com',
        'projectId': 'test-project',
        'storageBucket': 'test.appspot.com',
        'messagingSenderId': '123',
        'appId': 'test-app',
      };

      final config = FirebaseConfig.fromMap(map);

      expect(config.apiKey, 'test-key');
      expect(config.projectId, 'test-project');
      expect(config.appId, 'test-app');
    });

    test('toMap returns correct structure', () {
      final config = FirebaseConfig(
        apiKey: 'key',
        authDomain: 'domain',
        projectId: 'project',
        storageBucket: 'bucket',
        messagingSenderId: 'sender',
        appId: 'app',
      );

      final map = config.toMap();

      expect(map['apiKey'], 'key');
      expect(map['projectId'], 'project');
      expect(map['appId'], 'app');
    });
  });

  group('AuthUser', () {
    test('hasRole returns true for admin', () {
      final user = AuthUser(
        uid: 'test',
        email: 'admin@test.com',
        role: 'admin',
      );

      expect(user.hasRole('user'), true);
      expect(user.hasRole('admin'), true);
      expect(user.hasRole('any-role'), true);
    });

    test('hasRole checks specific role', () {
      final user = AuthUser(
        uid: 'test',
        email: 'user@test.com',
        role: 'user',
      );

      expect(user.hasRole('user'), true);
      expect(user.hasRole('admin'), false);
    });

    test('hasAnyRole works correctly', () {
      final user = AuthUser(
        uid: 'test',
        email: 'recruiter@test.com',
        role: 'recruiter',
      );

      expect(user.hasAnyRole(['admin', 'recruiter']), true);
      expect(user.hasAnyRole(['admin', 'user']), false);
    });

    test('belongsToTenant works correctly', () {
      final user = AuthUser(
        uid: 'test',
        email: 'user@test.com',
        tenantId: 'tenant-1',
        role: 'user',
      );

      expect(user.belongsToTenant('tenant-1'), true);
      expect(user.belongsToTenant('tenant-2'), false);
    });

    test('admin belongs to all tenants', () {
      final user = AuthUser(
        uid: 'test',
        email: 'admin@test.com',
        tenantId: 'tenant-1',
        role: 'admin',
      );

      expect(user.belongsToTenant('tenant-1'), true);
      expect(user.belongsToTenant('tenant-2'), true);
      expect(user.belongsToTenant('any-tenant'), true);
    });

    test('copyWith creates new instance with updated values', () {
      final user = AuthUser(
        uid: 'test',
        email: 'user@test.com',
        role: 'user',
      );

      final updated = user.copyWith(role: 'admin');

      expect(updated.role, 'admin');
      expect(updated.uid, user.uid);
      expect(updated.email, user.email);
    });

    test('toJson includes all fields', () {
      final user = AuthUser(
        uid: 'test-uid',
        email: 'test@example.com',
        emailVerified: true,
        displayName: 'Test User',
        role: 'user',
        tenantId: 'tenant-1',
      );

      final json = user.toJson();

      expect(json['uid'], 'test-uid');
      expect(json['email'], 'test@example.com');
      expect(json['emailVerified'], true);
      expect(json['displayName'], 'Test User');
      expect(json['role'], 'user');
      expect(json['tenantId'], 'tenant-1');
    });
  });
}
