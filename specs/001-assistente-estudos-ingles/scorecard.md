# Scorecard de Qualidade — Demanda `assistente-estudos-ingles`

> Rubrica ancorada e versionada. A versão da rubrica e a versão da arquitetura são gravadas junto de
> cada nota.

- **Versão da rubrica:** 1.0.0
- **Versão da arquitetura de referência:** `1.0.0`
- **SHA da constituição usada:** `57a3cd1afa1551a430521f967918cc3703028057`
- **Run ID:** `0C7ED1DD-841A-4047-8D56-E02D2A99AE8C` · **Data (UTC-3):** `2026-06-20`

---

## Âncoras de nível (valem para todas as dimensões)

| Nota | Significado |
|---|---|
| **0–2** | Ausente ou gravemente deficiente. Inviável usar como está. |
| **3–4** | Presente, mas com lacunas sérias que exigem retrabalho relevante. |
| **5–6** | Aceitável no mínimo, com pontos fracos claros. |
| **7–8** | Bom. Atende ao esperado com ressalvas menores. |
| **9–10** | Excelente. Sem ressalvas relevantes; serviria de referência. |

> Regra do avaliador: na dúvida entre dois níveis, fique no menor e justifique. Conformidade é hard
> gate — uma violação não é compensada por outras notas altas.

---

## Parte A — Nota da Especificação (preenchida pelo `spec-reviewer`, contexto limpo)

| # | Dimensão | Tipo | Sub-nota (0–10) | Justificativa (1 linha) |
|---|---|---|---|---|
| A1 | Completude dos requisitos | qualitativa | 9 | FR-001..FR-021 cobrem cadastro, persistência, geração, progresso, busca, local-first e o comando único; sem lacuna detectável. |
| A2 | Decisões em aberto (menos é melhor) | objetiva | 8 | Apenas 2 em aberto, não-bloqueantes (UI web vs. Swagger UI; LLM local Ollama); D1–D4 resolvidas na Etapa 1. |
| A3 | Testabilidade dos critérios de aceite | qualitativa | 8 | Given/When/Then + SC com limiares objetivos; SC-004/SC-005 reescritos para verificação determinística após revisão. |
| A4 | Conformidade com a constituição | objetiva | 9 | Constitution Check (13 regras) sem violação; tensões §4/§7 resolvidas a favor da constituição com ADR-001/002. |
| A5 | Clareza / ausência de ambiguidade | qualitativa | 8 | Layout de arquivos, entidades e OpenAPI concretos; fronteira manual×automático em FR-005/FR-014 delimitada após revisão. |

**Nota final da spec:** **8.4 / 10**

**Violações de conformidade (spec):** nenhuma.

> Nota: A3 e A5 já incorporam as melhorias recomendadas pelo revisor (SC-004/SC-005 determinísticos;
> FR-005/FR-014 com fronteira manual×automático explícita). A nota registrada reflete a avaliação
> independente sobre a spec entregue.

---

## Parte B — Nota da Implementação (preenchida pelo `impl-reviewer`, contexto limpo)

| # | Dimensão | Tipo | Sub-nota (0–10) | Justificativa (1 linha) |
|---|---|---|---|---|
| B1 | Conformidade com a spec | objetiva | 9 | Todos os SC verificados deterministicamente em integração real (LocalStack); sem desvios. |
| B2 | Conformidade com a arquitetura | objetiva | 8 | Clean Arch/§2/§4/§11 OK; §3-linha na régua (95.4%), §3-branch via exceção ADR-003 legítima. |
| B3 | % de testes passando | objetiva | 10 | 148/148 verdes (unit + contrato + integração real), zero falhas. |
| B4 | Cobertura de testes | objetiva | 7 | Linha 95.4% cumpre §3; branch 83.6% só atende via exceção por-demanda (dívida T036). |
| B5 | Qualidade de código | qualitativa | 8 | Use cases ~100% linha, erros de domínio de 1ª classe, excludes mínimos, logs estruturados. |
| B6 | Completude das tarefas | objetiva | 9 | T001–T039 entregues; T036 (branch 95% pleno) diferido conscientemente via ADR-003. |

**Nota final da implementação:** **8.5 / 10**

**Conformidade:** spec `PASS` · arquitetura `PASS` (§3-branch sob exceção ADR-003) · testes falhando `0` (esperado 0)

**Build:** `mvn clean verify` = BUILD SUCCESS (gate JaCoCo ATIVO: módulo LINHA ≥95% / BRANCH ≥80%).

---

## Resumo

| | Nota final | Gate mínimo | Passou no gate? |
|---|---|---|---|
| Especificação | 8.4 | 7.0 | sim |
| Implementação | 8.5 | 7.0 | sim |
