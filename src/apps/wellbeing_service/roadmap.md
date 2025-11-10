# Wellbeing Service - Roadmap

## 🧠 Visão Geral

Serviço responsável por monitorar bem-estar e saúde mental dos trabalhadores usando Machine Learning e análise preditiva.

### Responsabilidades
- Coleta de eventos de bem-estar (stress, energia, pausas)
- Modelos ML para detecção de burnout/stress
- Geração de recomendações personalizadas
- Alertas preventivos de saúde mental
- Análises e relatórios

---

## 🎯 Funcionalidades Principais

1. **Coleta de Dados**
   - Eventos manuais (auto-relato)
   - Dados simulados de biometria (stress score, sono, atividade)
   - Contexto (após reunião, durante deadline, etc)

2. **Modelos ML**
   - Random Forest para classificação de risco (low/medium/high)
   - LSTM para previsão de stress futuro
   - Clustering de perfis de bem-estar

3. **Recomendações**
   - Sugestão de pausas inteligentes
   - Redistribuição de tarefas se sobrecarga
   - Exercícios de respiração/meditação
   - Contato com apoio profissional se necessário

4. **Dashboard e Relatórios**
   - Evolução de métricas ao longo do tempo
   - Comparações (você vs média)
   - Exportação de relatórios

---

## 📋 Tarefas de Implementação

### Fase 1: Setup e API Base
- [ ] Estrutura de pastas e dependências
- [ ] FastAPI setup
- [ ] DynamoDB table para eventos
- [ ] Endpoints básicos:
  - `POST /api/v1/wellbeing/events` - Criar evento
  - `GET /api/v1/wellbeing/events?user_id={id}` - Listar eventos
  - `GET /api/v1/users/{id}/wellbeing` - Resumo

### Fase 2: Modelo ML de Detecção de Stress
- [ ] Dataset de treino (simulado ou real)
- [ ] Feature engineering (tempo trabalhado, pausas, reuniões, auto-relatos)
- [ ] Treinar Random Forest:
  - Input: features de 7 dias
  - Output: risco de burnout (0-1)
  - Métricas: accuracy, precision, recall
- [ ] Serializar modelo (joblib/pickle)
- [ ] Endpoint de predição: `POST /api/v1/wellbeing/predict`

### Fase 3: Modelo LSTM para Séries Temporais
- [ ] Preparar dados em formato de sequência temporal
- [ ] Arquitetura LSTM:
  ```python
  model = Sequential([
      LSTM(64, return_sequences=True, input_shape=(timesteps, features)),
      Dropout(0.2),
      LSTM(32),
      Dense(16, activation='relu'),
      Dense(1, activation='sigmoid')  # Stress score (0-1)
  ])
  ```
- [ ] Treinar com histórico de 30 dias
- [ ] Prever próximos 7 dias
- [ ] Endpoint: `GET /api/v1/wellbeing/forecast?user_id={id}`

### Fase 4: Sistema de Recomendações
- [ ] Regras baseadas em heurísticas:
  - Stress alto → sugerir pausa de 15min
  - 4h sem pausa → sugerir caminhada
  - Score de risco > 0.7 → alertar gestor (com consentimento)
- [ ] ML para recomendações personalizadas (opcional)
- [ ] Endpoint: `GET /api/v1/wellbeing/recommendations?user_id={id}`

### Fase 5: Integração com Agentes IA
- [ ] Wellbeing Agent (CrewAI) consome este serviço
- [ ] Agente monitora dados em tempo real
- [ ] Agente gera insights e ações

### Fase 6: Testes e Deploy
- [ ] Unit tests (modelos, endpoints)
- [ ] Integration tests
- [ ] Deploy serverless (Lambda)

---

## 🔌 Endpoints

- `POST /api/v1/wellbeing/events`
- `GET /api/v1/wellbeing/events?user_id={id}&start_date={date}&end_date={date}`
- `GET /api/v1/users/{id}/wellbeing` - Resumo
- `POST /api/v1/wellbeing/predict` - Predição ML
- `GET /api/v1/wellbeing/forecast?user_id={id}` - Previsão LSTM
- `GET /api/v1/wellbeing/recommendations?user_id={id}`

---

## 📊 Database Schema (DynamoDB)

### Table: symbiowork-wellbeing-events
```
PK: user_id#timestamp
SK: event_id
Attributes:
  - event_type: (stress_input, break_taken, meeting_end, task_completed)
  - value: Number (1-10 para stress, minutos para pausas)
  - metadata: Map (contexto adicional)
  - timestamp
```

### Table: symbiowork-wellbeing-summary (opcional)
```
PK: user_id#date
Attributes:
  - avg_stress_score
  - total_breaks
  - risk_level (low/medium/high)
  - prediction_score
```

---

## 🧪 ML Models

### Random Forest (Classificação de Risco)
- **Features**: stress scores últimos 7 dias, pausas, horas trabalhadas, reuniões
- **Target**: risco_burnout (0 = baixo, 1 = médio, 2 = alto)
- **Library**: scikit-learn
- **File**: `models/stress_classifier.pkl`

### LSTM (Previsão Temporal)
- **Input shape**: (7, 10) - 7 dias, 10 features
- **Output**: stress_score próximos 7 dias
- **Framework**: TensorFlow/Keras
- **File**: `models/stress_lstm.h5`

---

## ✅ Critérios de Aceitação

- [ ] Coleta de eventos funcionando
- [ ] Modelo ML treinado com accuracy > 70%
- [ ] LSTM prevê tendências com MAPE < 20%
- [ ] Recomendações geradas automaticamente
- [ ] Integração com frontend e agentes IA
- [ ] Testes cobertura 70%+
- [ ] Deploy serverless OK

---

## 📚 Referências

- [scikit-learn](https://scikit-learn.org/)
- [TensorFlow LSTM Tutorial](https://www.tensorflow.org/guide/keras/rnn)
- [Burnout Detection with ML](https://arxiv.org/abs/example) (papers de referência)
