"""
Firebase Authentication Service for Microservices

This package provides Firebase Authentication utilities for backend microservices,
including token verification middleware and user management.
"""

from .firebase_admin import get_firebase_admin, init_firebase_admin
from .middleware import verify_firebase_token
from .models import AuthUser, FirebaseConfig
from .utils import get_user_claims, verify_custom_claims

__version__ = "0.2.0"

__all__ = [
    "get_firebase_admin",
    "init_firebase_admin",
    "verify_firebase_token",
    "AuthUser",
    "FirebaseConfig",
    "get_user_claims",
    "verify_custom_claims",
]
