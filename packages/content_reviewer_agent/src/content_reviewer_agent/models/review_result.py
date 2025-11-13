"""Review result models."""

from datetime import datetime
from enum import Enum
from typing import Any, Dict, List, Optional
from uuid import uuid4

from pydantic import BaseModel, Field

from content_reviewer_agent.models.content import ReviewIssue


class ReviewType(str, Enum):
    """Type of review performed."""

    ERROR_DETECTION = "error_detection"
    COMPREHENSION = "comprehension"
    SOURCE_VERIFICATION = "source_verification"
    CONTENT_UPDATE = "content_update"
    FULL_REVIEW = "full_review"


class ReviewStatus(str, Enum):
    """Status of a review."""

    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"


class ReviewResult(BaseModel):
    """Result of a content review."""

    review_id: str = Field(default_factory=lambda: str(uuid4()))
    content_id: str = Field(..., description="ID of the reviewed content")
    review_type: ReviewType = Field(..., description="Type of review performed")
    status: ReviewStatus = Field(
        default=ReviewStatus.PENDING, description="Status of the review"
    )
    issues: List[ReviewIssue] = Field(
        default_factory=list, description="Issues found during review"
    )
    summary: str = Field(default="", description="Summary of the review")
    recommendations: List[str] = Field(
        default_factory=list, description="Recommendations for improvement"
    )
    quality_score: Optional[float] = Field(
        None, ge=0.0, le=100.0, description="Overall quality score (0-100)"
    )
    metadata: Dict[str, Any] = Field(
        default_factory=dict, description="Additional metadata"
    )
    created_at: datetime = Field(default_factory=datetime.utcnow)
    completed_at: Optional[datetime] = None

    def add_issue(self, issue: ReviewIssue) -> None:
        """Add an issue to the review result."""
        self.issues.append(issue)

    def get_critical_issues(self) -> List[ReviewIssue]:
        """Get all critical issues."""
        return [issue for issue in self.issues if issue.severity.value == "critical"]

    def get_high_issues(self) -> List[ReviewIssue]:
        """Get all high severity issues."""
        return [issue for issue in self.issues if issue.severity.value == "high"]

    model_config = {
        "json_schema_extra": {
            "example": {
                "content_id": "content-123",
                "review_type": "full_review",
                "status": "completed",
                "summary": "Content reviewed successfully with 3 issues found",
                "quality_score": 85.0,
            }
        }
    }
