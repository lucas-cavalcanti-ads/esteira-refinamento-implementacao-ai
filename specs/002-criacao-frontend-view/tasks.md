# Tasks: English Partner View — Frontend de Estudos

**Input**: Design documents from `specs/002-criacao-frontend-view/`

**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅ | contracts/ ✅

**Tests**: Vitest (unitários do api client) + Playwright smoke e2e — gerados nas fases correspondentes.

**Organization**: Tarefas agrupadas por user story para permitir implementação e validação incremental.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: pode rodar em paralelo (arquivos diferentes, sem dependências entre si)
- **[Story]**: user story correspondente (US1–US7 do spec.md)

---

## Phase 1: Setup (Inicialização do Projeto)

**Purpose**: Inicializar o repositório git, estrutura de diretórios e arquivos de configuração.

- [ ] T001 Inicializar repositório git em `english-partner-view/` com branch `main` e criar branch `claude-criacao-frontend-view` a partir dela
- [ ] T002 Criar `english-partner-view/package.json` com dependências: `vite`, `typescript`, `@material/web`, `marked`; devDependencies: `vitest`, `@playwright/test`, `@types/marked`, `eslint`
- [ ] T003 [P] Criar `english-partner-view/vite.config.ts` com configuração: port 5173, envPrefix VITE_, resolve aliases para `src/`
- [ ] T004 [P] Criar `english-partner-view/tsconfig.json` com target ES2022, module ESNext, strict true, paths mapeados para `src/`
- [ ] T005 [P] Criar `english-partner-view/index.html` como entry point da SPA: carrega `src/main.ts`, inclui `<ep-app>` como root element
- [ ] T006 [P] Criar `english-partner-view/.env.example` com `VITE_API_URL=http://localhost:8080`
- [ ] T007 Criar estrutura de diretórios completa conforme plan.md: `src/api/`, `src/pages/`, `src/components/`, `src/styles/`, `test/unit/`, `test/e2e/`

**Checkpoint**: `npm install` e `npm run dev` devem funcionar sem erros (exibe página em branco em localhost:5173).

---

## Phase 2: Fundacional (Pré-requisitos Bloqueantes)

**Purpose**: Infraestrutura central que TODA user story depende. Deve estar completa antes de qualquer fase de user story.

**⚠️ CRÍTICO**: Nenhuma fase de user story pode começar sem esta fase concluída.

