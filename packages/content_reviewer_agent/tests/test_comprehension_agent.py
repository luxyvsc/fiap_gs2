"""Tests for AI-powered comprehension agent."""

import os
from unittest.mock import Mock, patch

import pytest

from content_reviewer_agent.agents.comprehension import ComprehensionAgent
from content_reviewer_agent.models.ai_schema import AIReviewIssue, AIReviewResponse
from content_reviewer_agent.models.content import Content, ContentType, IssueType

# Check if Google API key is available for real API tests
HAS_GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY") is not None


@pytest.mark.asyncio
@pytest.mark.skipif(not HAS_GOOGLE_API_KEY, reason="GOOGLE_API_KEY not set")
async def test_comprehension_with_real_api():
    """Test comprehension agent with real Google AI API."""
    agent = ComprehensionAgent()
    content = Content(
        title="Test Content",
        text="The utilization of sophisticated methodologies necessitates comprehensive understanding.",
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
async def test_comprehension_complex_words():
    """Test detection of complex words."""
    agent = ComprehensionAgent()
    content = Content(
        title="Test Content",
        text="We must utilize this methodology.",
        content_type=ContentType.TEXT,
    )

    mock_response_data = AIReviewResponse(
        issues=[
            AIReviewIssue(
                type="comprehension",
                severity="low",
                description="Complex word can be simplified",
                original_text="utilize",
                suggested_fix="use",
                confidence=0.85,
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
async def test_comprehension_simple_content():
    """Test with simple, clear content."""
    agent = ComprehensionAgent()
    content = Content(
        title="Test Content",
        text="Python is easy to learn.",
        content_type=ContentType.TEXT,
    )

    mock_response_data = AIReviewResponse(issues=[])

    with patch.object(agent.client.models, "generate_content") as mock_generate:
        mock_resp = Mock()
        mock_resp.text = mock_response_data.model_dump_json()
        mock_generate.return_value = mock_resp

        issues = await agent.review(content)
        assert len(issues) == 0
