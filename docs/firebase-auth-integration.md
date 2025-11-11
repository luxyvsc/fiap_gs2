# Firebase Authentication Integration Guide

This guide explains how to integrate Firebase Authentication across the FIAP AI-Enhanced Learning Platform, covering both backend microservices and frontend applications.

## 🎯 Overview

The platform now uses **Firebase Authentication** for all authentication needs:
- **Backend**: Python microservices use `auth_service` package with Firebase Admin SDK
- **Frontend**: Flutter applications use `dashboard_auth` package with Firebase Client SDK
- **Google Cloud Integration**: Service-to-service authentication for Vertex AI and other Google Cloud APIs

## 🏗️ Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│  Flutter App    │         │  Backend API     │         │  Google Cloud    │
│  (Client SDK)   │────────▶│  (Admin SDK)     │────────▶│  (Service Acct)  │
└─────────────────┘         └──────────────────┘         └──────────────────┘
      │                            │                             │
      │ ID Token                   │ Verify Token               │ API Calls
      │                            │                             │
      ▼                            ▼                             ▼
 User Identity              Role/Claims Check           Vertex AI, Storage, etc.
```

## 📋 Prerequisites

### 1. Firebase Project Setup

1. **Create Firebase Project**
   ```
   - Go to https://console.firebase.google.com/
   - Create new project or select existing
   - Enable Authentication
   - Enable required sign-in methods (Email/Password, Google, etc.)
   ```

2. **Get Service Account Key** (for backend)
   ```
   - Go to Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save JSON securely (do NOT commit to git)
   ```

3. **Get Web App Config** (for frontend)
   ```
   - Go to Project Settings → General
   - Add Web App
   - Copy configuration (apiKey, authDomain, etc.)
   ```

### 2. Google Cloud Setup (for Vertex AI)

1. **Enable APIs**
   ```bash
   gcloud services enable aiplatform.googleapis.com
   gcloud services enable firebase.googleapis.com
   ```

2. **Create Service Account** (if not using Firebase SA)
   ```bash
   gcloud iam service-accounts create fiap-backend \
     --display-name="FIAP Backend Services"
   ```

3. **Grant IAM Roles**
   ```bash
   # Firebase Admin
   gcloud projects add-iam-policy-binding PROJECT_ID \
     --member="serviceAccount:fiap-backend@PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/firebase.admin"
   
   # Vertex AI User
   gcloud projects add-iam-policy-binding PROJECT_ID \
     --member="serviceAccount:fiap-backend@PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/aiplatform.user"
   ```

## 🔧 Backend Setup (Python Microservices)

### 1. Install auth_service Package

```bash
cd packages/auth_service
pip install -e ".[dev]"
```

### 2. Configure Environment Variables

Create `.env` file or use Secret Manager:

```bash
# Required
FIREBASE_PROJECT_ID=your-project-id

# Option 1: Base64-encoded service account (recommended)
FIREBASE_SERVICE_ACCOUNT_BASE64=<base64_encoded_json>

# Option 2: Direct JSON (not recommended for production)
FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}'

# Optional
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
```

**Encode service account:**
```bash
base64 -i service-account.json | tr -d '\n' > service-account-base64.txt
```

### 3. Initialize in Your Microservice

```python
# your_service/main.py
from fastapi import FastAPI, Depends
from auth_service import init_firebase_admin, verify_firebase_token, AuthUser

app = FastAPI()

@app.on_event("startup")
async def startup():
    init_firebase_admin()
    print("✅ Firebase Admin initialized")

@app.get("/api/v1/protected")
async def protected_route(user: AuthUser = Depends(verify_firebase_token)):
    return {
        "message": f"Hello {user.email}",
        "uid": user.uid,
        "role": user.role
    }
```

### 4. Role-Based Endpoints

```python
from auth_service import require_role, require_any_role

# Admin only
@app.get("/api/v1/admin/users")
async def list_users(user: AuthUser = Depends(require_role("admin"))):
    return {"users": [...]}

# Admin or recruiter
@app.post("/api/v1/jobs")
async def create_job(user: AuthUser = Depends(require_any_role("admin", "recruiter"))):
    return {"job_id": "123"}
```

### 5. Setting Custom Claims (Admin Endpoint)

```python
from auth_service import set_custom_claims

@app.post("/api/v1/admin/users/{uid}/role")
async def assign_role(
    uid: str,
    role: str,
    tenant_id: str,
    admin: AuthUser = Depends(require_role("admin"))
):
    set_custom_claims(uid, {
        "role": role,
        "tenant_id": tenant_id,
    })
    return {"status": "success"}
```

## 🎨 Frontend Setup (Flutter)

### 1. Add Package Dependency

```yaml
# pubspec.yaml
dependencies:
  dashboard_auth:
    path: ../dashboard_auth
```

### 2. Initialize Firebase

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_auth/dashboard_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load from environment or config
  final firebaseConfig = FirebaseConfig(
    apiKey: const String.fromEnvironment('FIREBASE_API_KEY'),
    authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
    storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    messagingSenderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    appId: const String.fromEnvironment('FIREBASE_APP_ID'),
  );
  
  await FirebaseService().initialize(config: firebaseConfig);
  
  runApp(const ProviderScope(child: MyApp()));
}
```

### 3. Create Login Screen