- [ ] T008 Criar `english-partner-view/src/types.ts` com todas as interfaces TypeScript do data-model.md: `UnitResponse`, `UnitViewResponse`, `UnitStatus`, `AttachmentResponse`, `AttachmentType`, `TopicDto`, `TopicKind`, `MasteryStatus`, `GeneratedRefResponse`, `GeneratedContentType`, `UnitProgressResponse`, `RecurringErrorResponse`, `SearchHitResponse`, `SearchHitKind`, `CreateUnitRequest`, `ContentRequest`, `MasteryStatusRequest`, `RecurringErrorRequest`, `ApiError`
- [ ] T009 Criar `english-partner-view/src/api/client.ts`: wrapper sobre `fetch` com base URL de `import.meta.env.VITE_API_URL`, header `Content-Type: application/json`, extração de `message` de erros Spring Boot, lançamento de `ApiError` tipado para erros 4xx/5xx e falhas de rede
- [ ] T010 [P] Criar `english-partner-view/src/api/units.ts`: funções `listUnits()`, `createUnit(req)`, `getUnit(n)`, `attachFile(n, type, file)`, `saveCorrection(n, content)`, `saveNotes(n, content)`, `saveTopics(n, topics)`, `updateTopicStatus(n, topicId, status)`, `saveErrors(n, errors)` — consumindo os endpoints de `/api/v1/units/*` conforme contracts/api-contract.md
- [ ] T011 [P] Criar `english-partner-view/src/api/knowledge.ts`: funções `getProgress()`, `getErrors(unitFilter?)`, `search(q)` — consumindo `/api/v1/progress`, `/api/v1/errors`, `/api/v1/search`
- [ ] T012 [P] Criar `english-partner-view/src/api/generation.ts`: funções `generateSummary(n)`, `generateExercises(n)`, `generateFlashcards(n)`, `exportUnit(n, format)` (exportUnit retorna Blob e aciona download via `URL.createObjectURL`) — consumindo `/api/v1/units/{n}/generate/*` e `/api/v1/units/{n}/export`
- [ ] T013 Criar `english-partner-view/src/router.ts`: router hash-based que escuta `hashchange` e `load`, faz parse do `location.hash` em rota + parâmetros, chama a função de render da página correspondente, e exporta `navigate(hash: string)` para navegação programática
- [ ] T014 Criar `english-partner-view/src/components/app-shell.ts`: componente que renderiza o `<md-navigation-drawer>` com itens (Visão Geral, Units, Progresso, Erros, Busca), `<md-top-app-bar>` e o `<main>` onde as páginas são montadas; registra os `<md-*>` custom elements necessários do `@material/web`
- [ ] T015 [P] Criar `english-partner-view/src/components/loading.ts`: helper que exibe/oculta um `<md-circular-progress>` indeterminado sobreposto ao conteúdo durante chamadas à API
- [ ] T016 [P] Criar `english-partner-view/src/components/error-banner.ts`: componente `<md-banner>` ou snackbar que exibe mensagens de erro mapeadas de `ApiError` usando o mapa de erros do contracts/api-contract.md
- [ ] T017 Criar `english-partner-view/src/styles/main.css`: importa tokens de tema Material Web, define variáveis CSS de tema (cores primary/secondary/surface), reset básico, layout do app shell (drawer + main)
- [ ] T018 Criar `english-partner-view/src/main.ts`: entry point que importa `app-shell.ts`, monta o componente raiz no `<ep-app>` e inicializa o router
- [ ] T019 Escrever `english-partner-view/test/unit/api-client.test.ts` com Vitest: testa `client.ts` — (a) request com sucesso retorna JSON parseado; (b) erro 4xx/5xx lança `ApiError` com status e message corretos; (c) falha de rede lança `ApiError` com status 0 e mensagem de conectividade; usa `vi.stubGlobal('fetch', ...)` para mock
- [ ] T020 Configurar scripts npm em `package.json`: `"dev": "vite"`, `"build": "tsc && vite build"`, `"test": "vitest run"`, `"test:e2e": "playwright test"`, `"lint": "eslint src/"`

**Checkpoint**: `npm run test` passa; `npm run dev` inicia sem erro; app-shell renderiza nav com 5 itens no browser.

---

## Phase 3: US7 — Iniciar e Desligar a Solução (Priority: P1)

**Goal**: Scripts `start.sh` e `stop.sh` no diretório raiz `english-partner/` que orquestram backend + frontend.

**Independent Test**: Executar `./start.sh` a partir de `english-partner/` a partir de estado desligado; verificar que backend e frontend sobem em ordem e as URLs aparecem no terminal. Executar `./stop.sh` e verificar desligamento ordenado.

- [ ] T021 [US7] Criar `english-partner/start.sh`: (1) chamar `english-partner-backend/start.sh` em background aguardando sua conclusão (que já faz health check do backend); (2) aguardar `http://localhost:8080/actuator/health` com loop de 60×3s como fallback próprio; (3) iniciar `npm run dev` no diretório `english-partner-view/` em background gravando PID em `/tmp/ep-frontend.pid`; (4) aguardar `http://localhost:5173` responder (loop 20×3s); (5) imprimir URLs: `http://localhost:5173` (frontend) e `http://localhost:8080/swagger-ui` (Swagger UI)
- [ ] T022 [US7] Criar `english-partner/stop.sh`: (1) matar processo do frontend via PID de `/tmp/ep-frontend.pid` (com fallback `pkill -f "vite"`); (2) chamar `english-partner-backend/stop.sh`; (3) confirmar encerramento no terminal. Garantir `set -euo pipefail` e tornar ambos os scripts executáveis (`chmod +x`)

