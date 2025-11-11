"""Content update agent for detecting outdated or deprecated content."""

import re
from datetime import datetime
from typing import Dict, List

from content_reviewer_agent.agents.base import BaseReviewAgent
from content_reviewer_agent.models.content import (
    Content,
    IssueSeverity,
    IssueType,
    ReviewIssue,
)


class ContentUpdateAgent(BaseReviewAgent):
    """Agent that detects outdated or deprecated content."""

    def __init__(self):
        """Initialize the content update agent."""
        super().__init__(
            name="Content Update Agent",
            description="Detects outdated technology references and deprecated APIs",
        )

        # Deprecated technologies and their replacements
        self.deprecated_tech: Dict[str, Dict[str, str]] = {
            "python 2": {
                "replacement": "Python 3",
                "reason": "Python 2 reached end-of-life in January 2020",
            },
            "react.createclass": {
                "replacement": "React.Component or functional components with hooks",
                "reason": "React.createClass is deprecated since React 15.5",
            },
            "jquery": {
                "replacement": "modern JavaScript (ES6+) or frameworks like React/Vue",
                "reason": "Modern browsers support native features that replace jQuery",
            },
            "angular.js": {
                "replacement": "Angular (2+)",
                "reason": "AngularJS reached end-of-life in January 2022",
            },
            "bower": {
                "replacement": "npm or yarn",
                "reason": "Bower is deprecated since 2017",
            },
        }

        # Version patterns to check
        self.version_patterns = [
            (r"python\s+2\.\d+", "Python 2"),
            (r"java\s+[1-7](?:\.\d+)?", "Java (old version)"),
            (r"node(?:js)?\s+[0-9]\.x", "Node.js (old version)"),
            (r"angular\s+1\.\d+", "AngularJS"),
        ]

        # Current year for date-based checks
        self.current_year = datetime.now().year

    async def review(self, content: Content) -> List[ReviewIssue]:
        """Review content for outdated information.

        Args:
            content: Content to review

        Returns:
            List of outdated content issues
        """
        issues = []

        # Check for deprecated technologies
        issues.extend(self._check_deprecated_tech(content))

        # Check for old version references
        issues.extend(self._check_old_versions(content))

        # Check for outdated dates
        issues.extend(self._check_outdated_dates(content))

        # Check for broken or old URL patterns
        issues.extend(self._check_outdated_urls(content))

        return issues

    def _check_deprecated_tech(self, content: Content) -> List[ReviewIssue]:
        """Check for deprecated technology references.

        Args:
            content: Content to check

        Returns:
            List of issues with deprecated tech
        """
        issues = []
        text_lower = content.text.lower()

        for tech, info in self.deprecated_tech.items():
            if tech.lower() in text_lower:
                issues.append(
                    ReviewIssue(
                        content_id=content.content_id,
                        issue_type=IssueType.DEPRECATED,
                        severity=IssueSeverity.HIGH,
                        description=f"Deprecated technology: {tech}",
                        original_text=tech,
                        suggested_fix=info["replacement"],
                        sources=[f"Reason: {info['reason']}"],
                        confidence=0.90,
                    )
                )

        return issues

    def _check_old_versions(self, content: Content) -> List[ReviewIssue]:
        """Check for old version references.

        Args:
            content: Content to check

        Returns:
            List of issues with old versions
        """
        issues = []

        for pattern, tech_name in self.version_patterns:
            matches = re.finditer(pattern, content.text, re.IGNORECASE)
            for match in matches:
                issues.append(
                    ReviewIssue(
                        content_id=content.content_id,
                        issue_type=IssueType.OUTDATED,
                        severity=IssueSeverity.MEDIUM,
                        description=f"Old version reference: {tech_name}",
                        original_text=match.group(),
                        suggested_fix=f"Update to latest version of {tech_name}",
                        location=f"Position {match.start()}",
                        confidence=0.85,
                    )
                )

        return issues

    def _check_outdated_dates(self, content: Content) -> List[ReviewIssue]:
        """Check for outdated date references.

        Args:
            content: Content to check

        Returns:
            List of issues with outdated dates
        """
        issues = []

        # Find year references
        year_pattern = r"\b(19\d{2}|20[0-1]\d|202[0-2])\b"
        years = re.finditer(year_pattern, content.text)

        for match in years:
            year = int(match.group())
            years_old = self.current_year - year

            # Flag if reference is more than 5 years old
            if years_old > 5:
                issues.append(
                    ReviewIssue(
                        content_id=content.content_id,
                        issue_type=IssueType.OUTDATED,
                        severity=(
                            IssueSeverity.LOW
                            if years_old < 10
                            else IssueSeverity.MEDIUM
                        ),
                        description=f"Reference to {year} is {years_old} years old",
                        original_text=match.group(),
                        suggested_fix=f"Consider updating statistics or examples from {year}",
                        location=f"Position {match.start()}",
                        confidence=0.70,
                    )
                )

        return issues

    def _check_outdated_urls(self, content: Content) -> List[ReviewIssue]:
        """Check for potentially outdated URLs.

        Args:
            content: Content to check

        Returns:
            List of issues with outdated URLs
        """
        issues = []

        # Check for old documentation URLs
        old_url_patterns = [
            (r"http://docs\.python\.org/2", "Python 2 documentation"),
            (r"http://(?!https)", "Non-HTTPS URL (security concern)"),
            (r"angularjs\.org", "AngularJS documentation (deprecated)"),
        ]

        for pattern, description in old_url_patterns:
            matches = re.finditer(pattern, content.text)
            for match in matches:
                issues.append(
                    ReviewIssue(
                        content_id=content.content_id,
                        issue_type=IssueType.OUTDATED,
                        severity=IssueSeverity.MEDIUM,
                        description=f"Outdated URL: {description}",
                        original_text=match.group(),
                        suggested_fix="Update to current documentation URL",
                        confidence=0.85,
                    )
                )

        return issues
