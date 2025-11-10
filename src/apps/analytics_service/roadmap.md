# Analytics Service - Roadmap

## 📊 Visão Geral

Serviço de análise de dados, processamento e geração de insights usando Python (pandas, scikit-learn) e R (ggplot2, tidyverse).

### Responsabilidades
- Pipeline ETL de dados
- Análises estatísticas
- Modelos ML adicionais
- Visualizações e relatórios
- Scripts R para análises avançadas

---

## 🎯 Funcionalidades

1. **ETL Pipeline**
   - Coletar dados de todos os serviços
   - Transformar e limpar dados
   - Carregar em data warehouse (Aurora/BigQuery)

2. **Análises Estatísticas (R)**
   - Estatísticas descritivas
   - Testes de hipóteses
   - Correlações e regressões
   - Time series analysis

3. **Machine Learning**
   - Churn prediction
   - Clustering de usuários
   - Anomaly detection
   - Forecast de métricas

4. **Visualizações**
   - Dashboards interativos
   - Relatórios automatizados (PDF/Excel)
   - Gráficos R (ggplot2)

---

## 📋 Tarefas

### Fase 1: ETL Pipeline
- [ ] Coletar dados de:
  - Wellbeing events
  - Collaboration sessions
  - Agent actions
  - Green work events
- [ ] Transformações:
  - Agregações diárias/semanais
  - Feature engineering
  - Normalização
- [ ] Carregar em Aurora Serverless ou BigQuery

### Fase 2: Scripts R para Análises
- [ ] `eda.R` - Análise exploratória
  ```r
  library(tidyverse)
  library(ggplot2)
  
  # Carregar dados
  wellbeing <- read_csv("wellbeing_summary.csv")
  
  # Análise descritiva
  summary(wellbeing)
  
  # Visualização
  ggplot(wellbeing, aes(x=date, y=avg_stress)) +
    geom_line() +
    facet_wrap(~user_profile) +
    theme_minimal()
  ```
- [ ] `statistical_tests.R` - Testes de hipóteses
- [ ] `time_series.R` - Análise temporal
- [ ] `correlations.R` - Matriz de correlações

### Fase 3: Modelos ML
- [ ] **Churn Prediction**:
  - Features: engagement, stress, dias desde último login
  - Target: churn (sim/não nos próximos 30 dias)
  - Modelo: Gradient Boosting
- [ ] **User Clustering**:
  - Features: padrões de trabalho, preferências
  - Algoritmo: K-Means ou DBSCAN
  - Output: segmentos de usuários
- [ ] **Anomaly Detection**:
  - Isolation Forest ou Autoencoder
  - Detectar comportamentos anômalos

### Fase 4: API Endpoints
- [ ] `GET /api/v1/analytics/summary?period={period}`
- [ ] `GET /api/v1/analytics/trends?metric={metric}`
- [ ] `GET /api/v1/analytics/forecast?metric={metric}&days={n}`
- [ ] `GET /api/v1/analytics/clusters`
- [ ] `GET /api/v1/analytics/export?format={csv|pdf|xlsx}`

### Fase 5: Visualizações
- [ ] Integrar matplotlib/seaborn para Python
- [ ] Gerar plots R e salvar como PNG
- [ ] Criar relatórios R Markdown automatizados

### Fase 6: Testes e Deploy
- [ ] Testar pipeline ETL
- [ ] Testar modelos ML
- [ ] Deploy serverless (Lambda para Python, EC2/Fargate para R se necessário)

---

## 🔌 Endpoints

- `GET /api/v1/analytics/summary`
- `GET /api/v1/analytics/trends`
- `GET /api/v1/analytics/forecast`
- `GET /api/v1/analytics/clusters`
- `GET /api/v1/analytics/anomalies`
- `GET /api/v1/analytics/export`

---

## 📊 Database Schema

### Data Warehouse (Aurora Serverless)
```sql
CREATE TABLE fact_wellbeing (
    user_id UUID,
    date DATE,
    avg_stress_score FLOAT,
    total_breaks INT,
    hours_worked FLOAT,
    risk_level VARCHAR(20)
);

CREATE TABLE fact_collaboration (
    user_id UUID,
    date DATE,
    sessions_joined INT,
    total_time_minutes INT,
    messages_sent INT
);

CREATE TABLE fact_green_work (
    user_id UUID,
    date DATE,
    co2_kg FLOAT,
    transport_type VARCHAR(50),
    work_location VARCHAR(50)
);
```

---

## 🧪 ML Models

### Churn Prediction
- **Algorithm**: LightGBM
- **Features**: last_login_days, avg_stress, engagement_score, sessions_count
- **Evaluation**: AUC-ROC, Precision-Recall

### User Clustering
- **Algorithm**: K-Means (k=5)
- **Features**: work_hours, stress_avg, collaboration_frequency
- **Evaluation**: Silhouette Score

---

## ✅ Critérios de Aceitação

- [ ] ETL pipeline processando dados
- [ ] Scripts R executando análises
- [ ] Modelos ML treinados e deployados
- [ ] Visualizações geradas
- [ ] Endpoints respondendo
- [ ] Exportação de relatórios funcionando
- [ ] Testes OK
- [ ] Deploy serverless

---

## 📚 Referências

- [pandas Documentation](https://pandas.pydata.org/)
- [R for Data Science](https://r4ds.had.co.nz/)
- [scikit-learn](https://scikit-learn.org/)
- [ggplot2](https://ggplot2.tidyverse.org/)