**Checkpoint**: Cenário V1 do quickstart.md passa — `./start.sh` exibe ambas as URLs; `./stop.sh` encerra tudo.

---

## Phase 4: US1 — Navegar e Gerenciar Units (Priority: P1) 🎯 MVP

**Goal**: Listar units existentes, criar nova unit, navegar para o detalhe, tratar unit duplicada e lista vazia.

**Independent Test**: Abrir `#/units`, criar unit número=1 título="Test", ver na listagem, clicar e ser levado a `#/units/1` (mesmo que a tela de detalhe esteja vazia ainda). Tentar criar unit duplicada e ver mensagem de erro.

- [ ] T023 [P] [US1] Criar `english-partner-view/src/pages/dashboard.ts`: chama `getProgress()` e renderiza cards `<md-card>` com contagens (total de units, units por status, total de tópicos pendentes); exibe `loading` durante fetch e `error-banner` em caso de falha
- [ ] T024 [P] [US1] Criar `english-partner-view/src/pages/units-list.ts`: chama `listUnits()` e renderiza `<md-list>` de units (número, título, status badge); botão "Nova unit" abre `<md-dialog>` com formulário (`<md-outlined-text-field>` para número/título/data/observações + `<md-select>` para status AGENDADA|REALIZADA|EM_REVISAO|CONCLUIDA); ao confirmar chama `createUnit()`, atualiza lista ou exibe `error-banner` (409=duplicada, 400=validação); lista vazia exibe estado empty com texto e botão de ação
- [ ] T025 [US1] Registrar rotas no `src/router.ts`: `#/` → `dashboard`, `#/units` → `units-list`; adicionar item de fallback para hash desconhecido redirecionar para `#/`
- [ ] T026 [US1] Conectar itens do nav drawer no `app-shell.ts` para usar `navigate()` do router e marcar o item ativo conforme o hash corrente

**Checkpoint**: Cenário V2 do quickstart.md passa — criar unit, ver na lista, clicar e navegar.

---

## Phase 5: US2 — Ver e Enriquecer Dados de uma Unit (Priority: P1)

**Goal**: Tela completa de uma unit com metadados, anotação Markdown, tópicos (add/edit/status), erros recorrentes e referências de conteúdos gerados.

**Independent Test**: Abrir `#/units/1`, ver todos os campos da unit; editar nota com Markdown e salvar (preview aparece); adicionar tópico VOCABULARY "run out of", salvar, alterar status para DOMINADO; registrar erro recorrente.

- [ ] T027 [US2] Criar `english-partner-view/src/pages/unit-detail.ts` — esqueleto base: extrai `number` do hash, chama `getUnit(n)`, exibe `loading` e `error-banner`; renderiza seção de metadados (número, título, data, status badge, observações) usando `<md-card>` e `<md-chip-set>` para status
- [ ] T028 [US2] Adicionar seção de **Anotação** em `unit-detail.ts`: o editor sempre inicia vazio (limitação da API: `notesPath` é um caminho de arquivo no servidor sem endpoint de leitura — spec:FR-013); exibe `<md-outlined-textarea>` editável + `<div>` de preview com `marked.parse()` atualizado em tempo real; botão "Salvar" chama `saveNotes(n, content)`; exibe snackbar de sucesso ou `error-banner` em falha; quando `notesPath != null`, exibe aviso "Nota existente — editor iniciado vazio (limitação da API atual)"
- [ ] T029 [US2] Adicionar seção de **Tópicos** em `unit-detail.ts`: renderiza lista `<md-list>` dos tópicos existentes com ícone de tipo, label e chip de masteryStatus; botão "Adicionar tópico" abre `<md-dialog>` com `<md-select>` para kind (GRAMMAR|VOCABULARY|EXPRESSION|PRONUNCIATION|ERROR) + `<md-outlined-text-field>` para label; cada item existente tem (a) botão "Editar" que reabre o mesmo dialog preenchido com os valores atuais — ao confirmar atualiza o item in-memory e envia array completo via `saveTopics()`, e (b) botão de status que abre dialog de alteração via `updateTopicStatus()` (atualização individual sem reenviar o array); ao salvar novos tópicos via "Adicionar" também usa `saveTopics()` com o array atualizado
- [ ] T030 [US2] Adicionar seção de **Erros recorrentes** em `unit-detail.ts`: lista os erros existentes; botão "Registrar erro" abre dialog com label + categoria; ao salvar chama `saveErrors()` com o array atualizado
- [ ] T031 [US2] Adicionar seção de **Conteúdos gerados** em `unit-detail.ts`: lista `generated[]` da UnitViewResponse exibindo type, count, `generatedAt` formatada, path; exibe "Nenhum conteúdo gerado ainda" quando vazio
- [ ] T032 [US2] Registrar rota `#/units/:number` no `src/router.ts` extraindo o parâmetro numérico e passando para `unit-detail`

