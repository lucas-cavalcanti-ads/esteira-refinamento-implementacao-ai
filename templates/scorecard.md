# Scorecard de Qualidade — Demanda `{slug}`

> Rubrica **ancorada** e **versionada**. As âncoras (o que significa cada nível) impedem que o
> avaliador derive entre runs. A versão da rubrica e a versão da arquitetura são gravadas junto de
> cada nota — se qualquer uma mudar, notas antigas deixam de ser comparáveis com as novas, e isso
> fica explícito.

- **Versão da rubrica:** 1.0.0 _(deve bater com `scorecard.rubric_version` em harness.config.json)_
- **Versão da arquitetura de referência:** `{arquitetura_version}` _(do marcador no CONSTITUTION.md)_
- **SHA da constituição usada:** `{constitution_sha}`
- **Run ID:** `{run_id}` · **Data (UTC-3):** `{aaaa-mm-dd hh:mm:ss}`

---

## Âncoras de nível (valem para todas as dimensões)

| Nota | Significado |
|---|---|
| **0–2** | Ausente ou gravemente deficiente. Inviável usar como está. |
| **3–4** | Presente, mas com lacunas sérias que exigem retrabalho relevante. |
| **5–6** | Aceitável no mínimo, com pontos fracos claros. |
| **7–8** | Bom. Atende ao esperado com ressalvas menores. |
| **9–10** | Excelente. Sem ressalvas relevantes; serviria de referência. |

> Regra do avaliador: na dúvida entre dois níveis, fique no **menor** e justifique. Nota alta exige
> evidência. Conformidade é hard gate — uma violação não é compensada por outras notas altas.

---

## Parte A — Nota da Especificação (preenchida pelo `spec-reviewer`)

| # | Dimensão | Tipo | Sub-nota (0–10) | Justificativa (1 linha) |
|---|---|---|---|---|
| A1 | Completude dos requisitos | qualitativa | | |
| A2 | Decisões em aberto (menos é melhor) | objetiva | | nº em aberto: `{n}` |
| A3 | Testabilidade dos critérios de aceite | qualitativa | | |
| A4 | Conformidade com a constituição | objetiva (pass/fail→nota) | | violações: `{lista}` |
| A5 | Clareza / ausência de ambiguidade | qualitativa | | |

**Nota final da spec:** `{média das sub-notas, ponderada se configurado}` / 10

**Violações de conformidade (spec):** `{nenhuma | lista citando regra e local}`

---

## Parte B — Nota da Implementação (preenchida pelo `impl-reviewer`)

| # | Dimensão | Tipo | Sub-nota (0–10) | Justificativa (1 linha) |
|---|---|---|---|---|
| B1 | Conformidade com a spec | objetiva (pass/fail→nota) | | |
| B2 | Conformidade com a arquitetura | objetiva (pass/fail→nota) | | violações: `{lista}` |
| B3 | % de testes passando | objetiva | | `{passaram}/{total}` |
| B4 | Cobertura de testes | objetiva | | `{cobertura}%` (se mensurável) |
| B5 | Qualidade de código | qualitativa | | |
| B6 | Completude das tarefas | objetiva | | `{tasks_fechadas}/{tasks_total}` |

**Nota final da implementação:** `{média das sub-notas, ponderada se configurado}` / 10

**Conformidade:** spec `{PASS/FAIL}` · arquitetura `{PASS/FAIL}` · testes falhando `{n}` (esperado 0)

---

## Resumo

| | Nota final | Gate mínimo | Passou no gate? |
|---|---|---|---|
| Especificação | `{nota}` | `{nota_minima_spec}` | `{sim/não}` |
| Implementação | `{nota}` | `{nota_minima_impl}` | `{sim/não}` |

> Cada run também registra uma linha em `quality-log.jsonl` (no repo de refinamentos), com estas
> notas + `arquitetura_version` + `constitution_sha` + `rubric_version`, para gerar a tendência de
> qualidade do harness ao longo do tempo (`scripts/scorecard-trend.sh`).

## Como evoluir a rubrica (sem quebrar comparabilidade)

1. Edite as dimensões/âncoras aqui e **suba a versão** (`rubric_version` na config + este arquivo).
2. A partir do bump, novas notas usam a versão nova; notas antigas continuam marcadas com a antiga.
3. No `scorecard-trend.sh`, compare apenas dentro da mesma `rubric_version` (ou trate o bump como
   quebra de série). O mesmo raciocínio vale para `arquitetura_version`.
