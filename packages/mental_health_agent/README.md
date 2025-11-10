# AI Agent for Mental Health Monitoring

Agente de IA que monitora indicadores de saúde mental de alunos, professores e colaboradores, identificando sinais de alerta precocemente e recomendando intervenções apropriadas.

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
