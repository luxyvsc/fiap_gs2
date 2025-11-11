"""Tests for source verification agent."""

import pytest

from content_reviewer_agent.agents.source_verification import SourceVerificationAgent
from content_reviewer_agent.models.content import Content, ContentType, IssueType


@pytest.mark.asyncio
async def test_source_trusted_urls():
    """Test trusted URL detection."""
    agent = SourceVerificationAgent()
    content = Content(
        title="Test Content",
        text="According to https://docs.python.org/3/, Python is great.",
        content_type=ContentType.TEXT,
    )

    issues = await agent.review(content)

    # Trusted URLs should not be flagged
    url_issues = [
        i
        for i in issues
        if i.issue_type == IssueType.SOURCE and "python.org" in str(i.original_text)
    ]
    # Should not flag trusted domains as unverified
    unverified = [i for i in url_issues if "unverified" in i.description.lower()]
    assert len(unverified) == 0


@pytest.mark.asyncio
async def test_source_untrusted_urls():
    """Test untrusted URL flagging."""
    agent = SourceVerificationAgent()
    content = Content(
        title="Test Content",
        text="Check out this site: https://random-blog-123.com/article",
        content_type=ContentType.TEXT,
    )

    issues = await agent.review(content)

    # Should flag untrusted URLs
    source_issues = [i for i in issues if i.issue_type == IssueType.SOURCE]
    assert len(source_issues) > 0


@pytest.mark.asyncio
async def test_source_missing_citations():
    """Test missing citation detection."""
    agent = SourceVerificationAgent()
    content = Content(
        title="Test Content",
        text='Research shows that "Python is the most popular language in 2024".',
        content_type=ContentType.TEXT,
    )

    issues = await agent.review(content)

    # Should flag missing citations
    citation_issues = [i for i in issues if "citation" in i.description.lower()]
    assert len(citation_issues) > 0


@pytest.mark.asyncio
async def test_source_claims_without_sources():
    """Test unsupported claims detection."""
    agent = SourceVerificationAgent()
    content = Content(
        title="Test Content",
        text="Studies have shown that 90% of developers prefer Python.",
        content_type=ContentType.TEXT,
    )

    issues = await agent.review(content)

    # Should flag claims needing sources
    claim_issues = [i for i in issues if "claim" in i.description.lower()]
    assert len(claim_issues) > 0


@pytest.mark.asyncio
async def test_source_with_proper_citations():
    """Test content with proper citations."""
    agent = SourceVerificationAgent()
    content = Content(
        title="Test Content",
        text="According to research [1], Python is popular. [1] https://docs.python.org/",
        content_type=ContentType.TEXT,
    )

    issues = await agent.review(content)

    # Should have fewer issues with proper citations
    critical_issues = [i for i in issues if i.severity.value == "critical"]
    assert len(critical_issues) == 0
