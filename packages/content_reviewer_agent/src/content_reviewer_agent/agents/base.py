"""Base agent interface for content reviewers."""

from abc import ABC, abstractmethod
from typing import List

from content_reviewer_agent.models.content import Content, ReviewIssue


class BaseReviewAgent(ABC):
    """Base class for all review agents."""

    def __init__(self, name: str, description: str):
        """Initialize the agent.

        Args:
            name: Name of the agent
            description: Description of what the agent does
        """
        self.name = name
        self.description = description

    @abstractmethod
    async def review(self, content: Content) -> List[ReviewIssue]:
        """Review content and return list of issues.

        Args:
            content: Content to review

        Returns:
            List of issues found
        """
        pass

    def __repr__(self) -> str:
        """String representation of the agent."""
        return f"{self.__class__.__name__}(name='{self.name}')"
