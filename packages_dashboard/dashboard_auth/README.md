# Firebase Auth - Flutter Package

Firebase Authentication package for Flutter frontend in the FIAP AI-Enhanced Learning Platform.

## 🔐 Overview

This Flutter package provides comprehensive Firebase Authentication functionality including:
- Firebase initialization functions
- Authentication provider with Riverpod (login, logout, register, password recovery)
- Pre-built Login and Register widgets
- Automatic authentication state management
- Email/password authentication
- Password recovery
- Email verification
- Role-Based Access Control (RBAC) widgets
- `context.watch` pattern for checking authentication state
- Riverpod state management integration

## 🚀 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  firebase_auth:
    path: ../dashboard_auth
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
import 'package:dashboard_auth/dashboard_auth.dart';

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
import 'package:dashboard_auth/dashboard_auth.dart';

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

### 1. Initialize Firebase

In your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_auth/dashboard_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseInitService.initialize(
    apiKey: 'YOUR_API_KEY',
    authDomain: 'your-project.firebaseapp.com',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
    messagingSenderId: '123456789',
    appId: '1:123456789:web:abcdef',
  );
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 2. Use AuthWrapper with context.watch

The package automatically manages authentication state. Use `AuthWrapper` to show login when not authenticated:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthWrapper(
        child: HomeScreen(), // Shown when authenticated
        signedOutBuilder: (context) => AuthScreen(), // Shown when not authenticated
      ),
    );
  }
}
```

### 3. Create Auth Screen with Login/Register

```dart
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen(BuildContext context, {Key? key}) : super(key: key);

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showLogin ? 'Login' : 'Cadastro'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _showLogin
              ? LoginWidget(
                  onRegisterTap: () => setState(() => _showLogin = false),
                )
              : RegisterWidget(
                  onLoginTap: () => setState(() => _showLogin = true),
                ),
        ),
      ),
    );
  }
}
```

### 4. Check Authentication State with context.watch

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch authentication state
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    
    if (!isAuthenticated) {
      return LoginScreen();
    }
    
    return HomeScreen();
  }
}
```

### 5. Access Current User

```dart
class ProfileWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authUserStreamProvider);
    
    return userAsync.when(
      data: (user) {
        if (user == null) return Text('Not signed in');
        return Column(
          children: [
            Text('Email: ${user.email}'),
            Text('Name: ${user.displayName}'),
            Text('Role: ${user.role}'),
          ],
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### 6. Sign Out

```dart
ElevatedButton(
  onPressed: () async {
    await ref.read(authStateNotifierProvider.notifier).signOut();
  },
  child: Text('Logout'),
)
```

## 🏗️ Available Providers

### Services
- `authServiceProvider` - AuthService singleton for auth operations

### State Management
- `firebaseUserStreamProvider` - Stream of Firebase User (with context.watch)
- `authUserStreamProvider` - Stream of AuthUserModel with custom claims
- `currentAuthUserProvider` - Current AuthUserModel (async)
- `isAuthenticatedProvider` - Boolean: is user signed in? (use with context.watch)
- `authStateNotifierProvider` - StateNotifier for auth operations (login, register, etc.)

### Auth State Notifier Methods
```dart
final authNotifier = ref.read(authStateNotifierProvider.notifier);

// Login
await authNotifier.signIn(email, password);

// Register
await authNotifier.register(email, password, displayName);

// Reset password
await authNotifier.resetPassword(email);

// Sign out
await authNotifier.signOut();
```

## 🎨 Pre-built Widgets

### LoginWidget
Ready-to-use login form with email and password fields:
```dart
LoginWidget(
  onRegisterTap: () {
    // Navigate to register screen
  },
  onLoginSuccess: () {
    // Optional callback after successful login
  },
)
```

### RegisterWidget
Ready-to-use registration form:
```dart
RegisterWidget(
  onLoginTap: () {
    // Navigate to login screen
  },
  onRegisterSuccess: () {
    // Optional callback after successful registration
  },
)
```

### AuthWrapper
Automatically handles authentication state:
```dart
AuthWrapper(
  child: HomeScreen(), // Shown when authenticated
  signedOutBuilder: (context) => LoginScreen(), // When not authenticated
  loadingBuilder: (context) => LoadingScreen(), // While checking
)
```

### RoleGuard
Show content only if user has required role:
```dart
RoleGuard(
  requiredRole: 'admin',
  child: AdminPanel(),
  unauthorizedBuilder: (context) => Text('Access denied'),
)
```

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
