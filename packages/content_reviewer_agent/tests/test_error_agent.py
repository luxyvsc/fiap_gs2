"""Tests for error detection agent."""

import pytest

from content_reviewer_agent.agents.error_detection import ErrorDetectionAgent
from content_reviewer_agent.models.content import Content, ContentType, IssueType


@pytest.mark.asyncio
async def test_error_agent_spelling():
    """Test spelling error detection."""
    agent = ErrorDetectionAgent()
    content = Content(
        title="Test Content",
        text="I recieve emails regularly and occured issues with seperate accounts.",
        content_type=ContentType.TEXT,
    )

    issues = await agent.review(content)

    # Should find spelling errors
    assert len(issues) > 0
    spelling_issues = [i for i in issues if i.issue_type == IssueType.SPELLING]
    assert len(spelling_issues) >= 3  # recieve, occured, seperate


@pytest.mark.asyncio
async def test_error_agent_grammar():
    """Test grammar error detection."""
    agent = ErrorDetectionAgent()
    content = Content(
        title="Test Content",
        text="This is a example of  incorrect grammar.",
        content_type=ContentType.TEXT,
    )

    issues = await agent.review(content)

    # Should find grammar issues
    grammar_issues = [i for i in issues if i.issue_type == IssueType.GRAMMAR]
    assert len(grammar_issues) > 0


@pytest.mark.asyncio
async def test_error_agent_clean_content():
    """Test with clean content."""
    agent = ErrorDetectionAgent()
    content = Content(
        title="Clean Content",
        text="This is a well-written sentence with no errors.",
        content_type=ContentType.TEXT,
    )

    issues = await agent.review(content)

    # Should find minimal or no issues
    critical_issues = [i for i in issues if i.severity.value == "critical"]
    assert len(critical_issues) == 0


@pytest.mark.asyncio
async def test_error_agent_code_syntax():
    """Test code syntax checking."""
    agent = ErrorDetectionAgent()
    content = Content(
        title="Python Code",
        text="def my_function()\n    print('hello')",
        content_type=ContentType.CODE,
    )

    issues = await agent.review(content)

    # Should find syntax issues in code
    syntax_issues = [i for i in issues if i.issue_type == IssueType.SYNTAX]
    assert len(syntax_issues) > 0
