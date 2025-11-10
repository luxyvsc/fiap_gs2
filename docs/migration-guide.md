# Guia de Migração - Monorepo Reorganizado

## 📋 Resumo da Reorganização

Este documento descreve a reorganização do projeto FIAP AI-Enhanced Learning Platform de uma estrutura tradicional `src/apps/` para um monorepo moderno baseado em pacotes independentes.

## 🔄 Mudanças Principais

### Estrutura Antiga
```
src/apps/
├── auth_service/
├── code_review_agent/
├── frontend_flutter/
└── ... (13 apps no total)
```

### Estrutura Nova
```
packages/                    # Pacotes Python
├── auth_service/
├── code_review_agent/
└── ... (10 pacotes)

packages_dashboard/          # Pacotes Flutter
├── frontend_flutter/
├── approval_interface/
└── gamified_exams/
```

## 🎯 Benefícios da Nova Estrutura

1. **Modularidade**: Cada pacote é independente e instalável
2. **Reutilização**: Pacotes podem ser usados em outros projetos
3. **Isolamento**: Dependências específicas por pacote
4. **Testabilidade**: Testes isolados e mais fáceis de manter
5. **Desenvolvimento**: Modo editável facilita desenvolvimento local
6. **Versionamento**: Cada pacote pode ter versão independente
7. **CI/CD**: Melhor integração com pipelines de build
8. **Padrões Modernos**: Uso de pyproject.toml e pubspec.yaml

## 📦 Estrutura de Pacote Python

Cada pacote Python segue esta estrutura:

```
packages/package_name/
├── src/
│   └── package_name/        # Código instalável
│       ├── __init__.py
│       ├── main.py
│       ├── api/             # Rotas FastAPI
│       ├── models/          # Pydantic models
│       ├── services/        # Lógica de negócio
│       └── repositories/    # Acesso a dados
├── tests/                   # Testes pytest
│   ├── conftest.py
│   ├── test_api.py
│   └── test_services.py
├── pyproject.toml           # Metadados e dependências
├── README.md                # Documentação
└── roadmap.md               # Roadmap de implementação
```

### pyproject.toml

Cada pacote usa `pyproject.toml` com:
- Metadados do pacote (nome, versão, descrição)
- Dependências de produção
- Dependências de desenvolvimento (pytest, black, isort, etc.)
- Configuração de ferramentas (black, isort, pytest, mypy)

### Instalação

```bash
# Instalar em modo editável
pip install -e "packages/package_name[dev]"

# Ou sem dependências dev
pip install -e packages/package_name
```

### Imports

Os imports mudaram de:
```python
# Antigo
from src.main import app
from src.models.user import User
```

Para:
```python
# Novo
from package_name.main import app
from package_name.models.user import User
```

## 📱 Estrutura de Pacote Flutter

Cada pacote Flutter segue esta estrutura:

```
packages_dashboard/package_name/
├── lib/
│   ├── src/                 # Implementação privada
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── services/
│   │   └── models/
│   └── package_name.dart    # Exports públicos
├── test/                    # Testes
│   └── package_name_test.dart
├── pubspec.yaml             # Metadados e dependências
├── README.md                # Documentação
└── roadmap.md               # Roadmap
```

### pubspec.yaml

Cada pacote define:
- Nome e descrição
- Versão
- Dependências (Flutter SDK, packages externos)
- Dev dependencies (flutter_test, lints)

### Path Dependencies

Para usar um pacote Flutter em outro:

```yaml
dependencies:
  outro_pacote:
    path: ../outro_pacote
```

### Instalação

```bash
cd packages_dashboard/package_name
flutter pub get
```

## 🔧 Desenvolvimento Local

### Python

```bash
# 1. Navegar até o pacote
cd packages/auth_service

# 2. Criar ambiente virtual (opcional)
python -m venv venv
source venv/bin/activate

# 3. Instalar em modo editável
pip install -e ".[dev]"

# 4. Rodar testes
pytest

# 5. Formatar código
black .
isort .

# 6. Verificar qualidade
flake8 .
mypy src
```

### Flutter

