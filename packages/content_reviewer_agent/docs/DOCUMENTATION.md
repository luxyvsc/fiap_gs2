# Content Reviewer Agent - Complete Documentation

## Overview

The Content Reviewer Agent is an AI-powered system that automatically reviews educational content for errors, readability, source verification, and outdated information. It consists of four specialized agents that work together to ensure content quality.

## Architecture

### Four Specialized Agents

1. **Error Detection Agent** (`error_detection.py`)
   - Detects spelling errors
   - Identifies grammar issues
   - Checks syntax in code blocks
   - Pattern-based detection with confidence scores

2. **Comprehension Agent** (`comprehension.py`)
   - Analyzes readability metrics
   - Detects overly complex words
   - Identifies long sentences and paragraphs
   - Flags passive voice usage

3. **Source Verification Agent** (`source_verification.py`)
   - Validates URLs and sources
   - Checks for missing citations
   - Identifies unsupported claims
   - Verifies trusted domains

4. **Content Update Agent** (`content_update.py`)
   - Detects deprecated technologies
   - Identifies old version references
   - Flags outdated dates
   - Checks for obsolete URL patterns

### Service Layer

The `ContentReviewService` orchestrates all agents and provides:
- Unified review interface
- Quality score calculation
- Summary generation
- Recommendation system

### API Layer

FastAPI REST API with endpoints for:
- Full content review
- Individual agent reviews
- Agent information retrieval
- Health checks

## Installation

```bash
cd packages/content_reviewer_agent
pip install -e ".[dev]"
```

## Running the Service

### Local Development

```bash
# Run with uvicorn
cd src/content_reviewer_agent
uvicorn content_reviewer_agent.main:app --reload --port 8000

# Or run directly
python -m content_reviewer_agent.main
```

### Production Deployment

```bash
# Using gunicorn with uvicorn workers
gunicorn content_reviewer_agent.main:app \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000
```

## API Reference

### Base URL

```
http://localhost:8000
```

### Endpoints

#### POST /api/v1/review

Review content with specified review type.

**Request Body:**
```json
{
  "title": "Introduction to Python",
  "text": "Content to review...",
  "content_type": "text",
  "discipline": "Computer Science"
}
```

**Query Parameters:**
- `review_type`: `full_review`, `error_detection`, `comprehension`, `source_verification`, `content_update`

**Response:**
```json
{
  "review_id": "uuid",
  "content_id": "uuid",
  "review_type": "full_review",
  "status": "completed",
  "issues": [
    {
      "issue_id": "uuid",
      "content_id": "uuid",
      "issue_type": "spelling",
      "severity": "low",
      "description": "Spelling error: 'recieve'",
      "original_text": "recieve",
      "suggested_fix": "receive",
      "confidence": 0.95
    }
  ],
  "summary": "Found 5 issues: 1 high, 2 medium, 2 low",
  "recommendations": [
    "Consider running a spell checker before publishing"
  ],
  "quality_score": 85.0,
  "created_at": "2025-11-11T19:00:00Z",
  "completed_at": "2025-11-11T19:00:01Z"
}
```

#### POST /api/v1/review/errors

Review for errors only.

#### POST /api/v1/review/comprehension

Review for comprehension improvements.

#### POST /api/v1/review/sources

Review sources and citations.

#### POST /api/v1/review/updates

Check for outdated content.

#### GET /api/v1/agents

Get information about available agents.

**Response:**
```json
{
  "agents": [
    {
      "name": "Error Detection Agent",
      "description": "Detects spelling, grammar, and syntax errors",
      "review_type": "error_detection"
    }
  ]
}
```

## Usage Examples

### Python Client

```python
import httpx

async def review_content():
    client = httpx.AsyncClient()
    
    # Review content
    response = await client.post(
        "http://localhost:8000/api/v1/review",
        json={
            "title": "My Article",
            "text": "Content to review...",
            "content_type": "text"
        },
        params={"review_type": "full_review"}
    )
    
    result = response.json()
    print(f"Quality Score: {result['quality_score']}")
    print(f"Issues Found: {len(result['issues'])}")
    
    await client.aclose()
```

### cURL

