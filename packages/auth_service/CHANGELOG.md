# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0] - 2025-11-10

### Changed
- **BREAKING**: Migrated from JWT-based authentication to Firebase Authentication
- Replaced custom authentication logic with Firebase Admin SDK
- Removed dependencies: `python-jose`, `passlib`, `bcrypt`, `boto3`
- Added dependency: `firebase-admin>=6.2.0`

### Added
- Firebase Admin SDK initialization with multiple configuration options
- Support for Application Default Credentials (ADC)
- FastAPI middleware for Firebase ID token verification
- Role-Based Access Control (RBAC) dependencies
- Tenant-based access control
- Custom claims management utilities
- User management functions (create, update, delete)
- Comprehensive example application
- Unit tests for models and utilities
- Documentation with security best practices

### Removed
- JWT token generation and validation
- Password hashing with bcrypt
- OAuth2 implementation (now handled by Firebase)
- DynamoDB user repository
- Refresh token management (handled by Firebase)

## [0.1.0] - Initial Release

### Features
- JWT-based authentication
- User registration and login
- Password hashing with bcrypt
- OAuth2 integration (planned)
- DynamoDB storage
