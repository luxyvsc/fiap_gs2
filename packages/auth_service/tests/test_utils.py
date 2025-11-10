"""
Tests for utility functions.
"""

import pytest

from auth_service.models import AuthUser
from auth_service.utils import verify_custom_claims


def test_verify_custom_claims_matching(mock_auth_user):
    """Test verify_custom_claims with matching claims."""
    result = verify_custom_claims(
        mock_auth_user, {"role": "user", "tenant_id": "test-tenant"}
    )
    assert result is True


def test_verify_custom_claims_not_matching(mock_auth_user):
    """Test verify_custom_claims with non-matching claims."""
    result = verify_custom_claims(mock_auth_user, {"role": "admin"})
    assert result is False


def test_verify_custom_claims_missing_claim(mock_auth_user):
    """Test verify_custom_claims with missing claim."""
    result = verify_custom_claims(
        mock_auth_user, {"role": "user", "missing_claim": "value"}
    )
    assert result is False


def test_verify_custom_claims_with_custom_dict():
    """Test verify_custom_claims with custom claims dictionary."""
    user = AuthUser(
        uid="user123",
        email="user@example.com",
        role="user",
        custom_claims={"subscription": "premium", "level": 5},
    )
    result = verify_custom_claims(user, {"subscription": "premium", "level": 5})
    assert result is True

    result = verify_custom_claims(user, {"subscription": "basic"})
    assert result is False