**Checkpoint**: Cenário V3 do quickstart.md passa — nota Markdown salva e renderizada; tópico adicionado e status alterado.

---

## Phase 6: US3 — Anexar Materiais (Priority: P2)

**Goal**: Upload de PDF de material, homework e correção; correção em texto; lista de anexos na tela da unit.

**Independent Test**: Na tela de uma unit, fazer upload de um PDF como MATERIAL e ver na lista de anexos. Registrar correção em texto e ver salva.

- [ ] T033 [P] [US3] Adicionar seção de **Anexos** em `unit-detail.ts`: renderiza lista `<md-list>` dos `attachments[]` com tipo (chip), path; botão "Anexar PDF" abre dialog com `<md-select>` de tipo (MATERIAL|HOMEWORK|CORRECTION) + `<input type="file" accept=".pdf">`; ao confirmar usa `FormData` e chama `attachFile(n, type, file)`; exibe progresso de upload e erro se falhar; valida extensão .pdf antes do envio
- [ ] T034 [US3] Adicionar seção de **Correção em texto** em `unit-detail.ts`: `<md-outlined-textarea>` para registrar correção textual; botão "Salvar correção" chama `saveCorrection(n, content)`; exibe o conteúdo salvo quando já existe; estados: loading, sucesso, erro

**Checkpoint**: Cenário V4 do quickstart.md passa — upload de PDF listado como MATERIAL.

---

## Phase 7: US4 — Gerar e Exportar Conteúdos (Priority: P2)

**Goal**: Botões de geração (resumo/exercícios/flashcards) com loading, tratamento de base insuficiente e IA indisponível; exportação com download de arquivo.

**Independent Test**: Com material anexado, clicar "Gerar resumo" → loading aparece → referência aparece em conteúdos gerados. Exportar em Markdown → download inicia.

- [ ] T035 [P] [US4] Adicionar botões de **Geração** à seção de conteúdos gerados em `unit-detail.ts`: botões `<md-filled-button>` "Gerar resumo", "Gerar exercícios", "Gerar flashcards"; cada um mostra `<md-linear-progress>` durante chamada; ao concluir atualiza a lista `generated[]`; mapeia 422 → "Base insuficiente para geração…" e 503 → "Serviço de IA temporariamente indisponível…" via `error-banner`
- [ ] T036 [US4] Adicionar seção de **Exportação** em `unit-detail.ts`: `<md-select>` com opções md|json|pdf; botão "Exportar"; ao confirmar chama `exportUnit(n, format)` que retorna Blob; aciona download via `URL.createObjectURL(blob)` + `<a download>` programático; exibe loading durante request e erro se falhar

**Checkpoint**: Cenários V6 e V7 do quickstart.md passam — geração e exportação funcionais.

