# Content Review Example App

A Flutter web/mobile application demonstrating the Content Reviewer Agent API integration with support for multiple content formats.

## Features

- **Multiple Content Formats**: 
  - Plain Text
  - HTML (with live preview)
  - Markdown (with live preview)
  - File Upload (.txt, .html, .md)
- **Full Review**: Run all four agents simultaneously
- **Error Detection**: Check for spelling, grammar, and syntax errors
- **Comprehension Analysis**: Analyze readability and suggest simplifications
- **Source Verification**: Verify citations and sources
- **Content Update**: Detect outdated or deprecated content
- **Agent Attribution**: See which AI agent (with model name) detected each issue

## Architecture

The app follows a clean architecture pattern:

```
lib/
├── models/           # Data models matching API responses
├── services/         # API client service
├── screens/          # Main UI screens
└── widgets/          # Reusable UI components
```

## Running the App

### Prerequisites

1. Start the Content Reviewer Agent API:

```bash
cd ../../  # Go to content_reviewer_agent package root
pip install -e ".[dev]"
export GOOGLE_API_KEY="your-google-api-key"  # Required for AI agents
python -m content_reviewer_agent.main
```

The API will run on `http://localhost:8000`

2. Install Flutter dependencies:

```bash
flutter pub get
```

### Run on Web

```bash
flutter run -d chrome
```

### Run on Mobile

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Usage

### Basic Text Input

1. **Enter Content**: The app comes pre-loaded with sample content demonstrating various issues
2. **Select Review Type**: Choose which type of review to perform
3. **Configure API URL**: Default is `http://localhost:8000`, change if needed
4. **Click Review**: Press the "Review Content" button
5. **View Results**: See issues categorized by severity with suggested fixes

### HTML Content

1. Select "HTML" from Content Type dropdown
2. Enter HTML code in the text field
3. See live preview above the editor
4. Review results will analyze the HTML content

### Markdown Content

1. Select "Markdown" from Content Type dropdown
2. Enter Markdown text in the text field
3. See live rendered preview above the editor
4. Review results will analyze the Markdown content

### File Upload

1. Click "Load from File" button
2. Select a file (.txt, .html, or .md)
3. Content type is auto-detected based on file extension
4. File content is loaded into the editor
5. Review as normal

## UI Components

### Review Summary Card

Displays:
- Overall quality score
- Issue counts by severity
- Recommendations
- Review metadata

### Review Issue Card

Shows for each issue:
- Issue type and severity badge
- AI Agent attribution (e.g., "Error Detection Agent (gemini-2.5-flash)")
- Description
- Location in content
- Original problematic text
- Suggested fix
- Confidence score
- Reference sources

## API Integration

The app communicates with the Content Reviewer Agent API using:

- **Dio**: HTTP client for making API requests
- **Riverpod**: State management for service injection
- **Custom Models**: Dart classes mirroring Python Pydantic models

## Content Format Support

### Supported File Types

- `.txt` - Plain text files
- `.html`, `.htm` - HTML documents
- `.md`, `.markdown` - Markdown documents

### Rendering Libraries

- **flutter_html**: Renders HTML content with CSS support
- **flutter_markdown**: Renders Markdown with GitHub Flavored Markdown support
- **file_picker**: Cross-platform file selection

## Testing

```bash
# Run unit and widget tests
flutter test

# Run with coverage
flutter test --coverage

# Run analyzer
flutter analyze
```

## Technologies

- **Flutter**: Cross-platform UI framework
- **Riverpod**: State management
- **Dio**: HTTP client
- **Material 3**: Design system
- **flutter_html**: HTML rendering
- **flutter_markdown**: Markdown rendering
- **file_picker**: File selection

## Example Content

### HTML Example

```html
<h1>Sample HTML Content</h1>
<p>This is a <strong>sample</strong> paragraph with some <em>formatting</em>.</p>
<ul>
  <li>Item 1</li>
  <li>Item 2</li>
</ul>
```

### Markdown Example

```markdown
# Sample Markdown Content

This is a **sample** paragraph with some *formatting*.

- Item 1
- Item 2

[Visit Example](https://example.com)
```

## License

Part of FIAP Global Solution 2025.2 project.
