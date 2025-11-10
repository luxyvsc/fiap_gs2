# Collaboration Service - Roadmap

## 🤝 Visão Geral

Serviço para gerenciar ambientes de trabalho colaborativos virtuais, permitindo que equipes trabalhem juntas de forma imersiva e adaptativa.

### Responsabilidades
- Criar e gerenciar ambientes virtuais (salas)
- Gerenciar presença e disponibilidade
- Chat em tempo real
- Controles de ambiente (iluminação virtual, ruído de fundo)
- Notificações de atividades

---

## 🎯 Funcionalidades

1. **Ambientes Virtuais**
   - Criar salas públicas/privadas
   - Definir capacidade máxima
   - Temas (foco, brainstorming, social)
   - Ambientação (música, iluminação virtual)

2. **Gestão de Presença**
   - Status: disponível, ocupado, foco, ausente
   - Localização virtual (em qual sala)
   - "Do Not Disturb" mode
   - Notificações de entrada/saída

3. **Comunicação**
   - Chat de texto (WebSocket)
   - Compartilhamento de tela (integração opcional)
   - Reações e emojis
   - Threads de discussão

4. **Controles Adaptativos**
   - Ajustar "iluminação" virtual (cor ambiente)
   - Ruído branco/rosa para concentração
   - Música ambiente compartilhada
   - Pomodoro timer coletivo

---

## 📋 Tarefas

### Fase 1: API Base
- [ ] Endpoints:
  - `GET /api/v1/collaboration/environments` - Listar
  - `POST /api/v1/collaboration/environments` - Criar
  - `POST /api/v1/collaboration/environments/{id}/join` - Entrar
  - `POST /api/v1/collaboration/environments/{id}/leave` - Sair
  - `GET /api/v1/collaboration/environments/{id}/participants`

### Fase 2: Real-time (WebSocket)
- [ ] WebSocket server: `/ws/collaboration/{env_id}`
- [ ] Mensagens:
  - `user_joined`, `user_left`
  - `chat_message`
  - `status_change`
  - `environment_update` (controles)

### Fase 3: Controles de Ambiente
- [ ] Settings de ambiente:
  - `lighting_color`: hex color
  - `ambient_sound`: (none, white_noise, nature, lofi)
  - `focus_mode`: boolean
- [ ] Sincronizar entre participantes
- [ ] Persistir preferências

### Fase 4: Integração com Frontend
- [ ] Flutter exibe ambientes e participantes
- [ ] Chat em tempo real
- [ ] Controles visuais de ambiente

### Fase 5: Testes e Deploy
- [ ] Testes de WebSocket
- [ ] Load testing (100+ usuários simultâneos)
- [ ] Deploy serverless

---

## 🔌 Endpoints

- `GET /api/v1/collaboration/environments`
- `POST /api/v1/collaboration/environments`
- `GET /api/v1/collaboration/environments/{id}`
- `POST /api/v1/collaboration/environments/{id}/join`
- `POST /api/v1/collaboration/environments/{id}/leave`
- `GET /api/v1/collaboration/environments/{id}/participants`
- `PUT /api/v1/collaboration/environments/{id}/settings`
- `WebSocket /ws/collaboration/{env_id}`

---

## 📊 Database Schema

### Table: symbiowork-environments
```
PK: environment_id
Attributes:
  - name
  - type (public, private)
  - max_capacity
  - theme (focus, brainstorm, social)
  - settings (lighting, sound)
  - created_by
  - created_at
```

### Table: symbiowork-participants
```
PK: environment_id#user_id
Attributes:
  - user_id
  - status (available, busy, dnd)
  - joined_at
```

---

## ✅ Critérios de Aceitação

- [ ] CRUD de ambientes funcionando
- [ ] WebSocket com chat em tempo real
- [ ] Presença de usuários sincronizada
- [ ] Controles de ambiente aplicados
- [ ] Integração frontend completa
- [ ] Testes OK
- [ ] Deploy serverless

---

## 📚 Referências

- [WebSocket with FastAPI](https://fastapi.tiangolo.com/advanced/websockets/)
- [AWS API Gateway WebSocket](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-websocket-api.html)
