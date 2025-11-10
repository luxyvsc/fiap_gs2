# Recruitment Service - Roadmap

## 👥 Visão Geral

Serviço de recrutamento inclusivo com IA explicável para triagem de candidatos, matching e detecção de viés.

### Responsabilidades
- Gerenciar vagas e candidaturas
- IA para triagem e ranking de candidatos
- Explicabilidade (SHAP values, LIME)
- Análise de diversidade
- Detecção de viés algorítmico

---

## 🎯 Funcionalidades

1. **Gestão de Vagas**
   - Criar/editar vagas
   - Definir requisitos e skills
   - Publicar vagas

2. **Candidaturas**
   - Upload de currículo (PDF parsing)
   - Formulário de candidatura
   - Tracking de status

3. **IA para Matching**
   - Similarity score (candidato x vaga)
   - Ranking de candidatos
   - Recomendação de vagas (para candidatos)

4. **Explicabilidade**
   - Por que candidato X foi rankeado Y?
   - SHAP values para features
   - "What-if" analysis

5. **Análise de Diversidade**
   - Métricas de diversidade (gênero, etnia, idade)
   - Alertas de baixa diversidade
   - Comparação com benchmark

6. **Detecção de Viés**
   - Fairness metrics (disparate impact, equal opportunity)
   - Alertas se viés detectado
   - Sugestões de mitigação

---

## 📋 Tarefas

### Fase 1: CRUD de Vagas e Candidaturas
- [ ] Endpoints:
  - `GET /api/v1/recruitment/jobs` - Listar vagas
  - `POST /api/v1/recruitment/jobs` - Criar vaga (RH)
  - `GET /api/v1/recruitment/jobs/{id}`
  - `POST /api/v1/recruitment/applications` - Candidatar
  - `GET /api/v1/recruitment/applications?job_id={id}` - Listar (RH)

### Fase 2: Parsing de Currículos
- [ ] Upload de PDF
- [ ] Extração de texto (PyPDF2, pdfplumber)
- [ ] NER (Named Entity Recognition) para extrair:
  - Nome, email, telefone
  - Skills
  - Experiências
  - Educação
- [ ] Armazenar dados estruturados

### Fase 3: Modelo de Matching
- [ ] Features:
  - TF-IDF de skills do candidato vs vaga
  - Anos de experiência
  - Educação (match)
  - Localização (se relevante)
- [ ] Modelo:
  - Similarity score (cosine similarity)
  - Ou ML classifier (match/não-match)
- [ ] Endpoint: `POST /api/v1/recruitment/match`
  - Input: candidate_id, job_id
  - Output: score (0-1), explanation

### Fase 4: Explicabilidade (SHAP)
- [ ] Treinar modelo explicável (LightGBM, XGBoost)
- [ ] Calcular SHAP values:
  ```python
  import shap
  explainer = shap.TreeExplainer(model)
  shap_values = explainer.shap_values(candidate_features)
  ```
- [ ] Endpoint: `GET /api/v1/recruitment/candidates/{id}/explainability?job_id={id}`
  - Retorna: features mais importantes, SHAP values
- [ ] Visualização no frontend (waterfall plot, force plot)

### Fase 5: Análise de Diversidade
- [ ] Coletar dados de diversidade (opcional, com consentimento):
  - Gênero (self-reported)
  - Etnia (self-reported)
  - PcD (self-reported)
- [ ] Calcular métricas:
  - % de diversidade na pool
  - Comparação com benchmark de mercado
- [ ] Endpoint: `GET /api/v1/recruitment/jobs/{id}/diversity-analysis`

### Fase 6: Detecção de Viés
- [ ] Implementar fairness metrics:
  - **Disparate Impact**: ratio de aprovação entre grupos
  - **Equal Opportunity**: TPR entre grupos
- [ ] Se metric < threshold, alertar RH
- [ ] Sugestões de mitigação:
  - Re-weight features
  - Adversarial debiasing
  - Ajuste de threshold por grupo
- [ ] Endpoint: `GET /api/v1/recruitment/jobs/{id}/bias-analysis`

### Fase 7: Testes e Deploy
- [ ] Testar parsing de currículos
- [ ] Testar modelo de matching
- [ ] Testar explicabilidade
- [ ] Deploy serverless

---

## 🔌 Endpoints

- `GET /api/v1/recruitment/jobs`
- `POST /api/v1/recruitment/jobs` (RH only)
- `GET /api/v1/recruitment/jobs/{id}`
- `POST /api/v1/recruitment/applications`
- `POST /api/v1/recruitment/applications/{id}/upload-resume` (PDF)
- `GET /api/v1/recruitment/candidates?job_id={id}` (RH)
- `POST /api/v1/recruitment/match` - Score e ranking
- `GET /api/v1/recruitment/candidates/{id}/explainability?job_id={id}`
- `GET /api/v1/recruitment/jobs/{id}/diversity-analysis`
- `GET /api/v1/recruitment/jobs/{id}/bias-analysis`

---

## 📊 Database Schema

### Table: symbiowork-jobs
```
PK: job_id
Attributes:
  - title
  - description
  - required_skills (List)
  - location
  - type (remote, hybrid, onsite)
  - posted_by (user_id)
  - created_at
```

### Table: symbiowork-applications
```
PK: application_id
GSI: job_id-index, candidate_id-index
Attributes:
  - candidate_id
  - job_id
  - resume_url (S3)
  - parsed_data (Map: skills, experience)
  - match_score
  - status (applied, screening, interview, rejected, hired)
  - applied_at
```

---

## 🧪 ML Models

### Matching Model
- **Algorithm**: TF-IDF + Cosine Similarity (simples) ou LightGBM (avançado)
- **Features**: skills, experience, education
- **Output**: match score (0-1)
- **Explainability**: SHAP values

### Bias Detection
- **Metrics**: Disparate Impact, Equal Opportunity, Demographic Parity
- **Thresholds**: 
  - Disparate Impact < 0.8 → viés detectado
  - Equal Opportunity diff > 0.1 → viés detectado

---

## ✅ Critérios de Aceitação

- [ ] CRUD de vagas e candidaturas OK
- [ ] Parsing de PDF funcionando
- [ ] Modelo de matching com accuracy > 75%
- [ ] Explicabilidade (SHAP) implementada
- [ ] Análise de diversidade funcionando
- [ ] Detecção de viés com alertas
- [ ] Integração frontend completa
- [ ] Testes OK
- [ ] Deploy serverless

---

## 📚 Referências

- [SHAP Documentation](https://shap.readthedocs.io/)
- [Fairness in ML](https://fairlearn.org/)
- [Resume Parsing with NLP](https://github.com/OmkarPathak/pyresparser)
- [AI Fairness 360](https://aif360.mybluemix.net/)
