---
description: Etapa 1 — intake, validação e roteamento da demanda (perfil COMPLETO ou SPEC-PRONTA).
---

# /etapa1 — Intake e Roteamento

A Etapa 1 é um **roteador com dois perfis de validação**. Ela coleta os inputs, decide o caminho e
só libera o avanço quando as informações atingem um nível aceitável.

## Inputs esperados

Peça (ou aceite, se o usuário já colou) os seguintes inputs. Itens **obrigatórios** marcados com *.

- Contexto da demanda *
- Requisitos *
- Critérios de aceite *
- Repositório(s)-alvo onde a implementação acontece *
- Destino do refinamento (opcional; onde gravar spec/plan/tasks/scorecard/ADR). Se omitido, usa
  `refinamento_destino.default` da config — default: pasta oculta no próprio repo-alvo de código.
- Branch base para refinamento (opcional; default: `main`)
- Branch de implementação (opcional; default: criada na Etapa 3 a partir da `main`)
- **OU** link de uma spec pronta no formato Spec Kit (dispara o perfil SPEC-PRONTA)

## Roteamento

- Se o usuário forneceu **link de spec Spec Kit** → **perfil SPEC-PRONTA** (validação reforçada,
  pula a Etapa 2).
- Caso contrário → **perfil COMPLETO** (validação de demanda + refinamento na Etapa 2).

---

## Perfil COMPLETO — validação de demanda

Objetivo: garantir que a demanda está clara o suficiente para refinar com qualidade.

1. **Obrigatórios presentes.** Contexto, requisitos, critérios de aceite e repo(s)-alvo existem.
2. **Repos acessíveis.** Os repos-alvo existem e você consegue cloná-los (auth via PAT/keychain).
   Clone-os em `workspace/`.
3. **Branches válidas.** Se branch base/implementação foram informadas, confirme que existem (base)
   ou que o nome é válido (implementação). Senão, aplique os defaults.
4. **Qualidade da demanda.** Avalie se contexto + requisitos + critérios de aceite estão em nível
   aceitável (testáveis, sem ambiguidade grave, escopo claro).
   - Se **já estão aceitáveis**: vá direto ao gate de confirmação.
   - Se **não**: faça uma rodada de exploração/refinamento com o usuário (perguntas em lote, com
     sugestões) até atingir o nível aceitável.
5. Defina o `{slug}` (resumo em três palavras) a partir do contexto.

---

## Perfil SPEC-PRONTA — validação reforçada

Objetivo: garantir que a spec externa é válida, completa **e conforme à arquitetura** antes de
comprometer com implementação. Pular a Etapa 2 não significa pular a validação.

1. **Acessível.** O link da spec é alcançável e você consegue ler os artefatos.
2. **Formato Spec Kit.** A estrutura está no formato esperado (presença de `spec.md`, `plan.md`,
   `tasks.md` e demais artefatos das fases de refinamento).
3. **Completa.** Não há decisões em aberto pendentes. Se houver, **liste-as** e trate como na
   Etapa 2 (apresentar em lote com sugestões; o usuário decide resolver agora ou seguir assumindo).
4. **Repos e branches.** Repos-alvo acessíveis e clonados; branches válidas/defaults aplicados.
5. **Conformidade com a arquitetura (hard gate).** Materialize a constituição
   (`scripts/fetch-constitution.sh`, que também captura `arquitetura_version` e `constitution_sha`) e
   rode uma checagem leve de conformidade da spec contra ela (pode delegar ao agent `spec-reviewer`
   em modo "somente conformidade"). "Qualidade da spec" aqui **inclui conformidade arquitetural**,
   não só validade de formato.
   - Se a spec **contradiz** a constituição: exponha o conflito. A arquitetura de referência
     prevalece. O usuário decide: ajustar a spec, abrir exceção explícita só para esta demanda
     (registrar ADR), ou revisar a constituição (PR ao repo de arquitetura).
6. Defina o `{slug}` a partir do conteúdo da spec.

