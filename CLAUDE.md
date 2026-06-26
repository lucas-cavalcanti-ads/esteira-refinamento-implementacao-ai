# Esteira de Refinamento e Desenvolvimento — Harness V1

Este repositório é um **harness**: um conjunto de instruções, comandos, agents e skills que o
Claude Code lê e executa para transformar uma demanda em código implementado, conforme, testado
e com nota de qualidade — de forma reprodutível, local ou remota (celular).

Este arquivo descreve **o quê** o sistema faz e onde está cada coisa. O **como** detalhado mora
nos comandos (`.claude/commands/`). Mantenha este arquivo enxuto: ele é carregado em todo contexto.

---

## Como rodar

Abra o Claude Code com **este repositório** como diretório de trabalho e dispare:

- `/run` — orquestra o fluxo inteiro (Etapa 1 → 2 → 3) com gates de confirmação entre etapas.
- `/etapa1`, `/etapa2`, `/etapa3` — executam etapas isoladas (útil para retomar ou depurar).

Os repositórios-alvo **não vivem aqui**. São clonados em `workspace/` (efêmero, gitignorado) no
início de cada run. O estado durável fica nos repos certos: código no repo-alvo; **o refinamento vai
pro destino resolvido na Etapa 1** (default: pasta oculta no próprio repo-alvo; ou o repo central
`refinamentos-gen-ai`); e o `quality-log.jsonl` fica **sempre** em `refinamentos-gen-ai`.
`workspace/` pode ser descartado a qualquer momento.

---

## Princípios invioláveis do processo

1. **A constituição é a régua.** Toda conformidade (e quase toda nota) é medida contra a
   constituição materializada de `arquitetura-referencia`. Ela é buscada do repo, nunca inferida de
   código em run-time. Cada run carimba a **versão semântica** (`arquitetura_version`, do marcador no
   topo do `CONSTITUTION.md`) **e** o **SHA do commit** — versão = qual conjunto de regras; SHA =
   exatamente quais bytes.
2. **Nada de promoção silenciosa.** Um requisito de demanda só vira princípio constitucional com
   confirmação explícita e via PR ao repo de arquitetura. A arquitetura de referência prevalece em
   conflito.
3. **Quem avalia não é quem produz.** Notas de qualidade e checagens de conformidade saem de agents
   revisores independentes (`spec-reviewer`, `impl-reviewer`), com contexto limpo.
4. **Gates de confirmação entre etapas.** Com `gates.pausar_entre_etapas` ligado (default), o sistema
   **para e encerra o turno** ao fim da Etapa 1 e da Etapa 2; só avança num **novo turno** do usuário
   com aprovação explícita — nunca encadeia etapas na mesma resposta. Decisões em aberto vêm em lote,
   com sugestões.
5. **Contratos explícitos.** Toda etapa segue PRECOND → EXEC → POSTCOND → ON_FAIL. Se um POSTCOND
   falha, dispara o ON_FAIL — não se prossegue na marra.
6. **Determinismo onde importa.** O andaime (branches, PRs, relatórios, gates de conformidade) é
   determinístico. O miolo (escrever spec, escrever código) é AI-driven, validado pelos gates.

---

## Máquina de estados (visão alta)

```
                    ┌─────────── perfil COMPLETO (sem spec) ───────────┐
   INPUTS ──▶ ETAPA 1 (intake + roteamento)                            │
                    └─────────── perfil SPEC-PRONTA (pula p/ Etapa 3) ──┘
                          │                                    │
                          ▼ (confirmação)                      │
                       ETAPA 2 ───────────────────────────────┘
              (Spec Kit: constitution → specify → clarify →
               checklist → plan → tasks → analyze)
              push p/ refinamentos-gen-ai + NOTA da spec
                          │
                          ▼ (confirmação)
                       ETAPA 3
              (implement → conformidade c/ spec + arquitetura →
               correção se preciso → PR → NOTA da impl)
                          │
                          ▼
                       RELATÓRIO FINAL + scorecard registrado
```

Detalhes de cada etapa: `.claude/commands/etapa1.md`, `etapa2.md`, `etapa3.md`.

---

## Convenção de branches

Lida de `harness.config.json` (`branch_naming`). Resumindo:

- **Refinamento**: por padrão vai numa **pasta oculta no próprio repo-alvo** (`.refinamentos/{slug}`),
  na mesma branch `claude-{slug}` — destino configurável via `refinamento_destino`. No modo
  `repo_central` (repo `refinamentos-gen-ai`): branch `claude-{slug}-{aaaammdd}-{hhmmss}` (UTC-3).
- **Implementação** (repo-alvo): `claude-{slug}`.
- `{slug}` = resumo da implementação em três palavras com hífen (ex: `criacao-endpoint-usuarios`).

---

## Índice de artefatos

| Caminho | Papel |
|---|---|
| `harness.config.json` | Configuração única (repos, timezone, naming, gates, destino de refinamento). |
| `.claude/commands/run.md` | Orquestrador mestre das 3 etapas. |
| `.claude/commands/etapa1.md` | Intake + roteamento (2 perfis de validação). |
| `.claude/commands/etapa2.md` | Refinamento Spec Kit + push + nota da spec. |
| `.claude/commands/etapa3.md` | Implementação + conformidade + PR + nota da impl. |
| `.claude/skills/speckit-*/` | Skills do Spec Kit, invocadas como `/speckit-<fase>` (instaladas pelo `setup.sh`). |
| `.claude/agents/spec-reviewer.md` | Revisor independente da spec (conformidade + nota). |
| `.claude/agents/implementer.md` | Implementador isolado (contexto limpo). |
| `.claude/agents/impl-reviewer.md` | Revisor independente da implementação (conformidade + nota). |
| `.claude/skills/` | Acervo "como fazer X na minha arquitetura". |
| `.specify/memory/constitution.md` | Constituição **materializada em run-time** (não editar à mão). |
| `templates/CONSTITUTION.template.md` | Modelo para criar a constituição canônica no repo de arquitetura. |
| `templates/scorecard.md` | Rubrica de qualidade ancorada e versionada (0–10). |
| `templates/relatorio-etapa2.md`, `relatorio-etapa3.md` | Modelos dos relatórios formatados. |
| `templates/adr.md` | Modelo de registro de decisão (ADR). |
| `scripts/setup.sh` | Instala Spec Kit, puxa skills compartilhadas. |
| `scripts/fetch-constitution.sh` | Busca/materializa a constituição + captura versão e SHA. |
| `scripts/metrics.sh` | Telemetria (diff, testes, tempo). |
| `scripts/scorecard-trend.sh` | Agrega o log de notas e mostra tendência. |

Comece por `README.md` para a visão completa e o passo a passo de bootstrap.

<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan
at `specs/002-criacao-frontend-view/plan.md`
<!-- SPECKIT END -->
