---
description: Etapa 2 — refinamento via Spec Kit, push p/ refinamentos-gen-ai e nota da spec.
---

# /etapa2 — Refinamento (Spec Kit)

A Etapa 2 recebe os inputs já validados pela Etapa 1 e produz a especificação completa, baseada
100% no Spec Kit. Roda **apenas no perfil COMPLETO**.

## Passo A — Materializar a constituição

Rode `scripts/fetch-constitution.sh`. Ele:
- Lê `CONSTITUTION.md` do repo `arquitetura-referencia` — do `local_path` se configurado/existente,
  senão clonando a `url` (config).
- Materializa em `.specify/memory/constitution.md`.
- Captura a **versão semântica** (`arquitetura_version`, do marcador `<!-- arquitetura_version: -->`)
  e o **SHA do commit** (`constitution_sha`). Grave ambos no checkpoint.

Se o repo de arquitetura **não tem** `CONSTITUTION.md` ainda, **pare** e oriente o usuário a criar a
v1 a partir de `templates/CONSTITUTION.template.md` (bootstrap). A constituição é explícita e
escrita à mão; não a infira de código. Sem ela, as notas de conformidade medem contra fumaça.

## Passo B — Executar a fase de refinamento do Spec Kit

Na ordem canônica (de `harness.config.json` → `speckit.fase_refinamento`), execute contra o
repo-alvo em `workspace/`:

1. `/speckit-constitution` — **aplica a constituição canônica** já materializada (não entrevista o
   usuário do zero). No máximo acrescenta um adendo específico da demanda, se a Etapa 1 aprovou um.
2. `/speckit-specify` — o "o quê" e o "porquê" (sem detalhe técnico).
3. `/speckit-clarify` — reduz ambiguidade. Agrupe perguntas em lote (UX de celular).
4. `/speckit-checklist` — portão de qualidade dos requisitos, **antes do plan**.
5. `/speckit-plan` — arquitetura e stack (o "como"), respeitando a constituição.
6. `/speckit-tasks` — quebra o plano em tarefas testáveis e ordenadas.
7. `/speckit-analyze` — consistência entre spec/plan/tasks. **É read-only**: ele aponta, não
   corrige. Se houver inconsistências, aplique as correções e rode `analyze` de novo até limpar.

## Passo C — Decisões em aberto

Se sobraram decisões em aberto ao fim do refinamento, **apresente-as ao usuário em uma mensagem,
em lote, com sugestões** antes de finalizar a etapa. O usuário decide a abordagem de cada uma ou
opta por seguir assumindo-as. Registre decisões relevantes como ADR (`templates/adr.md`).

## Passo D — Nota da spec (revisor independente)

Invoque o agent **`spec-reviewer`** (contexto limpo, não foi quem escreveu a spec). Ele:
- Checa conformidade da spec com a constituição materializada.
- Preenche a rubrica de `templates/scorecard.md` (versão de `scorecard.rubric_version`).
- Produz as sub-notas e a **nota final da spec (0–10)**.

Gere o `scorecard.md` legível desta demanda e registre a linha no `quality-log.jsonl` (ver Passo E).

## Passo E — Gravar o refinamento (destino resolvido) + append no quality-log

O **destino** dos artefatos foi resolvido na Etapa 1 e está no checkpoint (`refinamento_destino`).
Grave conforme o destino; o **quality-log é sempre centralizado**, em separado.

**E.1 — Artefatos do refinamento (vai pro destino resolvido):**

Estrutura a gravar (mesma em qualquer destino):
```
<base-do-destino>/
  spec.md, plan.md, tasks.md, ... (artefatos do Spec Kit)
  scorecard.md                     (rubrica legível desta run)
  decisoes/ADR-*.md                (ADRs desta run, se houver)
```

- Se `refinamento_destino` = **`repo_alvo`** (ou um caminho dentro do repo-alvo): grave em
  `refinamento_destino.pasta_oculta_no_repo_alvo` (ex: `.refinamentos/{slug}/`) **na branch de
  implementação `claude-{slug}`** do repo-alvo, em `workspace/`. Não crie branch nova: é a mesma que
  a Etapa 3 usa, para a spec entrar no mesmo PR. Commit + push dessa branch.
- Se `refinamento_destino` = **`repo_central`** (ou uma URL de outro repo de refinamento): crie a
  branch `claude-{slug}-{aaaammdd}-{hhmmss}` (UTC-3; use `scripts/metrics.sh now`) nesse repo, grave
  `<slug>/` na raiz, commit + push.

**E.2 — quality-log.jsonl (SEMPRE centralizado, independe do destino):**

- Faça **APPEND de 1 linha** (não reescreva o arquivo) no `quality-log.jsonl` do repo CENTRAL
  `refinamentos-gen-ai` (`repos.refinamentos`). Schema em `templates/quality-log.schema.md`.
- A linha registra a nota da spec e **aponta para onde os artefatos foram gravados** (destino +
  caminho/branch), além de incluir **`arquitetura_version`, `constitution_sha` e `rubric_version`**
  — é o que garante comparabilidade entre runs (versão = qual régua; SHA = quais bytes; rubric =
  qual rubrica). Commit + push do log no repo central.

## Passo F — Relatório da Etapa 2 (mensagem única e formatada)

Preencha `templates/relatorio-etapa2.md`:
- Nome **com link** da branch gerada no repo de refinamentos.
- Artefatos criados.
- Se a Etapa 2 está totalmente concluída.
- Quantas decisões ficaram em aberto (e quais).
- **Nota da spec** + link para o scorecard detalhado.
- Pergunta de confirmação para avançar à Etapa 3.

Se a nota da spec ficou **abaixo de `scorecard.nota_minima_spec`**, sinalize isso explicitamente e
peça confirmação consciente antes de avançar (não bloqueia, mas não passa em silêncio).

**Após apresentar o relatório/gate, ENCERRE O TURNO** (ver a regra global de gates em `run.md`): não
chame a Etapa 3 nem antecipe trabalho dela na mesma resposta. Só avance num novo turno do usuário com
aprovação explícita.

## Contrato

```
PRECOND:
  - Perfil COMPLETO; inputs validados pela Etapa 1; repo-alvo clonado em workspace/.
  - CONSTITUTION.md existe no repo de arquitetura (senão, bootstrap e parar).
EXEC:
  - Materializa constituição (+versão +SHA). Roda fase_refinamento do Spec Kit na ordem canônica.
  - Resolve/expõe decisões em aberto. spec-reviewer emite a nota. Push p/ refinamentos. Relatório.
POSTCOND:
  - Artefatos do Spec Kit gerados e consistentes (analyze limpo).
  - Refinamento gravado no destino resolvido (pasta oculta na branch claude-{slug} do repo-alvo, OU
    branch própria no repo central) com push; scorecard.md commitado; quality-log.jsonl com append
    NO REPO CENTRAL contendo destino dos artefatos + arquitetura_version + constitution_sha +
    rubric_version.
  - Relatório apresentado; gate de confirmação para Etapa 3.
ON_FAIL:
  - analyze nunca limpa após N correções: pare e leve ao usuário com o diagnóstico.
  - Push falha (auth/rede): reporte e oriente; não declare a etapa concluída.
```