---

## Material constitucional nos requisitos (ambos os perfis)

Ao ler os requisitos, fique atento a itens que **não são feature desta demanda**, mas princípios
arquiteturais reutilizáveis (ex: "toda chamada externa deve ter timeout"). Se detectar um:

- **Nunca promova em silêncio.** Pergunte ao usuário, no ponto de decisões em aberto:
  > "Isto parece um princípio reutilizável, não só desta demanda. Aplicar só aqui (adendo de
  > demanda), ou promover à constituição (PR ao repo de arquitetura)?"
- Três escopos possíveis: **feature** (vai pra spec), **princípio de demanda** (adendo local válido
  só nesta run), **princípio promovido** (PR ao `arquitetura-referencia`).
- **Guard de conflito (hard gate):** antes de aplicar/promover, confira contra a constituição. Se
  contradiz, a arquitetura prevalece e o conflito vai para decisão do usuário. Registre toda
  exceção/adendo concedido como ADR (`templates/adr.md`).

---

## Destino do refinamento (ambos os perfis)

Resolva **onde** os artefatos de refinamento serão gravados, nesta ordem:

1. **Usuário informou um destino** (um repo/URL ou caminho) → vale o informado. Registre o valor
   literal no checkpoint.
2. **Não informou** → use `refinamento_destino.default` da config:
   - `repo_alvo` (default de fábrica): os artefatos vão numa pasta oculta dentro do próprio repo-alvo
     de código (`refinamento_destino.pasta_oculta_no_repo_alvo`, ex: `.refinamentos/{slug}`), na mesma
     branch `claude-{slug}` que a Etapa 3 usa — a spec viaja junto do código e entra no mesmo PR.
   - `repo_central`: empurra para `refinamentos-gen-ai` em branch própria (comportamento anterior).

Independentemente do destino, o **`quality-log.jsonl` é sempre centralizado** em `refinamentos-gen-ai`
(ver `repos.refinamentos`). Não mova o log junto dos artefatos.

Resolva o destino agora e grave-o no checkpoint (`refinamento_destino`) — a Etapa 2 vai consumi-lo.

---

## Gate de confirmação

Apresente um resumo:
- Perfil escolhido (COMPLETO / SPEC-PRONTA) e por quê.
- Inputs validados e `{slug}` definido.
- Repos-alvo, branch base, branch de implementação.
- **Destino do refinamento resolvido** (repo_alvo + pasta oculta, repo_central, ou o que o usuário
  informou).
- Decisões em aberto pendentes (se houver) e adendos/exceções constitucionais propostos.
- Pergunta clara: "Posso avançar para a Etapa {2 ou 3}?"

Grave o checkpoint em `workspace/.run-state.json` (perfil, slug, repos, branches,
`refinamento_destino`, `arquitetura_version`, `constitution_sha`).

**Após apresentar este gate, ENCERRE O TURNO** (ver a regra global de gates em `run.md`): não chame
a próxima etapa nem antecipe trabalho dela na mesma resposta. Só avance num novo turno do usuário
com aprovação explícita.

## Contrato

```
PRECOND:
  - Inputs obrigatórios coletados (ou link de spec, no perfil SPEC-PRONTA).
EXEC:
  - Valida conforme o perfil; clona repos-alvo em workspace/; materializa a constituição quando
    necessário; refina a demanda até nível aceitável (COMPLETO) ou valida a spec (SPEC-PRONTA).
POSTCOND:
  - Perfil decidido; slug definido; repos acessíveis; (SPEC-PRONTA) spec conforme à arquitetura;
    decisões em aberto apresentadas; checkpoint gravado; gate de confirmação aprovado.
ON_FAIL:
  - Se um repo não clona: reporte e oriente o usuário a checar auth/permissões de rede.
  - Se a demanda não atinge nível aceitável: não avance; continue a rodada de refinamento.
  - Se a spec contradiz a constituição: pare no hard gate e leve ao usuário.
```
