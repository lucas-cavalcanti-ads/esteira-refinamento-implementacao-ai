# Guia de Uso — Esteira de Refinamento e Desenvolvimento V1

Passo a passo para operar a esteira: de uma demanda até código conforme, testado, com PR aberto e
nota de qualidade. Roda no Claude Code, **localmente** (Mac) ou **remotamente** (celular).

> Visão conceitual e arquitetura: ver `README.md`. Este guia é a parte operacional.

---

## 1. Pré-requisitos

- `git`, `python3`, [`uv`](https://docs.astral.sh/uv/) (ou a CLI `specify`) e — recomendado —
  [`gh`](https://cli.github.com/) para abrir PRs.
- Autenticação do GitHub configurada (PAT no keychain), inclusive no ambiente remoto se for usar
  pelo celular.
- `CONSTITUTION.md` presente no repo `arquitetura-referencia` (já está, em `v1.0.0`).

> Não precisa conferir isso na mão: o bootstrap (abaixo) roda um `check-prereqs.sh` que verifica
> tudo e aborta com instruções claras se faltar algo obrigatório.

## 2. Bootstrap (uma vez) — comando único

Um único script faz tudo na ordem certa: verifica pré-requisitos, dá permissão aos scripts, instala
o Spec Kit e valida a constituição.

```bash
cd /Users/lucavpa/Documents/tech/gen-ai/esteiras-ai/esteira-refin-desenv-v1
bash scripts/bootstrap.sh
```

> Use `bash scripts/bootstrap.sh` na primeira vez: os scripts ainda não têm permissão de execução, e
> o próprio bootstrap concede (`chmod +x`) a partir daí. Depois disso, `./scripts/bootstrap.sh`
> também funciona.

O bootstrap roda, em ordem:

1. `check-prereqs.sh` — confere `git`, `python3`, `uv`/`specify` (obrigatórios) e `gh` (recomendado).
   **Aborta** se faltar algo obrigatório.
2. `chmod +x scripts/*.sh`.
3. `setup.sh` — instala os comandos do Spec Kit e (opcional) puxa skills compartilhadas.
4. `fetch-constitution.sh` — materializa a constituição e imprime `ARQUITETURA_VERSION` e
   `CONSTITUTION_SHA`.

Ao final deve aparecer "Bootstrap concluído". Se parar num passo, a mensagem diz o que resolver.

### Conferir a configuração (opcional)

O `harness.config.json` já vem pré-preenchido com seus repos, `local_path` e timezone — normalmente
não precisa mexer. Se quiser revisar, abra no seu editor:

```bash
nano harness.config.json        # ou: vim harness.config.json , code harness.config.json (VS Code)
```

> Por que `$EDITOR arquivo` dá erro: `$EDITOR` é a variável do seu editor padrão. Se ela não estiver
> definida no shell, o comando vira só o nome do arquivo e o shell tenta executá-lo, falhando. Use um
> editor concreto (acima) ou defina antes: `export EDITOR=nano`.

## 3. Rodar uma demanda (fluxo normal)

1. **Garanta que o repo-alvo existe** no GitHub (a esteira clona, não cria o repo).
2. Abra o Claude Code com a esteira como diretório de trabalho:
   ```bash
   cd /Users/lucavpa/Documents/tech/gen-ai/esteiras-ai/esteira-refin-desenv-v1
   claude
   ```
3. Dispare o orquestrador:
   ```
   /run
   ```
4. **Cole a demanda.** Use `PROMPT-DE-USO.md` como molde (ou `PROMPT-EXEMPLO.md` para um exemplo
   pronto).
5. **Etapa 1 (intake):** responda eventuais perguntas de refinamento (a esteira só pergunta se algo
   estiver abaixo do nível aceitável). Confirme o gate para avançar.
6. **Etapa 2 (refinamento):** ao final, a esteira apresenta um relatório único com a branch criada no
   `refinamentos-gen-ai`, os artefatos, decisões em aberto (em lote, com sugestões) e a **nota da
   spec**. Decida as pendências e confirme avançar para a implementação.
7. **Etapa 3 (implementação):** a esteira implementa, garante conformidade com a spec e com a
   arquitetura (corrigindo em ciclo), roda os testes e abre o **PR**. Revise o relatório final
   (tempo, contagem de arquivos/testes, conformidade, **nota da implementação**, link do PR).
8. **Aprove e mescle o PR** no repo-alvo quando estiver satisfeito.

## 4. Etapas isoladas (retomar/depurar)

`/etapa1`, `/etapa2`, `/etapa3` rodam cada etapa sozinha. O progresso fica em
`workspace/.run-state.json`; se uma run falhar no meio, o `/run` oferece retomar de onde parou.

## 5. Atalho: já tenho uma spec pronta (perfil SPEC-PRONTA)

Se você já tem o resultado de um Spec Kit, informe o **link da spec** na Etapa 1. A esteira valida
reforçado (formato, completude e **conformidade com a arquitetura**) e pula direto para a Etapa 3.

## 6. Pelo celular

Aponte a sessão remota do Claude Code para este repositório e rode `/run` igual. No celular o
`local_path` da arquitetura não existe, então o `fetch-constitution.sh` cai automaticamente para o
clone da `url` — sem ajuste manual.

## 7. Onde ficam os resultados

- **Specs + `scorecard.md` + ADRs + `quality-log.jsonl`** → repo `refinamentos-gen-ai`.
- **Código + PR** → repo-alvo.
- **`workspace/`** → efêmero (clones e estado da run); pode descartar.

## 8. Medir a qualidade do harness

Cada run registra duas linhas (spec e impl) no `quality-log.jsonl`. Para ver a tendência:

```bash
./scripts/scorecard-trend.sh /caminho/para/refinamentos-gen-ai/quality-log.jsonl
```

Mostra média por fase e por versão (rubrica + arquitetura), saúde de testes/conformidade e as
**sub-notas mais fracas** — onde ajustar o harness.

## 9. Evoluir a arquitetura (bump de versão)

Quando suas regras mudarem: edite o `CONSTITUTION.md` no repo de arquitetura, suba o
`arquitetura_version` (marcador + metadados + histórico) e commite. O próximo run carimba a nova
versão nas notas. Política completa em `arquitetura-referencia/VERSIONAMENTO.md`.

## 10. Quando algo falha (resumo dos ON_FAIL)

- **Repo-alvo não clona** → problema de auth/rede; a esteira reporta e orienta.
- **`analyze` não fica limpo** após N correções → a esteira para e te leva o diagnóstico.
- **Teste falhando** que não estabiliza → o PR **não** é aberto como "conforme".
- **Constituição ausente** no repo de arquitetura → a Etapa 2 pausa e orienta o bootstrap.
- Em qualquer falha, o checkpoint é preservado para retomada.

## Scripts disponíveis (referência rápida)

| Script | Para quê |
|---|---|
| `scripts/bootstrap.sh` | **Comando único** de setup (chama os de baixo na ordem). |
| `scripts/check-prereqs.sh` | Verifica as ferramentas de pré-requisito. |
| `scripts/setup.sh` | Instala o Spec Kit e puxa skills compartilhadas. |
| `scripts/fetch-constitution.sh` | Materializa a constituição (versão + SHA). |
| `scripts/metrics.sh` | Telemetria (timestamps UTC-3, diff de arquivos/testes). |
| `scripts/scorecard-trend.sh` | Tendência de qualidade a partir do `quality-log.jsonl`. |