---

## Phase 8: US5 — Progresso e Erros Recorrentes (Priority: P3)

**Goal**: Tela de progresso por unit com indicadores visuais; tela de erros consolidados com filtro por unit.

**Independent Test**: Com units em estados diferentes, `#/progress` mostra tabela com indicadores corretos. `#/errors` lista erros consolidados; filtrar por unit mostra apenas os dela.

- [ ] T037 [P] [US5] Criar `english-partner-view/src/pages/progress.ts`: chama `getProgress()`; renderiza tabela `<md-data-table>` com colunas: Unit, Material ✅/❌, Homework ✅/❌, Correção ✅/❌, Tópicos pendentes; cada linha clicável navega para `#/units/{n}`; loading e error-banner
- [ ] T038 [P] [US5] Criar `english-partner-view/src/pages/errors.ts`: chama `getErrors()` (sem filtro inicial); renderiza `<md-list>` de erros com label, categoria, occurrences, sourceUnits; `<md-select>` de filtro por unit (carregado via `listUnits()`); ao selecionar unit re-chama `getErrors(unitNumber)`; loading e error-banner
- [ ] T039 [US5] Registrar rotas `#/progress` e `#/errors` no `src/router.ts`

**Checkpoint**: Cenário V8 do quickstart.md passa — progresso e erros visíveis e navegáveis.

---

## Phase 9: US6 — Busca (Priority: P3)

**Goal**: Campo de busca por palavra-chave com resultados agrupados por tipo.

**Independent Test**: Buscar "present" → resultados aparecem agrupados por tipo (VOCABULARY, UNIT, etc.) com snippets. Clicar num resultado de tipo UNIT navega para a unit.

- [ ] T040 [US6] Criar `english-partner-view/src/pages/search.ts`: `<md-search-bar>` (ou `<md-outlined-text-field>` + botão); ao submeter chama `search(q)` e renderiza resultados agrupados por `kind` em `<md-list>` com subheadings; cada item exibe snippet e, para kind=UNIT, é clicável navegando para `#/units/{unitNumber}`; estado empty e error-banner
- [ ] T041 [US6] Registrar rota `#/search` no `src/router.ts`

**Checkpoint**: Cenário V9 do quickstart.md passa — busca retorna e agrupa resultados.

---

## Phase 10: Polish & Preocupações Transversais

**Purpose**: CI/CD, testes e2e, responsividade, error boundary e documentação.

- [ ] T042 [P] Criar `.github/workflows/ci.yml` em `english-partner-view/`: jobs `lint` (`npm run lint`), `test` (`npm run test`) e `build` (`npm run build`); trigger em push e PR para branch `claude-criacao-frontend-view`
- [ ] T043 [P] Escrever `english-partner-view/test/e2e/smoke.spec.ts` com Playwright: smoke test cobrindo V2 (criar unit + ver na lista) e V3 (anotação + tópico) do quickstart.md; requer backend em execução (`baseURL: 'http://localhost:5173'`)
- [ ] T044 [P] Criar `english-partner-view/playwright.config.ts`: configurar baseURL, timeout, reporter text, diretório de testes `test/e2e/`
- [ ] T045 Validar error boundary (cenário V10 do quickstart.md — backend offline): garantir que `error-banner` aparece e nenhuma tela em branco ocorre
- [ ] T046 [P] Passar responsividade: ajustar `src/styles/main.css` para breakpoints de tela menor (≤768px): nav drawer colapsado em `<md-navigation-bar>`, tabelas com scroll horizontal, formulários em coluna única
- [ ] T047 [P] Criar `english-partner-view/README.md`: pré-requisitos, setup (`npm install`, `.env.local`), comandos (`npm run dev`, `npm run test`), link para quickstart.md

---

## Dependencies & Execution Order

### Dependências entre fases

