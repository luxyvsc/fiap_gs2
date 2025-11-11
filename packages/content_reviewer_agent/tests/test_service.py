"""Tests for review service."""

import pytest

from content_reviewer_agent.models.content import Content, ContentType
from content_reviewer_agent.models.review_result import ReviewStatus, ReviewType
from content_reviewer_agent.services.review_service import ContentReviewService


@pytest.mark.asyncio
async def test_service_full_review():
    """Test full review of content."""
    service = ContentReviewService()
    content = Content(
        title="Test Content",
        text="I recieve emails and utilize complex methodology from 2010.",
        content_type=ContentType.TEXT,
    )

    result = await service.review_content(content, ReviewType.FULL_REVIEW)

    assert result.status == ReviewStatus.COMPLETED
    assert result.content_id == content.content_id
    assert len(result.issues) > 0
    assert result.quality_score is not None
    assert result.summary
    assert len(result.recommendations) > 0


@pytest.mark.asyncio
async def test_service_error_only():
    """Test error detection only."""
    service = ContentReviewService()
    content = Content(
        title="Test Content",
        text="I recieve emails regularly.",
        content_type=ContentType.TEXT,
    )

    result = await service.review_content(content, ReviewType.ERROR_DETECTION)

    assert result.status == ReviewStatus.COMPLETED
    assert result.review_type == ReviewType.ERROR_DETECTION
    # Should only have error-related issues
    assert len(result.issues) > 0


@pytest.mark.asyncio
async def test_service_comprehension_only():
    """Test comprehension review only."""
    service = ContentReviewService()
    content = Content(
        title="Test Content",
        text="We must utilize this methodology to facilitate the implementation process.",
        content_type=ContentType.TEXT,
    )

    result = await service.review_content(content, ReviewType.COMPREHENSION)

    assert result.status == ReviewStatus.COMPLETED
    assert result.review_type == ReviewType.COMPREHENSION


@pytest.mark.asyncio
async def test_service_source_only():
    """Test source verification only."""
    service = ContentReviewService()
    content = Content(
        title="Test Content",
        text="Research shows that 90% of developers prefer Python.",
        content_type=ContentType.TEXT,
    )

    result = await service.review_content(content, ReviewType.SOURCE_VERIFICATION)

    assert result.status == ReviewStatus.COMPLETED
    assert result.review_type == ReviewType.SOURCE_VERIFICATION


@pytest.mark.asyncio
async def test_service_update_only():
    """Test content update check only."""
    service = ContentReviewService()
    content = Content(
        title="Test Content",
        text="This tutorial uses Python 2.7 and jQuery.",
        content_type=ContentType.TEXT,
    )

    result = await service.review_content(content, ReviewType.CONTENT_UPDATE)

    assert result.status == ReviewStatus.COMPLETED
    assert result.review_type == ReviewType.CONTENT_UPDATE
    assert len(result.issues) > 0


@pytest.mark.asyncio
async def test_service_clean_content():
    """Test with clean content."""
    service = ContentReviewService()
    content = Content(
        title="Clean Content",
        text="Python is easy to learn. It has clear syntax.",
        content_type=ContentType.TEXT,
    )

    result = await service.review_content(content, ReviewType.FULL_REVIEW)

    assert result.status == ReviewStatus.COMPLETED
    assert result.quality_score >= 80.0  # Should have high score


@pytest.mark.asyncio
async def test_service_get_agents():
    """Test getting agent information."""
    service = ContentReviewService()
    info = await service.get_agent_info()

    assert "agents" in info
    assert len(info["agents"]) == 4
    assert all("name" in agent for agent in info["agents"])
    assert all("description" in agent for agent in info["agents"])
