"""Error detection agent for spelling, grammar, and syntax checking."""

import re
from typing import List

from content_reviewer_agent.agents.base import BaseReviewAgent
from content_reviewer_agent.models.content import (
    Content,
    IssueSeverity,
    IssueType,
    ReviewIssue,
)


class ErrorDetectionAgent(BaseReviewAgent):
    """Agent that detects errors in content (spelling, grammar, syntax)."""

    def __init__(self):
        """Initialize the error detection agent."""
        super().__init__(
            name="Error Detection Agent",
            description="Detects spelling, grammar, and syntax errors in content",
        )

        # Common spelling errors (for demonstration)
        self.common_errors = {
            "recieve": "receive",
            "occured": "occurred",
            "seperate": "separate",
            "definately": "definitely",
            "accomodate": "accommodate",
            "untill": "until",
            "thier": "their",
            "wierd": "weird",
            "acheive": "achieve",
            "beleive": "believe",
        }

        # Grammar patterns to check
        self.grammar_patterns = [
            (r"\ba\s+[aeiou]", "Use 'an' before vowel sounds"),
            (r"\ban\s+[^aeiou]", "Use 'a' before consonant sounds"),
            (r"\s\s+", "Multiple consecutive spaces"),
            (r"[.!?]\s*[a-z]", "Sentence should start with capital letter"),
        ]

    async def review(self, content: Content) -> List[ReviewIssue]:
        """Review content for errors.

        Args:
            content: Content to review

        Returns:
            List of issues found
        """
        issues = []
        text = content.text.lower()

        # Check for spelling errors
        words = re.findall(r"\b\w+\b", text)
        for word in words:
            if word in self.common_errors:
                issues.append(
                    ReviewIssue(
                        content_id=content.content_id,
                        issue_type=IssueType.SPELLING,
                        severity=IssueSeverity.LOW,
                        description=f"Spelling error: '{word}'",
                        original_text=word,
                        suggested_fix=self.common_errors[word],
                        confidence=0.95,
                    )
                )

        # Check for grammar issues
        for pattern, message in self.grammar_patterns:
            matches = re.finditer(pattern, content.text)
            for match in matches:
                issues.append(
                    ReviewIssue(
                        content_id=content.content_id,
                        issue_type=IssueType.GRAMMAR,
                        severity=IssueSeverity.MEDIUM,
                        description=message,
                        original_text=match.group(),
                        location=f"Position {match.start()}-{match.end()}",
                        confidence=0.85,
                    )
                )

        # Check for syntax issues in code blocks
        if content.content_type.value == "code":
            issues.extend(self._check_code_syntax(content))

        return issues

    def _check_code_syntax(self, content: Content) -> List[ReviewIssue]:
        """Check syntax in code content.

        Args:
            content: Content with code

        Returns:
            List of syntax issues
        """
        issues = []

        # Check for common Python syntax issues (simplified)
        lines = content.text.split("\n")
        for i, line in enumerate(lines, 1):
            # Check for missing colons in control structures
            if re.search(r"(if|for|while|def|class)\s+.*[^:]$", line.strip()):
                if line.strip() and not line.strip().startswith("#"):
                    issues.append(
                        ReviewIssue(
                            content_id=content.content_id,
                            issue_type=IssueType.SYNTAX,
                            severity=IssueSeverity.HIGH,
                            description="Possible missing colon at end of statement",
                            original_text=line.strip(),
                            location=f"Line {i}",
                            confidence=0.75,
                        )
                    )

        return issues
