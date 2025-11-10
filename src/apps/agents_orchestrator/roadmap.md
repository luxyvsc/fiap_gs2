# Agents Orchestrator - Roadmap

## 🤖 Visão Geral

Orquestrador de agentes de IA usando CrewAI. Gerencia múltiplos agentes especializados que colaboram para melhorar produtividade, bem-estar e aprendizado.

### Responsabilidades
- Orquestração de agentes especializados (CrewAI)
- Comunicação entre agentes
- Execução de tarefas colaborativas
- Dashboard de atividades dos agentes
- Interface de chat com agentes

---

## 🎯 Agentes Principais

### 1. Productivity Agent
- **Objetivo**: Otimizar tarefas e sugerir melhor timing para execução
- **Ferramentas**: Acesso a task_service, calendar_service
- **Ações**:
  - Priorizar tarefas por urgência/importância
  - Sugerir redistribuição se sobrecarga
  - Notificar deadlines próximos
  - Recomendar horários de foco profundo

### 2. Wellbeing Agent
- **Objetivo**: Monitorar saúde mental e sugerir ações preventivas
- **Ferramentas**: Acesso a wellbeing_service
- **Ações**:
  - Detectar padrões de stress elevado
  - Sugerir pausas e exercícios
  - Alertar sobre risco de burnout
  - Recomendar atividades de descompressão

### 3. Learning Agent
- **Objetivo**: Recomendar cursos e conteúdos para upskilling
- **Ferramentas**: Acesso a skill_gap_analysis, course_catalog
- **Ações**:
  - Identificar lacunas de habilidades
  - Sugerir cursos relevantes
  - Criar planos de aprendizado personalizados
  - Acompanhar progresso

---

## 📋 Tarefas de Implementação

### Fase 1: Setup CrewAI
- [ ] Instalar dependências:
  ```
  crewai==0.1.x
  langchain==0.1.x
  openai==1.x  # ou anthropic
  ```
- [ ] Configurar API keys (OpenAI/Claude)
- [ ] Estrutura de pastas:
  ```
  agents_orchestrator/
  ├── agents/
  │   ├── productivity_agent.py
  │   ├── wellbeing_agent.py
  │   └── learning_agent.py
  ├── tools/
  │   ├── task_tool.py
  │   ├── wellbeing_tool.py
  │   └── calendar_tool.py
  ├── crew.py  # Orquestração
  └── main.py
  ```

### Fase 2: Implementar Agentes
- [ ] **Productivity Agent**:
  ```python
  from crewai import Agent, Task, Crew
  from langchain.llms import OpenAI
  
  productivity_agent = Agent(
      role='Productivity Optimizer',
      goal='Help user maximize productivity while maintaining work-life balance',
      backstory="""You are an AI assistant specialized in task management 
      and productivity optimization. You analyze work patterns and suggest 
      improvements.""",
      tools=[TaskTool(), CalendarTool()],
      llm=OpenAI(model="gpt-4")
  )
  ```
- [ ] **Wellbeing Agent** - similar structure
- [ ] **Learning Agent** - similar structure

### Fase 3: Tools para Agentes
- [ ] Implementar `TaskTool`:
  - `get_user_tasks(user_id)`
  - `update_task_priority(task_id, priority)`
  - `get_task_stats(user_id)`
- [ ] Implementar `WellbeingTool`:
  - `get_wellbeing_status(user_id)`
  - `get_stress_forecast(user_id)`
  - `suggest_break(user_id)`
- [ ] Implementar `CalendarTool`:
  - `get_upcoming_meetings(user_id)`
  - `find_free_slots(user_id)`

### Fase 4: Crew Orchestration
- [ ] Definir tarefas colaborativas:
  ```python
  task1 = Task(
      description="Analyze user's workload for tomorrow",
      agent=productivity_agent
  )
  
  task2 = Task(
      description="Check user's wellbeing status",
      agent=wellbeing_agent
  )
  
  task3 = Task(
      description="If workload is high and stress is elevated, suggest adjustments",
      agent=productivity_agent,
      context=[task1, task2]  # Depende de task1 e task2
  )
  
  crew = Crew(
      agents=[productivity_agent, wellbeing_agent],
      tasks=[task1, task2, task3],
      verbose=True
  )
  
  result = crew.kickoff()
  ```

### Fase 5: API Endpoints
- [ ] `GET /api/v1/agents` - Lista agentes e status
- [ ] `GET /api/v1/agents/{id}/actions` - Histórico de ações
- [ ] `POST /api/v1/agents/{id}/chat` - Enviar mensagem para agente
- [ ] `POST /api/v1/agents/execute-task` - Executar tarefa colaborativa
- [ ] `WebSocket /ws/agents` - Real-time updates

### Fase 6: Dashboard e Logging
- [ ] Armazenar ações dos agentes no DynamoDB
- [ ] Endpoint de dashboard com métricas:
  - Quantas ações por agente
  - Taxa de sucesso
  - Feedback dos usuários
- [ ] Logs estruturados (CloudWatch)

### Fase 7: Testes e Deploy
- [ ] Mock tools para testes
- [ ] Testar orquestração de agentes
- [ ] Deploy serverless (Lambda com cold start otimizado)

---

## 🔌 Endpoints

- `GET /api/v1/agents`
- `GET /api/v1/agents/{id}/status`
- `GET /api/v1/agents/{id}/actions?user_id={user}`
- `POST /api/v1/agents/{id}/chat`
- `POST /api/v1/agents/crew/execute`
- `WebSocket /ws/agents/{user_id}`

---

## 📊 Database Schema

### Table: symbiowork-agent-actions
```
PK: action_id
GSI: user_id-timestamp-index
Attributes:
  - agent_id (productivity, wellbeing, learning)
  - user_id
  - action_type (suggestion, alert, task_update)
  - description
  - status (pending, accepted, rejected)
  - timestamp
```

---

## ✅ Critérios de Aceitação

- [ ] 3 agentes implementados (Productivity, Wellbeing, Learning)
- [ ] Agentes colaboram em tarefas complexas
- [ ] Tools conectam agentes aos serviços backend
- [ ] Chat funciona com respostas contextuais
- [ ] Dashboard mostra atividade dos agentes
- [ ] WebSocket envia updates em tempo real
- [ ] Deploy serverless OK

---

## 📚 Referências

- [CrewAI Documentation](https://docs.crewai.com/)
- [LangChain Agents](https://python.langchain.com/docs/modules/agents/)
- [OpenAI API](https://platform.openai.com/docs/)