```dart
// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_auth/dashboard_auth.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Navigate to home
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4. Use AuthWrapper for Route Protection

```dart
// lib/app.dart
import 'package:dashboard_auth/dashboard_auth.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthWrapper(
        child: HomeScreen(),
        signedOutBuilder: (context) => LoginScreen(),
      ),
    );
  }
}
```

### 5. Make Authenticated API Calls

```dart
// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:dashboard_auth/dashboard_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final authService = ref.watch(authServiceProvider);
  return createAuthenticatedDio(
    authService: authService,
    baseUrl: 'https://api.yourproject.com',
  );
});

// Usage
class GradingService {
  final Dio dio;
  GradingService(this.dio);

  Future<Map<String, dynamic>> submitAssignment(String assignmentId) async {
    final response = await dio.post(
      '/api/v1/grading/submit',
      data: {'assignment_id': assignmentId},
    );
    return response.data;
  }
}
```

### 6. Role-Based UI

```dart
import 'package:dashboard_auth/dashboard_auth.dart';

class AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRole: 'admin',
      child: Scaffold(
        appBar: AppBar(title: Text('Admin Panel')),
        body: AdminContent(),
      ),
      unauthorizedBuilder: (context) => Scaffold(
        body: Center(child: Text('Admin access required')),
      ),
    );
  }
}
```

## 🔐 Security Best Practices

### Backend

1. **Use Secret Manager** for production
   ```python
   # Example: AWS Secrets Manager
   import boto3
   import json
   
   client = boto3.client('secretsmanager')
   secret = client.get_secret_value(SecretId='firebase-service-account')
   service_account = json.loads(secret['SecretString'])
   ```

2. **Validate custom claims** before critical operations
   ```python
   if not verify_custom_claims(user, {"role": "admin", "tenant_id": tenant_id}):
       raise HTTPException(403, "Insufficient permissions")
   ```

3. **Enable rate limiting** on auth endpoints

4. **Log all authentication events**

### Frontend

1. **Use environment variables** for Firebase config
   ```bash
   flutter run --dart-define=FIREBASE_API_KEY=xxx
   ```

2. **Enable App Check** to prevent abuse
   ```dart
   await FirebaseAppCheck.instance.activate();
   ```

3. **Handle token expiration** gracefully
   ```dart
   dio.interceptors.add(InterceptorsWrapper(
     onError: (error, handler) {
       if (error.response?.statusCode == 401) {
         // Navigate to login
       }
       handler.next(error);
     },
   ));
   ```

## 🌐 Google Cloud Integration

### Calling Vertex AI from Backend

```python
from google.cloud import aiplatform
from google.auth import default

# Use Application Default Credentials (ADC)
credentials, project = default()

aiplatform.init(
    project=project,
    location="us-central1",
    credentials=credentials
)

# Call Vertex AI
from vertexai.preview.generative_models import GenerativeModel

model = GenerativeModel("gemini-pro")
response = model.generate_content("Hello, Vertex AI!")
```

### Service Account Permissions

Ensure your service account has:
- `roles/firebase.admin` - For Firebase Admin SDK
- `roles/aiplatform.user` - For Vertex AI
- `roles/storage.objectViewer` - For Cloud Storage (if needed)
- `roles/secretmanager.secretAccessor` - For Secret Manager

## 🧪 Testing

### Backend Tests

```python
# tests/test_auth.py
import pytest
from fastapi.testclient import TestClient

def test_protected_endpoint_without_token(client: TestClient):
    response = client.get("/api/v1/protected")
    assert response.status_code == 401

def test_protected_endpoint_with_token(client: TestClient, mock_firebase_token):
    response = client.get(
        "/api/v1/protected",
        headers={"Authorization": f"Bearer {mock_firebase_token}"}
    )
    assert response.status_code == 200
```

### Frontend Tests

```dart
// test/auth_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard_auth/dashboard_auth.dart';

void main() {
  test('AuthUser hasRole works correctly', () {
    final user = AuthUser(uid: 'test', role: 'admin');
    expect(user.hasRole('user'), true);
    expect(user.hasRole('admin'), true);
  });
}
```

## 📚 Migration from JWT to Firebase

If migrating from JWT-based auth:

1. **Keep both systems running** temporarily
2. **Migrate user accounts** to Firebase
3. **Update all microservices** to use `auth_service` v0.2.0
4. **Update frontend** to use Firebase Authentication
5. **Test thoroughly** in staging environment
6. **Deploy backend** first, then frontend
7. **Monitor** for authentication errors
8. **Decommission JWT** system after successful migration

## 🆘 Troubleshooting

### "Firebase Admin not initialized"
- Ensure `init_firebase_admin()` is called on startup
- Check environment variables are set correctly

### "Invalid service account JSON"
- Verify JSON is valid with `python -m json.tool service-account.json`
- Check Base64 encoding if using that method

### "401 Unauthorized" from backend
- Verify ID token is being sent in Authorization header
- Check token hasn't expired (refresh if needed)
- Ensure backend is verifying tokens correctly

### "Token has expired"
- Frontend should automatically refresh tokens
- Check `forceRefresh: true` in `getIdToken()` if needed

### Vertex AI "Permission Denied"
- Verify service account has `roles/aiplatform.user`
- Check project ID is correct
- Ensure API is enabled: `gcloud services enable aiplatform.googleapis.com`

## 📞 Support

For issues or questions:
1. Check package READMEs
2. Review Firebase documentation
3. Check GitHub issues
4. Contact team leads

## 🔗 Related Documentation

- [auth_service README](../../packages/auth_service/README.md)
- [dashboard_auth README](../../packages_dashboard/dashboard_auth/README.md)
- [Firebase Auth Docs](https://firebase.google.com/docs/auth)
- [Vertex AI Docs](https://cloud.google.com/vertex-ai/docs)
