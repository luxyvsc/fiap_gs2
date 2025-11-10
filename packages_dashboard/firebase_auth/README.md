# Firebase Auth - Flutter Package

Firebase Authentication package for Flutter frontend in the FIAP AI-Enhanced Learning Platform.

## 🔐 Overview

This Flutter package provides comprehensive Firebase Authentication functionality including:
- Firebase initialization
- Email/password authentication
- Google Sign-In
- Custom token authentication
- Automatic token management with Dio interceptor
- Role-Based Access Control (RBAC) widgets
- Tenant/multi-organization support
- Riverpod state management integration

## 🚀 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  firebase_auth:
    path: ../firebase_auth
```

Then run:
```bash
flutter pub get
```

## 📋 Requirements

- Flutter 3.0+
- Dart 3.0+
- Firebase project with Authentication enabled
- Firebase configuration (API key, project ID, etc.)

## 🔧 Configuration

### 1. Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create or select your project
3. Enable Authentication methods (Email/Password, Google, etc.)
4. Add your app (Web, Android, iOS)
5. Copy the Firebase configuration

### 2. Initialize Firebase in Your App

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  final firebaseConfig = FirebaseConfig(
    apiKey: 'YOUR_API_KEY',
    authDomain: 'your-project.firebaseapp.com',
    projectId: 'your-project',
    storageBucket: 'your-project.appspot.com',
    messagingSenderId: '123456789',
    appId: '1:123456789:web:abcdef',
  );
  
  await FirebaseService().initialize(config: firebaseConfig);
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 3. Environment Variables (Recommended for Production)

Create a config file or use environment variables:

```dart
// lib/config/firebase_config.dart
import 'package:firebase_auth/firebase_auth.dart';

FirebaseConfig getFirebaseConfig() {
  return FirebaseConfig(
    apiKey: const String.fromEnvironment('FIREBASE_API_KEY'),
    authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
    storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    messagingSenderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    appId: const String.fromEnvironment('FIREBASE_APP_ID'),
  );
}
```

## 💻 Usage

### Basic Authentication

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    
    return ElevatedButton(
      onPressed: () async {
        try {
          final user = await authService.signInWithEmailAndPassword(
            email: 'user@example.com',
            password: 'password123',
          );
          print('Signed in: ${user.email}');
        } catch (e) {
          print('Error: $e');
        }
      },
      child: Text('Sign In'),
    );
  }
}
```

### Using AuthWrapper Widget

```dart
import 'package:firebase_auth/firebase_auth.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthWrapper(
        child: HomeScreen(), // Shown when authenticated
        signedOutBuilder: (context) => LoginScreen(), // Shown when not authenticated
        loadingBuilder: (context) => LoadingScreen(), // Shown while checking auth
      ),
    );
  }
}
```

### Sign In Methods

#### Email & Password

```dart
final authService = ref.read(authServiceProvider);

// Sign in
final user = await authService.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Create account
final newUser = await authService.createUserWithEmailAndPassword(
  email: email,
  password: password,
  displayName: 'John Doe',
);
```

#### Google Sign-In

```dart
final user = await authService.signInWithGoogle();
```

#### Custom Token (After Backend OAuth)

```dart
// Backend returns custom token after OAuth
final customToken = await yourBackendApi.oauthCallback();

// Sign in with custom token
final user = await authService.signInWithCustomToken(customToken);
```

### Role-Based Access Control

#### Using RoleGuard Widget

```dart
import 'package:firebase_auth/firebase_auth.dart';

class AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRole: 'admin',
      child: AdminDashboard(),
      unauthorizedBuilder: (context) => Text('Admin access required'),
    );
  }
}
```

#### Using Providers

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final userRole = ref.watch(userRoleProvider);
    
    if (isAdmin) {
      return AdminContent();
    }
    
    return UserContent();
  }
}
```

### Tenant-Based Access Control

```dart
class TenantDataScreen extends StatelessWidget {
  final String tenantId;
  
