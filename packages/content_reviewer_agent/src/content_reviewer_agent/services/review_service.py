"""Content review service that orchestrates multiple agents."""

from datetime import datetime
from typing import List, Optional

from content_reviewer_agent.agents import (
    ComprehensionAgent,
    ContentUpdateAgent,
    ErrorDetectionAgent,
    SourceVerificationAgent,
)
from content_reviewer_agent.models.content import Content, ReviewIssue
from content_reviewer_agent.models.review_result import (
    ReviewResult,
    ReviewStatus,
    ReviewType,
)


class ContentReviewService:
    """Service that coordinates multiple review agents."""

    def __init__(self):
        """Initialize the review service with all agents."""
        self.error_agent = ErrorDetectionAgent()
        self.comprehension_agent = ComprehensionAgent()
        self.source_agent = SourceVerificationAgent()
        self.update_agent = ContentUpdateAgent()

    async def review_content(
        self,
        content: Content,
        review_type: ReviewType = ReviewType.FULL_REVIEW,
    ) -> ReviewResult:
        """Review content using specified review type.

        Args:
            content: Content to review
            review_type: Type of review to perform

        Returns:
            ReviewResult with issues found
        """
        result = ReviewResult(
            content_id=content.content_id,
            review_type=review_type,
            status=ReviewStatus.IN_PROGRESS,
        )

        try:
            issues: List[ReviewIssue] = []

            # Run appropriate agents based on review type
            if review_type == ReviewType.FULL_REVIEW:
                issues.extend(await self.error_agent.review(content))
                issues.extend(await self.comprehension_agent.review(content))
                issues.extend(await self.source_agent.review(content))
                issues.extend(await self.update_agent.review(content))

            elif review_type == ReviewType.ERROR_DETECTION:
                issues.extend(await self.error_agent.review(content))

            elif review_type == ReviewType.COMPREHENSION:
                issues.extend(await self.comprehension_agent.review(content))

            elif review_type == ReviewType.SOURCE_VERIFICATION:
                issues.extend(await self.source_agent.review(content))

            elif review_type == ReviewType.CONTENT_UPDATE:
                issues.extend(await self.update_agent.review(content))

            # Add all issues to result
            result.issues = issues

            # Generate summary and recommendations
            result.summary = self._generate_summary(issues)
            result.recommendations = self._generate_recommendations(issues)
            result.quality_score = self._calculate_quality_score(content, issues)

            # Mark as completed
            result.status = ReviewStatus.COMPLETED
            result.completed_at = datetime.utcnow()

        except Exception as e:
            result.status = ReviewStatus.FAILED
            result.summary = f"Review failed: {str(e)}"

        return result

    def _generate_summary(self, issues: List[ReviewIssue]) -> str:
        """Generate a summary of the review.

        Args:
            issues: List of issues found

        Returns:
            Summary string
        """
        if not issues:
            return "No issues found. Content looks good!"

        critical = len([i for i in issues if i.severity.value == "critical"])
        high = len([i for i in issues if i.severity.value == "high"])
        medium = len([i for i in issues if i.severity.value == "medium"])
        low = len([i for i in issues if i.severity.value == "low"])

        parts = []
        if critical:
            parts.append(f"{critical} critical")
        if high:
            parts.append(f"{high} high")
        if medium:
            parts.append(f"{medium} medium")
        if low:
            parts.append(f"{low} low")

        severity_text = ", ".join(parts)
        return f"Found {len(issues)} issue(s): {severity_text}"

    def _generate_recommendations(self, issues: List[ReviewIssue]) -> List[str]:
        """Generate recommendations based on issues.

        Args:
            issues: List of issues found

        Returns:
            List of recommendations
        """
        recommendations = []

        # Count issues by type
        issue_types = {}
        for issue in issues:
            issue_type = issue.issue_type.value
            issue_types[issue_type] = issue_types.get(issue_type, 0) + 1

        # Generate recommendations based on patterns
        if issue_types.get("spelling", 0) > 3:
            recommendations.append("Consider running a spell checker before publishing")

        if issue_types.get("comprehension", 0) > 5:
            recommendations.append(
                "Content may be too complex. Consider simplifying language and breaking up long sentences"
            )

        if issue_types.get("source", 0) > 2:
            recommendations.append("Add citations and references from trusted sources")

        if issue_types.get("outdated", 0) > 0:
            recommendations.append(
                "Update references to current versions and technologies"
            )

        if not recommendations:
            recommendations.append("Content quality is good overall")

        return recommendations

    def _calculate_quality_score(
        self, content: Content, issues: List[ReviewIssue]
    ) -> float:
        """Calculate an overall quality score.

        Args:
            content: The reviewed content
            issues: List of issues found

        Returns:
            Quality score from 0-100
        """
        if not content.text:
            return 0.0

        # Start with perfect score
        score = 100.0

        # Deduct points based on severity
        for issue in issues:
            if issue.severity.value == "critical":
                score -= 10
            elif issue.severity.value == "high":
                score -= 5
            elif issue.severity.value == "medium":
                score -= 2
            elif issue.severity.value == "low":
                score -= 1

        # Minimum score is 0
        return max(0.0, score)

    async def get_agent_info(self) -> dict:
        """Get information about all available agents.

        Returns:
            Dictionary with agent information
        """
        return {
            "agents": [
                {
                    "name": self.error_agent.name,
                    "description": self.error_agent.description,
                    "review_type": ReviewType.ERROR_DETECTION.value,
                },
                {
                    "name": self.comprehension_agent.name,
                    "description": self.comprehension_agent.description,
                    "review_type": ReviewType.COMPREHENSION.value,
                },
                {
                    "name": self.source_agent.name,
                    "description": self.source_agent.description,
                    "review_type": ReviewType.SOURCE_VERIFICATION.value,
                },
                {
                    "name": self.update_agent.name,
                    "description": self.update_agent.description,
                    "review_type": ReviewType.CONTENT_UPDATE.value,
                },
            ]
        }
