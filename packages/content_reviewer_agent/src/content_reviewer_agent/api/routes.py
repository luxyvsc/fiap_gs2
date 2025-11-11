"""API routes for content review."""

from typing import Optional

from fastapi import APIRouter, HTTPException, Query

from content_reviewer_agent.models.content import Content
from content_reviewer_agent.models.review_result import ReviewResult, ReviewType
from content_reviewer_agent.services.review_service import ContentReviewService

router = APIRouter(tags=["content-review"])

# Initialize service
review_service = ContentReviewService()


@router.post("/review", response_model=ReviewResult)
async def review_content(
    content: Content,
    review_type: Optional[ReviewType] = Query(
        ReviewType.FULL_REVIEW,
        description="Type of review to perform",
    ),
):
    """Review content with specified review type.

    Args:
        content: Content to review
        review_type: Type of review (full_review, error_detection, comprehension,
                     source_verification, content_update)

    Returns:
        ReviewResult with issues found
    """
    try:
        result = await review_service.review_content(content, review_type)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/agents")
async def get_agents():
    """Get information about available review agents.

    Returns:
        Dictionary with agent information
    """
    try:
        return await review_service.get_agent_info()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/review/errors", response_model=ReviewResult)
async def review_errors(content: Content):
    """Review content for errors only.

    Args:
        content: Content to review

    Returns:
        ReviewResult with error issues
    """
    return await review_service.review_content(content, ReviewType.ERROR_DETECTION)


@router.post("/review/comprehension", response_model=ReviewResult)
async def review_comprehension(content: Content):
    """Review content for comprehension improvements.

    Args:
        content: Content to review

    Returns:
        ReviewResult with comprehension issues
    """
    return await review_service.review_content(content, ReviewType.COMPREHENSION)


@router.post("/review/sources", response_model=ReviewResult)
async def review_sources(content: Content):
    """Review content sources and citations.

    Args:
        content: Content to review

    Returns:
        ReviewResult with source issues
    """
    return await review_service.review_content(content, ReviewType.SOURCE_VERIFICATION)


@router.post("/review/updates", response_model=ReviewResult)
async def review_updates(content: Content):
    """Review content for outdated information.

    Args:
        content: Content to review

    Returns:
        ReviewResult with outdated content issues
    """
    return await review_service.review_content(content, ReviewType.CONTENT_UPDATE)
