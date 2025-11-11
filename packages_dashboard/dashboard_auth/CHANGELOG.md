# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-11-10

### Added
- Initial release of Firebase Authentication Flutter package
- Firebase initialization service with multiple configuration options
- AuthService for all authentication operations:
  - Email/password sign-in and registration
  - Google Sign-In
  - Custom token authentication
  - Password reset
  - Email verification
  - Profile updates
  - Account deletion
- AuthUser model with custom claims support
- Role-based access control helpers
- Tenant-based access control helpers
- Dio HTTP interceptor for automatic token attachment
- Riverpod providers for authentication state management
- Authentication wrapper widgets:
  - AuthWrapper for route guarding
  - RoleGuard for role-based UI
  - TenantGuard for tenant-based UI
- Comprehensive documentation and examples
- Unit tests for models and utilities
- Flutter lints configuration

### Features
- Automatic ID token refresh
- Stream-based authentication state
- Custom claims in user model
- Multi-organization/tenant support
- Comprehensive error handling
- Logging with Logger package
- Type-safe API with strong typing
