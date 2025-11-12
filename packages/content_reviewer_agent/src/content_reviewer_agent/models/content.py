"""Content and review issue models."""

from datetime import datetime
from enum import Enum
from typing import Any, Dict, List, Optional
from uuid import uuid4

from pydantic import BaseModel, Field


class ContentType(str, Enum):
    """Type of content being reviewed."""

    TEXT = "text"
    CODE = "code"
    MARKDOWN = "markdown"
    HTML = "html"
    SLIDE = "slide"
    PDF = "pdf"


class IssueSeverity(str, Enum):
    """Severity level of a review issue."""

    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"
    INFO = "info"


class IssueType(str, Enum):
    """Type of issue found in content."""

    SPELLING = "spelling"
    GRAMMAR = "grammar"
    SYNTAX = "syntax"
    COMPREHENSION = "comprehension"
    SOURCE = "source"
    OUTDATED = "outdated"
    DEPRECATED = "deprecated"
    TECHNICAL = "technical"
    FACTUAL = "factual"


class Content(BaseModel):
    """Content to be reviewed."""

    content_id: str = Field(default_factory=lambda: str(uuid4()))
    title: str = Field(..., description="Title of the content")
    text: str = Field(..., description="Text content to review")
    content_type: ContentType = Field(
        default=ContentType.TEXT, description="Type of content"
    )
    discipline: Optional[str] = Field(None, description="Academic discipline")
    metadata: Dict[str, Any] = Field(
        default_factory=dict, description="Additional metadata"
    )
    created_at: datetime = Field(default_factory=datetime.utcnow)

    model_config = {
        "json_schema_extra": {
            "example": {
                "title": "Introduction to Python",
                "text": "Python is a high-level programming language...",
                "content_type": "text",
                "discipline": "Computer Science",
            }
        }
    }


class ReviewIssue(BaseModel):
    """An issue found during content review."""

    issue_id: str = Field(default_factory=lambda: str(uuid4()))
    content_id: str = Field(..., description="ID of the content with the issue")
    issue_type: IssueType = Field(..., description="Type of issue")
    severity: IssueSeverity = Field(..., description="Severity of the issue")
    description: str = Field(..., description="Description of the issue")
    location: Optional[str] = Field(None, description="Location in the content")
    original_text: Optional[str] = Field(None, description="Original problematic text")
    suggested_fix: Optional[str] = Field(None, description="Suggested correction")
    sources: List[str] = Field(
        default_factory=list, description="Reference sources for the issue"
    )
    confidence: float = Field(
        default=1.0, ge=0.0, le=1.0, description="Confidence score (0-1)"
    )
    reviewed_by_agent: Optional[str] = Field(
        None, description="Name of the AI agent that reviewed this content"
    )
    created_at: datetime = Field(default_factory=datetime.utcnow)

    model_config = {
        "json_schema_extra": {
            "example": {
                "content_id": "content-123",
                "issue_type": "spelling",
                "severity": "low",
                "description": "Spelling error detected",
                "original_text": "recieve",
                "suggested_fix": "receive",
                "confidence": 0.95,
                "reviewed_by_agent": "Error Detection Agent (Gemini 2.5 Flash)",
            }
        }
    }
