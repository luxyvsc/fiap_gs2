"""Tests for API endpoints."""

import pytest
from fastapi.testclient import TestClient

from content_reviewer_agent.main import app

client = TestClient(app)


def test_root_endpoint():
    """Test root endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "service" in data
    assert "version" in data


def test_health_check():
    """Test health check endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_get_agents():
    """Test get agents endpoint."""
    response = client.get("/api/v1/agents")
    assert response.status_code == 200
    data = response.json()
    assert "agents" in data
    assert len(data["agents"]) == 4


def test_review_content_full():
    """Test full content review."""
    content_data = {
        "title": "Test Content",
        "text": "I recieve emails and utilize methodology from 2010.",
        "content_type": "text",
    }

    response = client.post("/api/v1/review", json=content_data)
    assert response.status_code == 200
    data = response.json()
    assert "review_id" in data
    assert "issues" in data
    assert data["status"] == "completed"


def test_review_errors_endpoint():
    """Test error detection endpoint."""
    content_data = {
        "title": "Test",
        "text": "I recieve emails regularly.",
        "content_type": "text",
    }

    response = client.post("/api/v1/review/errors", json=content_data)
    assert response.status_code == 200
    data = response.json()
    assert data["review_type"] == "error_detection"


def test_review_comprehension_endpoint():
    """Test comprehension endpoint."""
    content_data = {
        "title": "Test",
        "text": "We must utilize this methodology.",
        "content_type": "text",
    }

    response = client.post("/api/v1/review/comprehension", json=content_data)
    assert response.status_code == 200
    data = response.json()
    assert data["review_type"] == "comprehension"


def test_review_sources_endpoint():
    """Test source verification endpoint."""
    content_data = {
        "title": "Test",
        "text": "Research shows that statistics indicate 90%.",
        "content_type": "text",
    }

    response = client.post("/api/v1/review/sources", json=content_data)
    assert response.status_code == 200
    data = response.json()
    assert data["review_type"] == "source_verification"


def test_review_updates_endpoint():
    """Test content update endpoint."""
    content_data = {
        "title": "Test",
        "text": "This uses Python 2.7 from 2010.",
        "content_type": "text",
    }

    response = client.post("/api/v1/review/updates", json=content_data)
    assert response.status_code == 200
    data = response.json()
    assert data["review_type"] == "content_update"


def test_review_with_query_param():
    """Test review with query parameter."""
    content_data = {
        "title": "Test",
        "text": "Test content",
        "content_type": "text",
    }

    response = client.post(
        "/api/v1/review?review_type=error_detection",
        json=content_data,
    )
    assert response.status_code == 200
    data = response.json()
    assert data["review_type"] == "error_detection"
