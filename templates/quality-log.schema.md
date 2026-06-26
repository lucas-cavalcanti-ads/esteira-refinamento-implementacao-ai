# Schema do `quality-log.jsonl`

Arquivo **append-only** na raiz do repo `refinamentos-gen-ai`. **Uma linha JSON por evento de nota**
(uma para a spec, na Etapa 2; outra para a implementação, na Etapa 3). JSONL porque o append gera
diff de git limpo e é trivial de agregar (`scripts/scorecard-trend.sh`).

> Regra de ouro: **nunca reescreva o arquivo** — só faça append. E **sempre** inclua
> `arquitetura_version`, `constitution_sha` e `rubric_version`: são eles que permitem distinguir "a
> qualidade regrediu" de "a régua mudou".

## Campos

| Campo | Tipo | Descrição |
|---|---|---|
| `ts` | string (ISO-8601, UTC-3) | Timestamp do registro. |
| `run_id` | string | ID da run (mesmo do checkpoint). |
| `slug` | string | Resumo de três palavras da demanda. |
| `fase` | string | `"spec"` ou `"impl"`. |
| `perfil` | string | `"COMPLETO"` ou `"SPEC_PRONTA"`. |
| `nota_final` | number | Nota 0–10 da fase. |
| `subnotas` | object | Mapa dimensão→nota (ex: `{"A1":8,"A2":6,...}`). |
| `conformidade` | object | Ex: `{"spec":"PASS","arquitetura":"PASS"}` (na impl) ou `{"constituicao":"PASS"}` (na spec). |
| `testes` | object\|null | Impl: `{"passaram":N,"falharam":0,"total":N,"cobertura":NN}`. Spec: `null`. |
| `decisoes_abertas` | number | Nº de decisões em aberto ao fim da fase. |
| `arquitetura_version` | string | Versão semântica da arquitetura de referência usada (marcador do CONSTITUTION.md). |
| `constitution_sha` | string | SHA do commit da constituição usada nesta run. |
| `rubric_version` | string | Versão da rubrica aplicada. |
| `branch_refinamento` | string\|null | Branch no repo de refinamentos. |
| `branch_implementacao` | string\|null | Branch no repo-alvo (na fase impl). |
| `pr_url` | string\|null | URL do PR (na fase impl). |

## Exemplo (duas linhas de uma mesma run)

```jsonl
{"ts":"2026-06-17T20:50:23-03:00","run_id":"a1b2","slug":"criacao-endpoint-usuarios","fase":"spec","perfil":"COMPLETO","nota_final":8.2,"subnotas":{"A1":9,"A2":7,"A3":8,"A4":10,"A5":7},"conformidade":{"constituicao":"PASS"},"testes":null,"decisoes_abertas":1,"arquitetura_version":"1.0.0","constitution_sha":"9f3c1d4","rubric_version":"1.0.0","branch_refinamento":"claude-criacao-endpoint-usuarios-20260617-205023","branch_implementacao":null,"pr_url":null}
{"ts":"2026-06-17T21:40:10-03:00","run_id":"a1b2","slug":"criacao-endpoint-usuarios","fase":"impl","perfil":"COMPLETO","nota_final":7.6,"subnotas":{"B1":8,"B2":9,"B3":10,"B4":6,"B5":7,"B6":8},"conformidade":{"spec":"PASS","arquitetura":"PASS"},"testes":{"passaram":42,"falharam":0,"total":42,"cobertura":81},"decisoes_abertas":0,"arquitetura_version":"1.0.0","constitution_sha":"9f3c1d4","rubric_version":"1.0.0","branch_refinamento":"claude-criacao-endpoint-usuarios-20260617-205023","branch_implementacao":"claude-criacao-endpoint-usuarios","pr_url":"https://github.com/.../pull/123"}
```
