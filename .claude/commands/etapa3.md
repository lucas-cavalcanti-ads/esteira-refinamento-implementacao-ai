---
description: Etapa 3 — implementação via Spec Kit, conformidade, PR e nota da implementação.
---

# /etapa3 — Implementação

A Etapa 3 parte da especificação (gerada na Etapa 2 ou fornecida no perfil SPEC-PRONTA) e produz a
implementação conforme, testada, com PR aberto e nota de qualidade.

## Passo A — Preparar

1. Garanta que a constituição está materializada (`.specify/memory/constitution.md`) e que
   `arquitetura_version` e `constitution_sha` estão no checkpoint. Se veio do perfil SPEC-PRONTA, a
   Etapa 1 já materializou.
2. No repo-alvo (em `workspace/`), crie/confirme a branch de implementação: `claude-{slug}`.
3. Inicie o cronômetro da implementação (registre o timestamp de início — `scripts/metrics.sh now`).

## Passo B — Implementar (agent isolado)

Delegue ao agent **`implementer`** (contexto limpo, dedicado à implementação) a execução de:

- `/speckit-implement` — percorre as tarefas e escreve o código conforme spec/plan/tasks.

O `implementer` usa as **skills** do acervo (`.claude/skills/`) — "como fazer X na minha
arquitetura" — para implementar de forma AI-driven **e** consistente. Implementação faseada se o
escopo for grande, para não estourar o contexto.

## Passo C — Conformidade (hard gate, revisor independente)

Invoque o agent **`impl-reviewer`** (não foi quem implementou). Ele garante **duas** conformidades:

1. **Conformidade com a especificação** gerada.
2. **Conformidade com a arquitetura de referência** (a constituição materializada).

Lembre que `analyze` é read-only: ele aponta desvios, não corrige. Então o ciclo é:

```
verificar (impl-reviewer / analyze) → houve desvio? → corrigir (implementer) → re-verificar
```

**Enquanto houver desvio, corrija imediatamente e repita.** Só prossiga quando ambas as
conformidades estiverem satisfeitas. Rode também a suíte de testes; espera-se zero falhas.

Opcional: um `/speckit-checklist` final como portão de aceitação (distinto do checklist de
requisitos da Etapa 2, que valida requisitos antes do plano).

## Passo D — Nota da implementação

Ainda no `impl-reviewer`, preencha a rubrica de implementação de `templates/scorecard.md`:
- Conformidade com a spec, conformidade com a arquitetura (objetivas, pass/fail → nota).
- % de testes passando, cobertura (objetivas, da telemetria).
- Qualidade de código, completude das tarefas.
- **Nota final da implementação (0–10).**

Atualize o `scorecard.md` da demanda e faça **append** da linha de implementação no
`quality-log.jsonl` (com **`arquitetura_version`, `constitution_sha` e `rubric_version`**).

## Passo E — Abrir o PR

Com a implementação conforme, abra um **PR da branch `claude-{slug}` para a `main`** do repo-alvo.
Título e descrição devem referenciar a demanda e linkar a spec no repo de refinamentos.

## Passo F — Telemetria + Relatório final (mensagem única)

Use `scripts/metrics.sh` para capturar as métricas e preencha `templates/relatorio-etapa3.md`:

- Tempo de execução da implementação.
- Arquivos alterados / criados / excluídos.
- Testes alterados / criados / excluídos.
- Testes que passaram com sucesso.
- Testes que falharam (esperado: zero).
- Se a implementação está em total conformidade (esperado: sim).
- **Nota da implementação** + link para o scorecard.
- Link do PR aberto.

Se a nota ficou **abaixo de `scorecard.nota_minima_impl`** ou houver qualquer teste falhando ou
não-conformidade, **não** apresente como sucesso silencioso: sinalize e leve ao usuário.

## Passo G — Encerrar a run

Marque o checkpoint como `concluido: true`. Confirme que ambas as linhas (spec e impl) estão no
`quality-log.jsonl`. O `workspace/` pode ser descartado.

## Contrato

```
PRECOND:
  - Constituição materializada (+versão +SHA); spec disponível (Etapa 2 ou SPEC-PRONTA);
    branch claude-{slug}.
EXEC:
  - implementer roda /speckit-implement usando skills. impl-reviewer garante conformidade dupla,
    corrige em ciclo até zerar desvios, roda testes. Emite nota. Abre PR. Captura telemetria.
POSTCOND:
  - Conformidade com spec E arquitetura satisfeitas; testes sem falha; PR aberto p/ main;
    nota da impl registrada (quality-log.jsonl com arquitetura_version + constitution_sha +
    rubric_version); relatório final apresentado; checkpoint concluído.
ON_FAIL:
  - Desvio que não fecha após N ciclos de correção: pare, reporte o desvio específico ao usuário.
  - Teste falhando que não estabiliza: não abra PR como "conforme"; leve ao usuário.
  - PR falha (auth/rede): reporte e oriente; não marque a run como concluída.
```
