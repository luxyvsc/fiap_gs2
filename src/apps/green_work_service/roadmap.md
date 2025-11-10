# Green Work Service - Roadmap

## 🌱 Visão Geral

Serviço para medir e otimizar o impacto ambiental do trabalho, promovendo práticas sustentáveis.

### Responsabilidades
- Calcular carbon footprint individual e coletivo
- Comparar trabalho remoto vs presencial
- Sugerir práticas sustentáveis
- Gamificar comportamentos ecológicos
- Dashboard de sustentabilidade

---

## 🎯 Funcionalidades

1. **Cálculo de Carbon Footprint**
   - Transporte (carro, transporte público, bicicleta)
   - Consumo de energia (escritório vs home office)
   - Reuniões virtuais (câmera on/off, duração)
   - Equipamentos (computador, ar condicionado)

2. **Comparações**
   - Você vs média da empresa
   - Remoto vs presencial
   - Esta semana vs semana anterior
   - Evolução mensal

3. **Recomendações**
   - "Trabalhe de casa 2x/semana → -10kg CO2/mês"
   - "Desligue câmera em reuniões grandes → -2kg CO2/mês"
   - "Use bicicleta 1x/semana → -5kg CO2/mês"

4. **Gamificação**
   - Badges: "Ciclista Urbano", "Energia Limpa", "Remoto Consciente"
   - Pontos por ações sustentáveis
   - Leaderboard verde (opcional)
   - Desafios mensais

---

## 📋 Tarefas

### Fase 1: Modelo de Cálculo de CO2
- [ ] Definir fatores de emissão:
  ```python
  EMISSION_FACTORS = {
      "car_km": 0.17,  # kg CO2 por km
      "bus_km": 0.08,
      "bike_km": 0.0,
      "home_office_hour": 0.05,  # energia casa
      "office_hour": 0.12,  # energia escritório
      "video_meeting_hour_camera_on": 0.15,
      "video_meeting_hour_camera_off": 0.05,
  }
  ```
- [ ] Função de cálculo:
  ```python
  def calculate_footprint(user_data):
      total = 0
      total += user_data["car_km"] * EMISSION_FACTORS["car_km"]
      total += user_data["home_hours"] * EMISSION_FACTORS["home_office_hour"]
      # ...
      return total  # kg CO2
  ```

### Fase 2: API de Coleta de Dados
- [ ] Endpoints:
  - `POST /api/v1/green-work/events` - Registrar ação
  - `GET /api/v1/green-work/footprint?user_id={id}&period={week|month}`
  - `GET /api/v1/green-work/comparison?user_id={id}`

### Fase 3: Sistema de Recomendações
- [ ] Regras heurísticas:
  - Se usa carro diariamente → sugerir transporte público/bike
  - Se câmera sempre ligada → sugerir desligar em reuniões grandes
  - Se trabalha 100% presencial → sugerir dias remotos
- [ ] Endpoint: `GET /api/v1/green-work/recommendations?user_id={id}`
- [ ] Incluir impacto estimado (quantos kg CO2 economizaria)

### Fase 4: Gamificação
- [ ] Definir badges:
  - "Ciclista Urbano": 10 dias de bicicleta
  - "Home Office Hero": 20 dias remotos em 1 mês
  - "Câmera Off Champion": 50h de reuniões sem câmera
  - "Carbon Neutral": reduziu 50kg CO2
- [ ] Sistema de pontos: 1 ponto = 1kg CO2 reduzido
- [ ] Endpoint: `GET /api/v1/green-work/achievements?user_id={id}`
- [ ] Leaderboard: `GET /api/v1/green-work/leaderboard?period={month}`

### Fase 5: Dashboard e Visualizações
- [ ] Evolução temporal (line chart)
- [ ] Breakdown por categoria (pie chart)
- [ ] Comparações (bar chart)
- [ ] Badges e achievements

### Fase 6: Testes e Deploy
- [ ] Validar cálculos com benchmarks
- [ ] Testes de endpoints
- [ ] Deploy serverless

---

## 🔌 Endpoints

- `POST /api/v1/green-work/events`
- `GET /api/v1/green-work/footprint?user_id={id}&period={period}`
- `GET /api/v1/green-work/comparison?user_id={id}`
- `GET /api/v1/green-work/recommendations?user_id={id}`
- `GET /api/v1/green-work/achievements?user_id={id}`
- `GET /api/v1/green-work/leaderboard?period={period}`

---

## 📊 Database Schema

### Table: symbiowork-green-events
```
PK: user_id#date
Attributes:
  - transport_type (car, bus, bike, walk)
  - distance_km
  - work_location (home, office)
  - hours_worked
  - meetings_camera_on_hours
  - meetings_camera_off_hours
  - date
```

### Table: symbiowork-green-footprint
```
PK: user_id#date
Attributes:
  - total_co2_kg
  - transport_co2
  - energy_co2
  - meetings_co2
  - date
```

---

## 🌍 Fatores de Emissão (Referências)

Baseado em estudos:
- [EPA Carbon Footprint Calculator](https://www.epa.gov/carbon-footprint-calculator)
- [Carbon Trust](https://www.carbontrust.com/)
- [Our World in Data - CO2 Emissions](https://ourworldindata.org/co2-emissions)

---

## ✅ Critérios de Aceitação

- [ ] Cálculo de CO2 implementado e validado
- [ ] Coleta de eventos funcionando
- [ ] Recomendações personalizadas geradas
- [ ] Sistema de badges funcionando
- [ ] Leaderboard (opcional) implementado
- [ ] Dashboard com visualizações
- [ ] Integração frontend completa
- [ ] Testes OK
- [ ] Deploy serverless

---

## 📚 Referências

- [Carbon Footprint Calculation Methods](https://ghgprotocol.org/)
- [Gamification for Sustainability](https://www.researchgate.net/publication/gamification_sustainability)
