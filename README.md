# Esteira de Refinamento e Implementação através de IA

Harness para transformar uma demanda em código **conforme, testado, com PR aberto e nota de
qualidade** — de forma reprodutível, local (Mac) ou remota (celular), usando o Claude Code e o
[Spec Kit](https://github.com/github/spec-kit).

Este repositório **não é** um programa executável tradicional. É um conjunto de instruções
(`CLAUDE.md` + comandos + agents + skills) que o Claude Code lê e executa. Rodar uma demanda =
abrir o Claude Code aqui e disparar `/run`.

> Operação passo a passo: ver `GUIA-DE-USO.md`. Molde de prompt e como ativar: `PROMPT-DE-USO.md`.
> Exemplo pronto: `PROMPT-EXEMPLO.md`.

---

## Arquitetura em uma imagem

```
            ┌──────────────────────── ESTE HARNESS (repo) ────────────────────────┐
            │  CLAUDE.md ......... contrato do processo (o quê) — enxuto           │
            │  .claude/commands/ . run, etapa1, etapa2, etapa3                     │
            │  .claude/agents/ ... spec-reviewer, implementer, impl-reviewer       │
            │  .claude/skills/ ... "como fazer X na minha arquitetura" + speckit-* │
            │  .specify/memory/ .. constituição MATERIALIZADA em run-time          │
            │  templates/ ........ scorecard, relatórios, ADR, constituição        │
            │  scripts/ .......... bootstrap, check-prereqs, setup, fetch, metrics │
            │  workspace/ ........ efêmero: repos-alvo clonados aqui (gitignored)  │
            └─────────────────────────────────────────────────────────────────────┘
                    │ lê (run-time)            │ escreve                │ abre PR
                    ▼                          ▼                        ▼
        arquitetura-referencia        refinamentos-gen-ai          repo(s)-alvo
        (CONSTITUTION.md =             (specs + scorecard.md +       (código na branch
         a régua de conformidade,       quality-log.jsonl)           claude-{slug})
         versionada por semver)
```

Três repositórios externos, papéis distintos: a **arquitetura** é a régua (constituição, versionada),
os **refinamentos** guardam specs + notas, e os **alvos** recebem o código. Configure as URLs (e o
`local_path` da arquitetura, se quiser leitura local) em `harness.config.json`.

---

## As três etapas

1. **Etapa 1 — Intake e roteamento.** Coleta e valida os inputs. Decide o perfil:
   **COMPLETO** (sem spec → vai para a Etapa 2) ou **SPEC-PRONTA** (spec fornecida → valida reforçado,
   incluindo conformidade com a arquitetura, e pula para a Etapa 3). Termina em gate de confirmação.
2. **Etapa 2 — Refinamento (Spec Kit).** Materializa a constituição (capturando versão + SHA), roda a
   fase de refinamento na ordem canônica (`constitution → specify → clarify → checklist → plan →
   tasks → analyze`), resolve/expõe decisões em aberto, gera a **nota da spec** (revisor
   independente), faz push para `refinamentos-gen-ai` e apresenta o relatório. Gate de confirmação.
3. **Etapa 3 — Implementação.** Implementa (`implement`) usando as skills, garante **conformidade
   dupla** (spec + arquitetura) corrigindo em ciclo até zerar desvios, roda testes (zero falhas),
   gera a **nota da implementação**, abre o **PR** e apresenta o relatório final com telemetria.

Os contratos detalhados (PRECOND/EXEC/POSTCOND/ON_FAIL) estão em cada `.claude/commands/etapaN.md`.

---

## Bootstrap (uma vez) — comando único

```bash
cd esteira-refin-desenv-v1
bash scripts/bootstrap.sh
```

O `bootstrap.sh` faz tudo na ordem certa e aborta se faltar pré-requisito:

1. **`check-prereqs.sh`** — verifica `git`, `python3`, `uv`/`specify` (obrigatórios) e `gh`
   (recomendado).
2. **`chmod +x scripts/*.sh`** — permissões de execução.
3. **`setup.sh`** — instala os comandos do Spec Kit e (opcional) puxa skills compartilhadas.
4. **`fetch-constitution.sh`** — materializa a constituição e imprime `ARQUITETURA_VERSION` e
   `CONSTITUTION_SHA`.

> Use `bash scripts/bootstrap.sh` na primeira vez (os scripts ainda não têm `+x`; o bootstrap
> concede). O `harness.config.json` já vem pré-preenchido — ajuste só se quiser (abra com `nano`,
> `vim` ou `code`, não com `$EDITOR` se a variável não estiver definida).

Pré-requisitos detalhados e operação: ver `GUIA-DE-USO.md`.

---

## Rodar uma demanda

```bash
cd esteira-refin-desenv-v1
claude          # abre o Claude Code com este repo como diretório de trabalho
```

No Claude Code:

```
/run
```

…e siga os gates. Para rodar etapas isoladas (retomar/depurar): `/etapa1`, `/etapa2`, `/etapa3`.

Pelo **celular**: aponte a sessão remota do Claude Code para este repositório e rode `/run` igual.
(No celular o `local_path` da arquitetura não existe; o fetch cai automaticamente para o clone da
`url`.)

---

## A "pimenta": medir a qualidade do harness

Cada run registra **duas linhas** em `quality-log.jsonl` (no repo de refinamentos): a nota da spec
(Etapa 2) e a nota da implementação (Etapa 3). As notas são:

- **Decompostas** numa rubrica de dimensões (não uma nota solta) — `templates/scorecard.md`.
- **Ancoradas** (cada nível 0–10 tem descrição), para o avaliador não derivar entre runs.
- **Versionadas** em duas dimensões: `rubric_version` (a rubrica, que mora no harness) e
  `arquitetura_version` (a constituição, que mora no repo de arquitetura) — mais o **SHA** do commit
  da constituição. Assim você distingue "a qualidade caiu" de "a régua mudou".
- Emitidas por **revisores independentes** (quem avalia ≠ quem produz), para não inflar.

Tendência ao longo do tempo:

```bash
./scripts/scorecard-trend.sh /caminho/para/refinamentos-gen-ai/quality-log.jsonl
```

Ele mostra média por fase/versão de rubrica/versão de arquitetura, saúde de testes/conformidade e as
**sub-notas mais fracas** — que é onde você ajusta o harness.

---

## Princípios que sustentam o design

- **A constituição é a régua**, lida do repo de arquitetura (do `local_path` ou via clone —
  determinística, nunca inferida em run-time), e carimbada por **versão semântica + SHA** em cada run.
- **Nada de promoção silenciosa**: um requisito de demanda só vira princípio durável via PR ao repo
  de arquitetura, com sua confirmação. A arquitetura prevalece em conflito (hard gate). Exceções
  viram ADR.
- **Quem avalia não é quem produz.**
- **Andaime determinístico, miolo AI-driven**: o processo (branches, PRs, relatórios, gates) é
  garantido; a spec e o código são gerados com autonomia e validados pelos gates.
- **Resumability**: cada etapa grava checkpoint em `workspace/.run-state.json`.

---

## Estrutura de arquivos

```
esteira-refin-desenv-v1/
├── CLAUDE.md                      # contrato do processo (enxuto, sempre carregado)
├── README.md                      # este arquivo
├── GUIA-DE-USO.md                 # passo a passo operacional
├── PROMPT-DE-USO.md               # molde de prompt + como ativar a esteira
├── PROMPT-EXEMPLO.md              # exemplo de demanda pronto para teste
├── harness.config.json            # configuração única
├── .gitignore
├── .claude/
│   ├── settings.json
│   ├── commands/{run,etapa1,etapa2,etapa3}.md
│   ├── skills/speckit-*/          # (instalados pelo setup.sh)
│   ├── agents/{spec-reviewer,implementer,impl-reviewer}.md
│   └── skills/{README,exemplo-endpoint/SKILL}.md
├── .specify/memory/constitution.md  # materializada em run-time (placeholder versionado)
├── templates/{CONSTITUTION.template,scorecard,relatorio-etapa2,relatorio-etapa3,adr,quality-log.schema}.md
├── scripts/{bootstrap,check-prereqs,setup,fetch-constitution,metrics,scorecard-trend}.sh
└── workspace/.gitkeep             # efêmero (gitignored)
```

> Nota: o `CONSTITUTION.md` em si NÃO mora aqui — ele é a fonte da verdade no repo
> `arquitetura-referencia`. Este harness o materializa em `.specify/memory/constitution.md` a cada run.

---

## Próximos passos sugeridos

1. Rodar `bash scripts/bootstrap.sh`.
2. Trocar a `exemplo-endpoint` por skills reais da sua arquitetura.
3. Rodar uma demanda pequena ponta a ponta para calibrar a rubrica e os gates (use `PROMPT-EXEMPLO.md`).
4. (Opcional) Apontar `skills_compartilhadas.url` para um repo de skills reutilizáveis.

