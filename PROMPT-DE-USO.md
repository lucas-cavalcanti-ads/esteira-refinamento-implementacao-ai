# Prompt de Uso — Como Ativar a Esteira

Este arquivo tem **(A)** o passo a passo para ativar a esteira e **(B)** um molde de prompt para você
preencher a cada demanda. Para um exemplo já preenchido, veja `PROMPT-EXEMPLO.md`.

---

## A) Como ativar a esteira

1. Garanta que o **repo-alvo existe** no GitHub (a esteira clona; não cria o repo).
2. Abra o Claude Code com **esta esteira** como diretório de trabalho:
   ```bash
   cd /Users/lucavpa/Documents/tech/gen-ai/esteiras-ai/esteira-refin-desenv-v1
   claude
   ```
   No **celular**: aponte a sessão remota do Claude Code para este mesmo repositório.
3. Dispare o orquestrador:
   ```
   /run
   ```
4. **Cole o prompt preenchido** (molde abaixo) como a próxima mensagem.
5. Siga os gates de confirmação entre as etapas. A esteira pergunta antes de avançar; decisões em
   aberto vêm em lote, com sugestões.

> Primeira vez? Rode o bootstrap antes (ver `GUIA-DE-USO.md`, seção 2): `chmod +x scripts/*.sh`,
> `./scripts/setup.sh`, `./scripts/fetch-constitution.sh`.

---

## B) Molde do prompt (preencha e cole após `/run`)

```
Demanda: <título curto da demanda>

Contexto: <por que esta demanda existe, o problema atual e o objetivo. 2–5 linhas.>

Requisitos:
- <o que a solução precisa fazer — um item por linha>
- <...>

Critérios de aceite:
- <condição verificável de "pronto" — objetiva e testável>
- <...>

Repositório-alvo: <owner/repo>
(branch base: <opcional; default main>; branch de implementação: <opcional; default: criada a partir da main>)
```

### Como preencher bem

- **Contexto**: dê o "porquê" e o objetivo, não só o "o quê". Ajuda o refinamento.
- **Requisitos**: o que a solução faz, do ponto de vista de quem usa — sem detalhe técnico (o "como"
  é decidido na Etapa 2, respeitando a arquitetura de referência).
- **Critérios de aceite**: cada um deve ser **verificável objetivamente** (um revisor diz
  PASS/FAIL). Critérios fracos derrubam a nota da spec.
- **Repositório-alvo**: precisa existir. Branches são opcionais (os defaults são aplicados).

### Atalho: já tenho uma spec pronta (perfil SPEC-PRONTA)

Se você já tem o resultado de um Spec Kit, em vez do molde acima informe:

```
Spec pronta: <link para a spec no formato Spec Kit>
Repositório-alvo: <owner/repo>
```

A esteira valida a spec reforçado (formato, completude e conformidade com a arquitetura) e pula
direto para a implementação (Etapa 3).

---

## O que a esteira entrega ao final

- Branch de refinamento no `refinamentos-gen-ai` com a spec, o `scorecard.md` e os ADRs.
- **Nota da spec** (Etapa 2) e **nota da implementação** (Etapa 3), registradas no `quality-log.jsonl`.
- PR aberto no repo-alvo, com a implementação conforme à spec e à arquitetura, testes passando e um
  relatório final com as métricas de execução.
