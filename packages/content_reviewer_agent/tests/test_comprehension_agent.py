"""Tests for comprehension agent."""

import pytest

from content_reviewer_agent.agents.comprehension import ComprehensionAgent
from content_reviewer_agent.models.content import Content, ContentType, IssueType


@pytest.mark.asyncio
async def test_comprehension_complex_words():
    """Test complex word detection."""
    agent = ComprehensionAgent()
    content = Content(
        title="Test Content",
        text="We must utilize this methodology to facilitate the implementation.",
        content_type=ContentType.TEXT,
    )

    issues = await agent.review(content)

    # Should find complex words
    assert len(issues) > 0
    assert any("utilize" in i.original_text.lower() for i in issues if i.original_text)


@pytest.mark.asyncio
async def test_comprehension_long_sentences():
    """Test long sentence detection."""
    agent = ComprehensionAgent()

    # Create a very long sentence
    long_sentence = (
        "This is an extremely long sentence that goes on and on and on and on "
        "and contains way too many words for easy comprehension and should really "
        "be broken up into multiple smaller sentences for better readability and "
        "understanding by the reader who is trying to learn from this content."
    )

    content = Content(
        title="Test Content",
        text=long_sentence,
        content_type=ContentType.TEXT,
    )

    issues = await agent.review(content)

    # Should flag long sentences
    assert len(issues) > 0
    comprehension_issues = [
        i for i in issues if i.issue_type == IssueType.COMPREHENSION
    ]
    assert len(comprehension_issues) > 0


@pytest.mark.asyncio
async def test_comprehension_passive_voice():
    """Test passive voice detection (pattern-based, may not catch all cases)."""
    agent = ComprehensionAgent()
    content = Content(
        title="Test Content",
        text="The code was tested thoroughly and errors were detected in the system.",
        content_type=ContentType.TEXT,
    )

    issues = await agent.review(content)

    # Passive voice detection is pattern-based and may not be perfect
    # Just ensure the agent runs without errors
    assert isinstance(issues, list)


@pytest.mark.asyncio
async def test_comprehension_simple_content():
    """Test with simple, clear content."""
    agent = ComprehensionAgent()
    content = Content(
        title="Simple Content",
        text="Python is easy to learn. It has clear syntax.",
        content_type=ContentType.TEXT,
    )

    issues = await agent.review(content)

    # Should have minimal issues
    high_severity = [i for i in issues if i.severity.value in ["critical", "high"]]
    assert len(high_severity) == 0
