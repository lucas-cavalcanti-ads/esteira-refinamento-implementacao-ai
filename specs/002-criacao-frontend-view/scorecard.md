# Scorecard de Qualidade — Demanda `criacao-frontend-view`

- **Versão da rubrica:** 1.0.0
- **Versão da arquitetura de referência:** 1.0.0
- **SHA da constituição usada:** 57a3cd1afa1551a430521f967918cc3703028057
- **Run ID:** 78175098-88b5-438e-a42c-a319efe28aae · **Data (UTC-3):** 2026-06-22 05:24:57

---

## Âncoras de nível (valem para todas as dimensões)

| Nota | Significado |
|---|---|
| **0–2** | Ausente ou gravemente deficiente. Inviável usar como está. |
| **3–4** | Presente, mas com lacunas sérias que exigem retrabalho relevante. |
| **5–6** | Aceitável no mínimo, com pontos fracos claros. |
| **7–8** | Bom. Atende ao esperado com ressalvas menores. |
| **9–10** | Excelente. Sem ressalvas relevantes; serviria de referência. |

---

## Parte A — Nota da Especificação (spec-reviewer)

| # | Dimensão | Tipo | Sub-nota (0–10) | Justificativa (1 linha) |
|---|---|---|---|---|
| A1 | Completude dos requisitos | qualitativa | **9** | 30 FRs cobrem todas as 7 user stories; entidades-chave, edge cases e critérios de sucesso presentes; única lacuna menor é ausência de FR de observabilidade/logging. |
| A2 | Decisões em aberto (menos é melhor) | objetiva | **8** | Clarifications fecha todas as questões; correções C1/H1/H2 rastreadas; sem decisões ambíguas restantes; nº em aberto: `0` |
| A3 | Testabilidade dos critérios de aceite | qualitativa | **9** | Todos os 32 acceptance scenarios usam Given/When/Then com condições objetivas; SC-001–007 têm métricas numéricas (tempo em segundos). |
| A4 | Conformidade com a constituição | objetiva (pass/fail→nota) | **7** | Exceções §1/§2 em ADR-001; §9/§10/§12 conformes; violação parcial §5 (sem FR/SC de observabilidade na spec); violações: `§5 parcial (observabilidade — escopo local reduz impacto)` |
| A5 | Clareza / ausência de ambiguidade | qualitativa | **9** | FR-013 documenta limitação do endpoint GET /notes; FR-015 detalha edição de kind+label; FR-006 elimina autenticação; assumptions explicitam escopo local/single-user. |

**Nota final da spec:** **8.4** / 10

**Violações de conformidade (spec):** §5 parcial — spec.md não contém FR/SC de logging estruturado (plano menciona console.error, mas não há critério verificável na spec). Escopo local reduz impacto prático.

---

## Parte B — Nota da Implementação (impl-reviewer — 2026-06-23, pós-correções D1–D4)

| # | Dimensão | Tipo | Sub-nota (0–10) | Justificativa (1 linha) |
|---|---|---|---|---|
| B1 | Conformidade com a spec | objetiva (pass/fail→nota) | **8.5** | 30/30 FRs implementados após correção D1 (getErrors carrega erros existentes em unit-detail) e D2 (CI fixed); sub-nota anterior: 7 (pré-correção). |
| B2 | Conformidade com a arquitetura | objetiva (pass/fail→nota) | **8.5** | §6 CI/CD conformou após D2 (pnpm action-setup + pnpm install --frozen-lockfile); §1/§2 cobertos por ADR-001; §3 PASS; §5 leve (console.error ausente — escopo local); §7/§8/§9/§12 PASS; sub-nota anterior: 7. |
| B3 | % de testes passando | objetiva | **9** | 13/13 testes unitários passam (confirmado pelo implementer); correções D1–D4 não alteram test/unit/; e2e smoke depende de backend em execução. |
| B4 | Cobertura de testes | objetiva | **6** | Apenas api/client.ts testado unitariamente; sem cobertura de pages/; estimada <30% de src/ — dimensão informativa (peso 0). |
| B5 | Qualidade de código | qualitativa | **8.5** | TypeScript strict; escapeHtml extraído para src/utils.ts (D4); currentErrors resetado entre navegações (D3); error handling em todos os fetch points; ausência de console.error estruturado é o único ponto leve restante. |
| B6 | Completude das tarefas | objetiva | **10** | 47/47 tasks concluídas após D1 (T030 completo com pré-carregamento); todos os artefatos presentes. |

**Nota final da implementação:** **8.8** / 10

**Cálculo ponderado:** B1×0.30 + B2×0.20 + B3×0.20 + B4×0 + B5×0.15 + B6×0.15
= 8.5×0.30 + 8.5×0.20 + 9×0.20 + 8.5×0.15 + 10×0.15
= 2.55 + 1.70 + 1.80 + 1.275 + 1.50 = **8.825** → arredondado para **8.8**

**Conformidade:** spec `PASS` · arquitetura `PASS` · testes falhando `0` (esperado 0)

**Desvios — pré-correção (todos resolvidos):**
1. ~~`LEVE` — FR-009/T030: erros pré-carregados ausentes~~ → **RESOLVIDO** (D1: `getErrors(n)` chamado no mount)
2. ~~`LEVE` — §6 CI/CD: npm ci sem package-lock.json~~ → **RESOLVIDO** (D2: workflow usa pnpm action-setup)
3. ~~`LEVE` — `currentErrors` não resetado entre navegações~~ → **RESOLVIDO** (D3: `currentErrors.length = 0` no início de renderAllSections)
4. ~~`LEVE` — `escapeHtml` duplicado em 3 arquivos~~ → **RESOLVIDO** (D4: extraído para `src/utils.ts`)

---

## Resumo

| | Nota final | Gate mínimo | Passou no gate? |
|---|---|---|---|
| Especificação | **8.4** | 7.0 | Sim |
| Implementação | **8.8** | 7.0 | Sim |
