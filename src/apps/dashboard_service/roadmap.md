# Dashboard Service - Roadmap

## 📈 Visão Geral

Serviço agregador que consolida dados de todos os microservices e fornece visualizações unificadas.

### Responsabilidades
- Agregar dados de múltiplos serviços
- Fornecer endpoint único para dashboard
- Cache de queries frequentes
- Geração de relatórios
- Real-time updates via WebSocket

---

## 🎯 Funcionalidades

1. **Dashboard Overview**
   - Cards de resumo (stress, tarefas, CO2)
   - Gráficos de evolução temporal
   - Notificações e alertas
   - Atividade recente

2. **Agregação de Dados**
   - Combinar wellbeing + collaboration + green work
   - Calcular KPIs globais
   - Comparações temporais

3. **Real-time Updates**
   - WebSocket para atualizações ao vivo
   - Push de notificações importantes

4. **Relatórios**
   - Geração de PDF/Excel
   - Relatórios periódicos automatizados
   - Exportação de dados

---

## 📋 Tarefas

### Fase 1: Agregação de Dados
- [ ] Criar funções para buscar dados de:
  - Wellbeing Service
  - Collaboration Service
  - Green Work Service
  - Agents Orchestrator
  - Analytics Service
- [ ] Combinar em estrutura unificada
- [ ] Calcular KPIs:
  - Overall health score (0-100)
  - Productivity index
  - Sustainability score

### Fase 2: API Endpoints
- [ ] `GET /api/v1/dashboard/overview?user_id={id}`
  - Retorna: resumo de todos os serviços
- [ ] `GET /api/v1/dashboard/notifications?user_id={id}`
  - Alertas e notificações
- [ ] `GET /api/v1/dashboard/activity?user_id={id}`
  - Atividade recente

### Fase 3: Cache
- [ ] Implementar Redis para cache
- [ ] TTL de 5 minutos para overview
- [ ] Invalidar cache em eventos importantes

### Fase 4: WebSocket
- [ ] `/ws/dashboard/{user_id}`
- [ ] Push de:
  - Novas recomendações de agentes
  - Alertas de bem-estar
  - Conquistas desbloqueadas

### Fase 5: Geração de Relatórios
- [ ] PDF com ReportLab (Python)
- [ ] Excel com openpyxl
- [ ] Agendar relatórios semanais/mensais
- [ ] Endpoint: `POST /api/v1/dashboard/generate-report`

### Fase 6: Testes e Deploy
- [ ] Testar agregação
- [ ] Testar cache
- [ ] Testar WebSocket
- [ ] Deploy serverless

---

## 🔌 Endpoints

- `GET /api/v1/dashboard/overview?user_id={id}`
- `GET /api/v1/dashboard/notifications?user_id={id}`
- `GET /api/v1/dashboard/activity?user_id={id}&limit={n}`
- `POST /api/v1/dashboard/generate-report`
- `WebSocket /ws/dashboard/{user_id}`

---

## 📊 Response Example

```json
{
  "user_id": "user-123",
  "timestamp": "2025-11-10T12:00:00Z",
  "overview": {
    "health_score": 75,
    "productivity_index": 82,
    "sustainability_score": 88
  },
  "wellbeing": {
    "current_stress": 6.5,
    "risk_level": "medium",
    "last_break": "2 hours ago"
  },
  "collaboration": {
    "current_environment": "Focus Room #3",
    "participants": 5
  },
  "green_work": {
    "co2_this_week": 12.5,
    "vs_last_week": -15.2
  },
  "agents": {
    "active_tasks": 2,
    "recent_actions": [...]
  },
  "notifications": [
    {
      "type": "wellbeing_alert",
      "message": "Consider taking a break",
      "timestamp": "..."
    }
  ]
}
```

---

## ✅ Critérios de Aceitação

- [ ] Agregação de dados funcionando
- [ ] Cache Redis implementado
- [ ] WebSocket com updates em tempo real
- [ ] Relatórios gerados (PDF/Excel)
- [ ] Integração frontend completa
- [ ] Testes OK
- [ ] Deploy serverless

---

## 📚 Referências

- [Redis with FastAPI](https://fastapi.tiangolo.com/advanced/async-redis/)
- [ReportLab for PDF](https://www.reportlab.com/docs/reportlab-userguide.pdf)
- [WebSocket with FastAPI](https://fastapi.tiangolo.com/advanced/websockets/)
