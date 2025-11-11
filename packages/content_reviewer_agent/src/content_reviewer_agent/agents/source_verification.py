"""Source verification agent."""

import re
from typing import List
from urllib.parse import urlparse

from content_reviewer_agent.agents.base import BaseReviewAgent
from content_reviewer_agent.models.content import (
    Content,
    IssueSeverity,
    IssueType,
    ReviewIssue,
)


class SourceVerificationAgent(BaseReviewAgent):
    """Agent that verifies sources and references in content."""

    def __init__(self):
        """Initialize the source verification agent."""
        super().__init__(
            name="Source Verification Agent",
            description="Verifies sources, citations, and references in content",
        )

        # Trusted domains for verification
        self.trusted_domains = [
            "wikipedia.org",
            "github.com",
            "stackoverflow.com",
            "python.org",
            "docs.python.org",
            "mozilla.org",
            "w3.org",
            "ieee.org",
            "acm.org",
            "arxiv.org",
            "scholar.google.com",
        ]

    async def review(self, content: Content) -> List[ReviewIssue]:
        """Review content sources and citations.

        Args:
            content: Content to review

        Returns:
            List of source-related issues
        """
        issues = []

        # Extract and verify URLs
        issues.extend(self._check_urls(content))

        # Check for missing citations
        issues.extend(self._check_citations(content))

        # Check for suspicious claims without sources
        issues.extend(self._check_unsupported_claims(content))

        return issues

    def _check_urls(self, content: Content) -> List[ReviewIssue]:
        """Check URLs in content.

        Args:
            content: Content to check

        Returns:
            List of URL-related issues
        """
        issues = []

        # Find all URLs
        url_pattern = r"https?://[^\s<>\"\'\)\\]+"
        urls = re.findall(url_pattern, content.text)

        for url in urls:
            parsed = urlparse(url)
            domain = parsed.netloc.lower()

            # Check if domain is trusted
            is_trusted = any(trusted in domain for trusted in self.trusted_domains)

            if not is_trusted:
                issues.append(
                    ReviewIssue(
                        content_id=content.content_id,
                        issue_type=IssueType.SOURCE,
                        severity=IssueSeverity.MEDIUM,
                        description=f"Unverified source: {domain}. Consider using trusted references.",
                        original_text=url,
                        sources=[url],
                        confidence=0.70,
                    )
                )

            # Check for broken URL patterns (basic validation)
            if not parsed.scheme or not parsed.netloc:
                issues.append(
                    ReviewIssue(
                        content_id=content.content_id,
                        issue_type=IssueType.SOURCE,
                        severity=IssueSeverity.HIGH,
                        description="Malformed URL detected",
                        original_text=url,
                        confidence=0.90,
                    )
                )

        return issues

    def _check_citations(self, content: Content) -> List[ReviewIssue]:
        """Check for proper citations.

        Args:
            content: Content to check

        Returns:
            List of citation issues
        """
        issues = []

        # Look for citation patterns like [1], (Author, Year)
        has_citations = bool(
            re.search(r"\[\d+\]|\([A-Z][a-z]+,\s*\d{4}\)", content.text)
        )

        # Look for quoted text without attribution
        quotes = re.findall(r'"([^"]{50,})"', content.text)
        if quotes and not has_citations:
            issues.append(
                ReviewIssue(
                    content_id=content.content_id,
                    issue_type=IssueType.SOURCE,
                    severity=IssueSeverity.MEDIUM,
                    description="Found quoted text without clear citation or source attribution",
                    confidence=0.75,
                )
            )

        return issues

    def _check_unsupported_claims(self, content: Content) -> List[ReviewIssue]:
        """Check for claims that should have sources.

        Args:
            content: Content to check

        Returns:
            List of issues with unsupported claims
        """
        issues = []

        # Patterns that often indicate claims needing sources
        claim_patterns = [
            r"research shows",
            r"studies have shown",
            r"according to",
            r"statistics show",
            r"\d+%\s+of",
            r"it has been proven",
            r"experts say",
        ]

        text_lower = content.text.lower()
        for pattern in claim_patterns:
            matches = re.finditer(pattern, text_lower)
            for match in matches:
                # Get surrounding context
                start = max(0, match.start() - 50)
                end = min(len(content.text), match.end() + 100)
                context = content.text[start:end]

                # Check if there's a nearby citation
                has_nearby_citation = bool(re.search(r"\[\d+\]|https?://", context))

                if not has_nearby_citation:
                    issues.append(
                        ReviewIssue(
                            content_id=content.content_id,
                            issue_type=IssueType.SOURCE,
                            severity=IssueSeverity.HIGH,
                            description=f"Claim requires citation: '{match.group()}'",
                            original_text=context.strip(),
                            location=f"Position {match.start()}",
                            confidence=0.80,
                        )
                    )

        return issues