```bash
# 1. Navegar até o pacote
cd packages_dashboard/frontend_flutter

# 2. Instalar dependências
flutter pub get

# 3. Rodar testes
flutter test

# 4. Formatar código
flutter format .

# 5. Analisar código
flutter analyze

# 6. Rodar aplicação
flutter run -d chrome
```

## 🔗 Dependências Entre Pacotes

### Python

Para usar um pacote como dependência de outro:

**Opção 1: Path dependency no pyproject.toml**
```toml
[project]
dependencies = [
    "auth-service @ file:///absolute/path/to/packages/auth_service",
]
```

**Opção 2: Instalar ambos em modo editável**
```bash
pip install -e packages/auth_service
pip install -e packages/code_review_agent
```

### Flutter

Adicionar ao `pubspec.yaml`:
```yaml
dependencies:
  auth_package:
    path: ../auth_package
```

## 🧪 Testes

### Python

Os testes foram atualizados para usar imports absolutos:

```python
# Antigo
from src.main import app

# Novo
from auth_service.main import app
```

### Flutter

Testes continuam usando imports de pacote:

```dart
import 'package:frontend_flutter/frontend_flutter.dart';
```

## 📚 Documentação

Cada pacote possui:

1. **README.md**: Instruções de instalação, uso e desenvolvimento
2. **roadmap.md**: Roadmap detalhado de implementação (migrado do original)
3. **Docstrings**: Documentação inline no código

Além disso, foram criados:
- `packages/README.md`: Visão geral dos pacotes Python
- `packages_dashboard/README.md`: Visão geral dos pacotes Flutter

## 🚀 CI/CD

A estrutura de pacotes facilita CI/CD:

```yaml
# Exemplo de workflow GitHub Actions
jobs:
  test-python:
    strategy:
      matrix:
        package:
          - auth_service
          - code_review_agent
          # ... outros pacotes
    steps:
      - name: Install package
        run: pip install -e "packages/${{ matrix.package }}[dev]"
      
      - name: Run tests
        run: |
          cd packages/${{ matrix.package }}
          pytest
```

## 🔐 Segurança

Mantidas as mesmas práticas:
- Não commitar secrets
- Usar variáveis de ambiente
- Validar inputs com Pydantic
- Usar flask_secure_storage no Flutter

## ⚡ Performance

Benefícios de performance:
- **Builds mais rápidos**: Apenas pacotes modificados precisam rebuild
- **Testes mais rápidos**: Testar apenas pacotes modificados
- **Cache efetivo**: Dependências podem ser cacheadas por pacote
- **Deploy seletivo**: Deploy apenas dos pacotes modificados

## 📋 Checklist de Migração

- [x] Criar diretórios `packages/` e `packages_dashboard/`
- [x] Migrar código Python para `packages/`
- [x] Criar `pyproject.toml` para cada pacote Python
- [x] Migrar código Flutter para `packages_dashboard/`
- [x] Criar `pubspec.yaml` para cada pacote Flutter
- [x] Atualizar imports nos testes
- [x] Criar README para cada pacote
- [x] Atualizar documentação principal
- [x] Remover diretório `src/apps/` antigo
- [x] Testar instalação de pacotes
- [x] Verificar estrutura final

## 🎓 Próximos Passos

1. **Implementar pacotes restantes**: Adicionar código aos pacotes que só têm roadmaps
2. **Configurar CI/CD**: Criar workflows para testar todos os pacotes
3. **Documentação de APIs**: Gerar docs automáticos com Sphinx/MkDocs
4. **Publicação**: Considerar publicar pacotes no PyPI/pub.dev
5. **Versionamento**: Definir estratégia de versioning (semver)
6. **Shared libraries**: Criar pacotes compartilhados para código comum

## 📞 Suporte

Para dúvidas sobre a nova estrutura:
1. Consulte o README do pacote específico
2. Revise este guia de migração
3. Consulte `docs/developer-guide.md`
4. Abra uma issue no GitHub

---

**Data da Migração**: 2025-11-10
**Versão**: 1.0
**Status**: ✅ Completo