```bash
# Full review
curl -X POST "http://localhost:8000/api/v1/review?review_type=full_review" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Content",
    "text": "I recieve emails regularly.",
    "content_type": "text"
  }'

# Get agents info
curl http://localhost:8000/api/v1/agents
```

## Testing

### Run All Tests

```bash
pytest -v
```

### Run with Coverage

```bash
pytest --cov=src --cov-report=html --cov-report=term
```

### Test Specific Agent

```bash
pytest tests/test_error_agent.py -v
```

## Issue Types and Severity

### Issue Types

- `spelling`: Spelling errors
- `grammar`: Grammar mistakes
- `syntax`: Code syntax errors
- `comprehension`: Readability issues
- `source`: Source/citation problems
- `outdated`: Outdated content
- `deprecated`: Deprecated technology
- `technical`: Technical inaccuracies
- `factual`: Factual errors

### Severity Levels

- `critical`: Must be fixed immediately
- `high`: Should be addressed soon
- `medium`: Moderate priority
- `low`: Minor issues
- `info`: Informational only

## Quality Score Calculation

The quality score starts at 100 and deducts points based on issue severity:

- Critical: -10 points
- High: -5 points
- Medium: -2 points
- Low: -1 point

Minimum score is 0. Higher scores indicate better content quality.

## Configuration

Environment variables (`.env` file):

```bash
# API Configuration
API_TITLE="Content Reviewer Agent API"
API_VERSION="1.0.0"
DEBUG=false

# AI Models (optional for future integration)
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
MODEL_NAME=gpt-4
TEMPERATURE=0.3

# Agent Configuration
MAX_RETRIES=3
TIMEOUT_SECONDS=120
```

## Flutter Example App

A complete Flutter example app is available in `example/content_review_example/`.

### Features

- Two-panel layout (input/results)
- Real-time API integration
- Material 3 design
- Responsive for web and mobile
- Pre-loaded sample content

### Running the Example

```bash
cd example/content_review_example

# Get dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on mobile
flutter run
```

See `example/content_review_example/README.md` for detailed instructions.

## Extending the Package

### Adding a New Agent

1. Create agent class in `src/content_reviewer_agent/agents/`:

```python
from content_reviewer_agent.agents.base import BaseReviewAgent
from content_reviewer_agent.models.content import Content, ReviewIssue

class MyNewAgent(BaseReviewAgent):
    def __init__(self):
        super().__init__(
            name="My New Agent",
            description="Description of what it does"
        )
    
    async def review(self, content: Content) -> List[ReviewIssue]:
        issues = []
        # Your review logic here
        return issues
```

2. Register in service (`services/review_service.py`):

```python
self.my_agent = MyNewAgent()

# Add to review logic
if review_type == ReviewType.MY_NEW_TYPE:
    issues.extend(await self.my_agent.review(content))
```

3. Add endpoint in `api/routes.py`:

```python
@router.post("/review/my-new-check", response_model=ReviewResult)
async def review_my_check(content: Content):
    return await review_service.review_content(
        content, ReviewType.MY_NEW_TYPE
    )
```

### Adding New Issue Types

Update `models/content.py`:

```python
class IssueType(str, Enum):
    # ... existing types ...
    MY_NEW_TYPE = "my_new_type"
```

## Performance Considerations

- **Async/Await**: All agents use async operations for better performance
- **Parallel Processing**: Multiple agents run concurrently in full review mode
- **Caching**: Consider adding Redis caching for repeated content reviews
- **Rate Limiting**: Implement rate limiting for production deployments

## Security

- Input validation with Pydantic models
- No direct code execution
- Sanitized error messages
- CORS configured (adjust for production)
- Environment variables for secrets

## Troubleshooting

### Common Issues

1. **Import Errors**
   ```bash
   pip install -e ".[dev]"
   ```

2. **Port Already in Use**
   ```bash
   uvicorn content_reviewer_agent.main:app --port 8001
   ```

3. **Test Failures**
   - Ensure package is installed in editable mode
   - Check Python version (3.11+ required)

## Contributing

1. Create a new branch
2. Make changes
3. Run tests: `pytest`
4. Run linters: `black .` and `isort .`
5. Submit pull request

## License

Part of FIAP Global Solution 2025.2 project.

## Support

For issues and questions, please create an issue in the GitHub repository.