  @override
  Widget build(BuildContext context) {
    return TenantGuard(
      requiredTenantId: tenantId,
      child: TenantContent(tenantId: tenantId),
      unauthorizedBuilder: (context) => Text('Access denied'),
    );
  }
}
```

### API Calls with Authentication

```dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Create authenticated Dio client
final authService = ref.read(authServiceProvider);
final dio = createAuthenticatedDio(
  authService: authService,
  baseUrl: 'https://api.example.com',
);

// Make authenticated API calls
// The interceptor automatically adds Authorization header
final response = await dio.get('/api/v1/protected');
```

### Monitoring Authentication State

```dart
class UserProfileWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authUserStreamProvider);
    
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Text('Not signed in');
        }
        return Column(
          children: [
            Text('Email: ${user.email}'),
            Text('Role: ${user.role}'),
            Text('Tenant: ${user.tenantId}'),
          ],
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### Sign Out

```dart
final authService = ref.read(authServiceProvider);
await authService.signOut();
```

## 🏗️ Available Providers

### Services
- `authServiceProvider` - AuthService singleton

### State
- `firebaseUserStreamProvider` - Stream of Firebase User
- `authUserStreamProvider` - Stream of AuthUser with custom claims
- `currentAuthUserProvider` - Current AuthUser (async)
- `isAuthenticatedProvider` - Boolean: is user signed in?
- `userRoleProvider` - Current user's role
- `isAdminProvider` - Boolean: is user admin?
- `userTenantIdProvider` - Current user's tenant ID

## 🔐 Security Best Practices

1. **Never expose Firebase API keys in code** - Use environment variables
2. **Enable App Check** in Firebase Console to protect against abuse
3. **Configure CORS** properly in Firebase and backend services
4. **Use HTTPS** for all API communications
5. **Implement rate limiting** on authentication endpoints
6. **Validate custom claims** on sensitive operations
7. **Use proper Firebase Security Rules** for Firestore/Storage
8. **Enable email verification** for new accounts
9. **Implement proper error handling** to avoid exposing sensitive info
10. **Regularly update dependencies** to patch security vulnerabilities

## 🧪 Testing

Run tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

## 📖 Integration with Backend

### Backend Setup

Your backend microservices should use the `auth_service` Python package:

```python
from fastapi import FastAPI, Depends
from auth_service import verify_firebase_token, AuthUser

app = FastAPI()

@app.get("/api/v1/protected")
async def protected_route(user: AuthUser = Depends(verify_firebase_token)):
    return {"message": f"Hello {user.email}", "uid": user.uid}
```

### Frontend API Calls

```dart
// Dio automatically adds Authorization header
final dio = createAuthenticatedDio(
  authService: authService,
  baseUrl: 'https://your-backend-api.com',
);

final response = await dio.get('/api/v1/protected');
// Request includes: Authorization: Bearer <firebase_id_token>
```

## 📚 API Reference

### Models
- `FirebaseConfig` - Firebase configuration
- `AuthUser` - Authenticated user with custom claims

### Services
- `FirebaseService` - Firebase initialization
- `AuthService` - Authentication operations

### Interceptors
- `AuthInterceptor` - Dio interceptor for adding auth tokens
- `createAuthenticatedDio()` - Create Dio with auth

### Widgets
- `AuthWrapper` - Route guard for authentication
- `RoleGuard` - Widget guard for role-based access
- `TenantGuard` - Widget guard for tenant-based access

## 🤝 Contributing

This package is part of the FIAP AI-Enhanced Learning Platform monorepo. See the main project documentation for contribution guidelines.

## 📄 License

See the main project LICENSE file.

## 🔗 Related Packages

- [auth_service](../../packages/auth_service) - Backend Firebase authentication service
- [frontend_flutter](../frontend_flutter) - Main Flutter application
