"""Tests for AI-powered content update agent."""

import os
from unittest.mock import Mock, patch

import pytest

from content_reviewer_agent.agents.content_update import ContentUpdateAgent
from content_reviewer_agent.models.ai_schema import AIReviewIssue, AIReviewResponse
from content_reviewer_agent.models.content import Content, ContentType, IssueType

# Check if Google API key is available for real API tests
HAS_GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY") is not None


@pytest.mark.asyncio
@pytest.mark.skipif(not HAS_GOOGLE_API_KEY, reason="GOOGLE_API_KEY not set")
async def test_update_with_real_api():
    """Test content update agent with real Google AI API."""
    agent = ContentUpdateAgent()
    content = Content(
        title="Test Content",
        text="Use Python 2.7 and jQuery 1.0 for this legacy project.",
        content_type=ContentType.TEXT,
    )

    issues = await agent.review(content)

    # Should find issues when using real API
    assert isinstance(issues, list)
    # Results may vary with real API, so just check structure
    if len(issues) > 0:
        assert hasattr(issues[0], "issue_type")
        assert hasattr(issues[0], "severity")
        assert hasattr(issues[0], "description")
        assert hasattr(issues[0], "reviewed_by_agent")
        # Verify agent name includes model
        assert issues[0].reviewed_by_agent is not None
        assert "gemini" in issues[0].reviewed_by_agent.lower()


@pytest.mark.asyncio
async def test_update_deprecated_tech():
    """Test detection of deprecated technology."""
    agent = ContentUpdateAgent()
    content = Content(
        title="Test Content",
        text="Use Python 2.7 for this project.",
        content_type=ContentType.TEXT,
    )

    mock_response_data = AIReviewResponse(
        issues=[
            AIReviewIssue(
                type="deprecated",
                severity="high",
                description="Python 2.7 is deprecated",
                original_text="Python 2.7",
                suggested_fix="Python 3.11 or later",
                confidence=0.95,
            )
        ]
    )

    with patch.object(agent.client.models, "generate_content") as mock_generate:
        mock_resp = Mock()
        mock_resp.text = mock_response_data.model_dump_json()
        mock_generate.return_value = mock_resp

        issues = await agent.review(content)
        assert len(issues) >= 1
        assert issues[0].reviewed_by_agent is not None


@pytest.mark.asyncio
async def test_update_current_content():
    """Test with current technology references."""
    agent = ContentUpdateAgent()
    content = Content(
        title="Test Content",
        text="Use Python 3.11 for modern development.",
        content_type=ContentType.TEXT,
    )

    mock_response_data = AIReviewResponse(issues=[])

    with patch.object(agent.client.models, "generate_content") as mock_generate:
        mock_resp = Mock()
        mock_resp.text = mock_response_data.model_dump_json()
        mock_generate.return_value = mock_resp

        issues = await agent.review(content)
        assert len(issues) == 0
