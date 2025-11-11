"""Comprehension improvement agent."""

import re
from typing import List

from content_reviewer_agent.agents.base import BaseReviewAgent
from content_reviewer_agent.models.content import (
    Content,
    IssueSeverity,
    IssueType,
    ReviewIssue,
)


class ComprehensionAgent(BaseReviewAgent):
    """Agent that analyzes content for comprehension improvements."""

    def __init__(self):
        """Initialize the comprehension agent."""
        super().__init__(
            name="Comprehension Improvement Agent",
            description="Analyzes content clarity and suggests improvements for easier understanding",
        )

        # Complex words that could be simplified
        self.complex_words = {
            "utilize": "use",
            "implement": "build",
            "instantiate": "create",
            "terminate": "end",
            "commence": "start",
            "facilitate": "help",
            "methodology": "method",
            "paradigm": "model",
        }

        # Readability thresholds
        self.max_sentence_length = 25  # words
        self.max_paragraph_length = 150  # words

    async def review(self, content: Content) -> List[ReviewIssue]:
        """Review content for comprehension issues.

        Args:
            content: Content to review

        Returns:
            List of comprehension issues found
        """
        issues = []

        # Check for overly complex words
        issues.extend(self._check_complex_words(content))

        # Check sentence length
        issues.extend(self._check_sentence_length(content))

        # Check paragraph length
        issues.extend(self._check_paragraph_length(content))

        # Check for passive voice
        issues.extend(self._check_passive_voice(content))

        return issues

    def _check_complex_words(self, content: Content) -> List[ReviewIssue]:
        """Check for unnecessarily complex words.

        Args:
            content: Content to check

        Returns:
            List of issues with complex words
        """
        issues = []
        words = re.findall(r"\b\w+\b", content.text.lower())

        for word in words:
            if word in self.complex_words:
                issues.append(
                    ReviewIssue(
                        content_id=content.content_id,
                        issue_type=IssueType.COMPREHENSION,
                        severity=IssueSeverity.LOW,
                        description=f"Consider simplifying: '{word}' could be '{self.complex_words[word]}'",
                        original_text=word,
                        suggested_fix=self.complex_words[word],
                        confidence=0.75,
                    )
                )

        return issues

    def _check_sentence_length(self, content: Content) -> List[ReviewIssue]:
        """Check for overly long sentences.

        Args:
            content: Content to check

        Returns:
            List of issues with long sentences
        """
        issues = []
        sentences = re.split(r"[.!?]+", content.text)

        for sentence in sentences:
            if not sentence.strip():
                continue

            word_count = len(sentence.split())
            if word_count > self.max_sentence_length:
                issues.append(
                    ReviewIssue(
                        content_id=content.content_id,
                        issue_type=IssueType.COMPREHENSION,
                        severity=IssueSeverity.MEDIUM,
                        description=f"Long sentence ({word_count} words). Consider breaking it up for clarity.",
                        original_text=sentence.strip()[:100] + "...",
                        confidence=0.80,
                    )
                )

        return issues

    def _check_paragraph_length(self, content: Content) -> List[ReviewIssue]:
        """Check for overly long paragraphs.

        Args:
            content: Content to check

        Returns:
            List of issues with long paragraphs
        """
        issues = []
        paragraphs = content.text.split("\n\n")

        for i, paragraph in enumerate(paragraphs, 1):
            if not paragraph.strip():
                continue

            word_count = len(paragraph.split())
            if word_count > self.max_paragraph_length:
                issues.append(
                    ReviewIssue(
                        content_id=content.content_id,
                        issue_type=IssueType.COMPREHENSION,
                        severity=IssueSeverity.MEDIUM,
                        description=f"Long paragraph ({word_count} words). Consider breaking into smaller chunks.",
                        location=f"Paragraph {i}",
                        confidence=0.85,
                    )
                )

        return issues

    def _check_passive_voice(self, content: Content) -> List[ReviewIssue]:
        """Check for excessive passive voice usage.

        Args:
            content: Content to check

        Returns:
            List of issues with passive voice
        """
        issues = []

        # Simple passive voice detection (was/were + past participle)
        passive_patterns = [
            r"\b(is|are|was|were|be|been|being)\s+(being\s+)?\w+ed\b",
            r"\b(is|are|was|were|be|been|being)\s+\w+en\b",
        ]

        for pattern in passive_patterns:
            matches = re.finditer(pattern, content.text, re.IGNORECASE)
            for match in matches:
                issues.append(
                    ReviewIssue(
                        content_id=content.content_id,
                        issue_type=IssueType.COMPREHENSION,
                        severity=IssueSeverity.LOW,
                        description="Consider using active voice for better clarity",
                        original_text=match.group(),
                        location=f"Position {match.start()}",
                        confidence=0.65,
                    )
                )

        return issues