- **Phase 1 (Setup)**: sem dependências — inicia imediatamente
- **Phase 2 (Fundacional)**: depende de Phase 1 — BLOQUEIA todas as fases de user story
- **Phase 3 (US7 Scripts)**: pode ser paralela ao Phase 2 (scripts são Bash, independentes do código TS)
- **Phase 4 (US1)**: depende de Phase 2
- **Phase 5 (US2)**: depende de Phase 4 (unit-detail é extensão da rota `#/units/:n` iniciada em US1)
- **Phase 6 (US3)**: depende de Phase 5 (anexos são seção de unit-detail)
- **Phase 7 (US4)**: depende de Phase 5 (geração/export são seções de unit-detail)
- **Phase 8 (US5)**: depende de Phase 2 (páginas independentes de progress/errors)
- **Phase 9 (US6)**: depende de Phase 2 (página independente de search)
- **Phase 10 (Polish)**: depende de todas as fases anteriores

### Dependências entre user stories

- **US7 (P1)**: independente do código frontend — pode ser feita em paralelo ao Phase 2
- **US1 (P1)**: requer Phase 2; sem dependência de outras US
- **US2 (P1)**: requer US1 (rota `#/units/:n`)
- **US3 (P2)**: requer US2 (seção em unit-detail)
- **US4 (P2)**: requer US2 (seção em unit-detail)
- **US5 (P3)**: requer Phase 2; sem dependência de US1–US4
- **US6 (P3)**: requer Phase 2; sem dependência de US1–US5

### Dentro de cada fase

- Tarefas marcadas `[P]` dentro da mesma fase são paralelas entre si
- Tarefas sem `[P]` dependem das anteriores na mesma fase

---

## Parallel Execution Examples

### Phase 2 — Fundacional

```bash
# Grupo paralelo A (tipos e cliente HTTP):
T008: src/types.ts
T009: src/api/client.ts

# Grupo paralelo B (endpoints — após T008 e T009):
T010: src/api/units.ts
T011: src/api/knowledge.ts
T012: src/api/generation.ts

# Grupo paralelo C (componentes UI — independentes dos endpoints):
T014: src/components/app-shell.ts
T015: src/components/loading.ts
T016: src/components/error-banner.ts
T017: src/styles/main.css
```

### Phase 4 (US1) + Phase 8 (US5) + Phase 9 (US6)

```bash
# Após Phase 2, podem rodar em paralelo:
T023+T024: pages/dashboard.ts e pages/units-list.ts  [US1]
T037+T038: pages/progress.ts e pages/errors.ts       [US5]
T040: pages/search.ts                                [US6]
```

---

## Implementation Strategy

### MVP (US7 + US1 + US2)

1. Phase 1: Setup
2. Phase 2: Fundacional (CRÍTICO)
3. Phase 3: US7 (scripts de bootstrap)
4. Phase 4: US1 (listar + criar units)
5. Phase 5: US2 (detalhe + anotação + tópicos + erros)
6. **PARAR E VALIDAR**: cenários V1–V3 do quickstart.md

### Entrega Incremental

1. Setup + Fundacional → base pronta
2. US7 → bootstrap funcional
3. US1 → listagem e criação de units (MVP!)
4. US2 → tela completa da unit
5. US3 → anexos PDF
6. US4 → geração + exportação
7. US5 → progresso + erros consolidados
8. US6 → busca
9. Polish → CI/CD + e2e + responsividade

---

## Notes

- `[P]` = arquivos diferentes, sem dependência entre si — podem ser implementados em paralelo
- Cada checkpoint indica que a user story está independentemente validável
- Usar `error-banner` e `loading` em TODOS os pontos de chamada à API (FR-003 e FR-004)
- Exportação (T036): o download via `URL.createObjectURL` não requer nenhum servidor intermediário
- Scripts `start.sh`/`stop.sh` (T021/T022): não são rastreados em git — criar diretamente no filesystem
- `PUT /api/v1/units/{n}/topics` substitui TODOS os tópicos: o frontend deve sempre enviar o array completo atualizado
