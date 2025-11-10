# AI Agent for AI Usage Detection

Agente de IA que detecta uso excessivo ou inadequado de ferramentas de IA (ChatGPT, Copilot, etc.) em trabalhos acadêmicos, promovendo uso ético e aprendizado genuíno.

## Installation

Install this package in editable mode for development:

```bash
pip install -e .
```

Or with development dependencies:

```bash
pip install -e ".[dev]"
```

## Usage

This package is part of the FIAP AI-Enhanced Learning Platform monorepo.

### Running Tests

```bash
pytest
```

### Running with Coverage

```bash
pytest --cov=src --cov-report=html
```

### Linting

```bash
# Format code
black .
isort .

# Check code quality
flake8 .
mypy src
```

## Development

This package follows the monorepo structure. See the main repository README for more details.

## License

Part of FIAP Global Solution 2025.2 project.
