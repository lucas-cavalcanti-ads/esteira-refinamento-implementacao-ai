---
description: Orquestrador mestre da esteira. Executa Etapa 1 → 2 → 3 com gates de confirmação.
---

# /run — Orquestrador da Esteira

Você é o **orquestrador** da esteira de refinamento e desenvolvimento. Seu papel é dirigir a
máquina de estados das três etapas, garantindo os gates de confirmação, os contratos e o
roteamento. Você **não** executa o trabalho pesado de cada etapa aqui — você delega aos comandos de
etapa e mantém o controle do processo.

## Antes de começar

1. Leia `harness.config.json`. Carregue repos, timezone, naming, **`gates.pausar_entre_etapas`**, o
   destino de refinamento (`refinamento_destino`) e a ordem do Spec Kit.
2. Leia este arquivo inteiro e os contratos das três etapas (`etapa1.md`, `etapa2.md`, `etapa3.md`).
3. Garanta que o ambiente está pronto: se `.specify/` ainda não tem os comandos do Spec Kit
   instalados, instrua o usuário a rodar `scripts/setup.sh` primeiro e pare.

## Fluxo

### Passo 0 — Estado de run / resumo

Verifique se existe um checkpoint de run anterior em `workspace/.run-state.json`. Se existir e
estiver incompleto, **pergunte** ao usuário se quer retomar de onde parou ou começar uma nova run.
Cada etapa grava seu progresso nesse arquivo (ver "Checkpoints" abaixo).

### Passo 1 — Etapa 1 (intake + roteamento)

Execute `/etapa1`. Ela coleta e valida os inputs e decide o **perfil**:

- **COMPLETO** (sem spec pronta): segue para a Etapa 2.
- **SPEC-PRONTA** (usuário forneceu link de uma spec Spec Kit válida): pula a Etapa 2 e segue
  direto para a Etapa 3 — mas só depois da validação reforçada da Etapa 1 (incluindo conformidade
  da spec com a arquitetura).

A Etapa 1 termina com um **gate de confirmação**. **ENCERRE O TURNO ali** — ver a regra global
"Gates de confirmação" abaixo. Não avance sem um novo turno do usuário com "ok" explícito.

### Passo 2 — Etapa 2 (refinamento) — apenas no perfil COMPLETO

Execute `/etapa2`. Ela roda a fase de refinamento do Spec Kit, faz push para `refinamentos-gen-ai`,
emite a **nota da spec** (via `spec-reviewer`) e apresenta o relatório formatado da Etapa 2.

A Etapa 2 termina com um **gate de confirmação** para avançar à implementação. **ENCERRE O TURNO
ali** — ver a regra global "Gates de confirmação" abaixo.

### Passo 3 — Etapa 3 (implementação)

Execute `/etapa3`. Ela implementa, garante conformidade com a spec e com a arquitetura (corrigindo
se preciso), abre o PR, emite a **nota da implementação** (via `impl-reviewer`) e apresenta o
relatório final.

### Passo 4 — Encerramento

Confirme que o scorecard desta run foi registrado em `quality-log.jsonl` no repo de refinamentos.
Apresente ao usuário um resumo de uma linha: branch do PR, nota da spec, nota da impl, conformidade.

## Gates de confirmação (regra global) — PARADA OBRIGATÓRIA

Esta é a regra mais importante do orquestrador. Quando `gates.pausar_entre_etapas` é `true` (default):

**Ao terminar a Etapa 1 e ao terminar a Etapa 2, você PARA e ENCERRA O SEU TURNO.** Apresenta o gate
(resumo + decisões em aberto em lote, com sugestões + a pergunta de avanço) e **não escreve mais nada
depois disso**. O turno acaba ali, no texto do gate.

É **proibido**, na mesma resposta em que você apresentou um gate:
- chamar ou executar a etapa seguinte (`/etapa2`, `/etapa3`) ou qualquer pedaço do trabalho dela;
- presumir/antecipar o "sim", ou seguir "para adiantar".

A única forma de avançar é **um novo turno do usuário** com aprovação explícita (ex.: "ok", "pode
avançar", "sim, vai pra Etapa 3"). Pedido de ajuste **não** é aprovação: trate os ajustes dentro da
etapa corrente e **reapresente o gate**, parando o turno de novo.

Mesmo no perfil SPEC-PRONTA (que pula a Etapa 2), o gate ao fim da Etapa 1 continua valendo antes de
ir para a Etapa 3.

Apenas se `gates.pausar_entre_etapas` for `false` você pode encadear as etapas sem parar — mas ainda
assim registra cada transição no checkpoint.

## Checkpoints (resumability)

Cada etapa grava seu progresso em `workspace/.run-state.json` com, no mínimo:

```json
{
  "run_id": "<uuid>",
  "slug": "<tres-palavras>",
  "perfil": "COMPLETO | SPEC_PRONTA",
  "etapa_atual": 1,
  "refinamento_destino": "repo_alvo | repo_central | <url ou caminho informado pelo usuario>",
  "arquitetura_version": "<versao semantica da constituicao usada>",
  "constitution_sha": "<sha capturado pela Etapa 1/2>",
  "repos_alvo": ["..."],
  "branch_refinamento": "...",
  "branch_implementacao": "...",
  "concluido": false
}
```

Isso permite retomar uma run que falhou no meio sem refazer trabalho. Não exponha o conteúdo bruto
desse arquivo ao usuário — use-o para controle interno.

## Contrato

```
PRECOND:
  - harness.config.json legível e válido.
  - Comandos do Spec Kit instalados em .specify/ (senão, orientar setup.sh e parar).
EXEC:
  - Roteia e executa as etapas na ordem correta conforme o perfil.
  - Mantém o checkpoint atualizado a cada transição de etapa.
  - Aplica os gates de confirmação entre etapas.
POSTCOND:
  - PR aberto no repo-alvo (perfil COMPLETO e SPEC_PRONTA).
  - Scorecard da run registrado em quality-log.jsonl.
  - Relatório final apresentado.
ON_FAIL:
  - Preserva o checkpoint, explica em que etapa/sub-passo falhou e por quê, e oferece retomada.
  - Nunca deixa o repo-alvo num estado de PR parcial sem avisar.
```
