# SymbioWork - POC Futuro do Trabalho

## 🚀 Visão Geral

**SymbioWork** é um ecossistema inovador de assistentes de IA e ambientes de trabalho adaptativos que torna o trabalho mais humano, inclusivo e sustentável. O projeto utiliza agentes inteligentes como "companheiros de trabalho" (peer agents) que priorizam bem-estar, inclusão e práticas sustentáveis no ambiente corporativo do futuro.

### Objetivo

Responder ao desafio FIAP GS 2025.2: **"Como a tecnologia pode tornar o trabalho mais humano, inclusivo e sustentável no futuro?"**

## 🎯 Principais Funcionalidades

- **Ambientes de Trabalho Imersivos**: Coworking virtual adaptativo com controle inteligente de ambiente
- **Monitoramento de Bem-Estar**: Análise preditiva de saúde mental e física no trabalho
- **Agentes de Produtividade**: Assistentes IA que otimizam tarefas e sugerem pausas inteligentes
- **Recrutamento Inclusivo**: IA explicável para seleção ética e diversa
- **Sustentabilidade Laboral**: Medição e otimização do impacto ambiental do trabalho
- **Gamificação Corporativa**: Engajamento através de desafios e aprendizado contínuo

## 🏗️ Arquitetura

### Stack Tecnológico

- **Frontend**: Flutter (Microfrontends/Microservices)
- **Backend**: Python (Microservices Serverless)
- **Agentes IA**: CrewAI para orquestração de agentes inteligentes
- **Infraestrutura**: Serverless (AWS Lambda/Google Cloud Functions/Azure Functions)
- **Database**: Serverless (DynamoDB/Aurora Serverless/Firebase)
- **Analytics**: Python + R para análise estatística

### Estrutura de Pastas

```
fiap_gs2/
├── assets/              # Prints, anexos, imagens e recursos visuais
├── docs/                # Documentação completa do projeto
│   ├── roadmap-overview.md
│   ├── discipline-mapping.md
│   └── delivery-guidelines.md
├── src/                 # Código-fonte dividido por apps
│   └── apps/
│       ├── frontend_flutter/        # Frontend Flutter
│       ├── auth_service/            # Autenticação e autorização
│       ├── wellbeing_service/       # Monitoramento de bem-estar
│       ├── collaboration_service/   # Ambientes colaborativos
│       ├── recruitment_service/     # Recrutamento inclusivo
│       ├── green_work_service/      # Trabalho sustentável
│       ├── agents_orchestrator/     # Orquestração de agentes IA (CrewAI)
│       ├── analytics_service/       # Análise de dados e ML
│       └── dashboard_service/       # Dashboard e visualizações
└── .github/
    └── copilot-instructions.md      # Instruções para colaboradores
```

## 🎓 Integração Disciplinar FIAP

Este projeto integra todas as disciplinas do curso:

- **AICSS**: Assistentes críticos e sociais, políticas de uso responsável de IA
- **Cybersecurity**: Autenticação, proteção de dados sensíveis, auditoria
- **Machine Learning**: Modelos preditivos para bem-estar e produtividade
- **Redes Neurais**: Detecção de padrões em comportamento e saúde mental
- **Linguagem R**: Análise estatística e visualizações
- **Python**: Backend, pipelines de dados, automações
- **Computação em Nuvem**: Arquitetura serverless e escalável
- **Banco de Dados**: Modelagem híbrida (NoSQL + SQL serverless)
- **Formação Social**: Análise de impacto social, inclusão e ética

## 🚀 Como Começar

Para detalhes completos sobre configuração, desenvolvimento e contribuição, consulte:

📖 **[.github/copilot-instructions.md](.github/copilot-instructions.md)** - Guia completo para desenvolvedores

📋 **[docs/roadmap-overview.md](docs/roadmap-overview.md)** - Roadmap detalhado de implementação

📚 **[docs/discipline-mapping.md](docs/discipline-mapping.md)** - Mapeamento por disciplinas

📦 **[docs/delivery-guidelines.md](docs/delivery-guidelines.md)** - Guia de entrega GS

## 📋 Roadmaps por App

Cada aplicação possui seu próprio roadmap detalhado em `src/apps/<app_name>/roadmap.md`:

- [Frontend Flutter](src/apps/frontend_flutter/roadmap.md)
- [Auth Service](src/apps/auth_service/roadmap.md)
- [Wellbeing Service](src/apps/wellbeing_service/roadmap.md)
- [Collaboration Service](src/apps/collaboration_service/roadmap.md)
- [Recruitment Service](src/apps/recruitment_service/roadmap.md)
- [Green Work Service](src/apps/green_work_service/roadmap.md)
- [Agents Orchestrator](src/apps/agents_orchestrator/roadmap.md)
- [Analytics Service](src/apps/analytics_service/roadmap.md)
- [Dashboard Service](src/apps/dashboard_service/roadmap.md)

## 🎬 Entrega GS 2025.2

### Requisitos Mínimos

✅ MVP funcional com aplicação de IA, ML e todas as disciplinas  
✅ Coleta, tratamento e análise de dados  
✅ Demonstração prática em vídeo  
✅ PDF único com estrutura completa  
✅ Link do YouTube (não listado) sem mascaramento  

### Concorrendo ao Pódio

Para concorrer aos prêmios (shape + camiseta FIAP):

1. Integrar máximo de disciplinas
2. Utilizar dados/automações reais
3. Mostrar integração hardware/software (se aplicável)
4. Vídeo de até 7 minutos com:
   - Nome do grupo + "QUERO CONCORRER"
   - Explicação clara da integração entre disciplinas
   - Postado no YouTube como "não listado"

## 👥 Equipe

[Nomes completos dos integrantes aqui - 3 a 5 pessoas]

## 📄 Licença

Este projeto é uma Prova de Conceito (POC) desenvolvida para o desafio Global Solution da FIAP 2025.2.

---

**Tema GS 2025.2**: O Futuro do Trabalho  
**Instituição**: FIAP  
**Ano**: 2025