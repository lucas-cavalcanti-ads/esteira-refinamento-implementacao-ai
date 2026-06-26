# Tasks — Assistente Local de Estudos de Inglês

**Branch**: `claude-assistente-estudos-ingles` · **Spec**: ./spec.md · **Plan**: ./plan.md
Constituição v1.0.0 · SHA `57a3cd1`.

Convenções: `[P]` = paralelizável (arquivos independentes). Ordem respeita TDD (teste antes do
código de produção) e a regra de dependência da Clean Architecture (domínio → aplicação → adapters →
interface). Cada task referencia FR/US.

---

## Fase 0 — Setup & Andaime (bloqueia tudo)

- **T001** Inicializar projeto Maven Java 21 + Spring Boot (Web, Validation), `pom.xml` com
  dependências: AWS SDK v2 (dynamodb-enhanced), Apache PDFBox, Anthropic Java SDK, Resilience4j
  (spring-boot starter), springdoc-openapi, JaCoCo; `./mvnw` wrapper.
- **T002** [P] Estrutura de pacotes Clean Architecture: `domain/`, `application/`, `infrastructure/`,
  `interface/rest/` conforme plan.md.
- **T003** [P] `docker-compose.yml` com LocalStack (serviço dynamodb) + app; `.env.example` com
  `ANTHROPIC_API_KEY`; `.gitignore` cobrindo `data/`, `.env`, `target/`.
- **T004** [P] `infra/terraform/` criando a tabela DynamoDB `english_partner` (on-demand) contra o
  endpoint LocalStack (§4, §7).
- **T005** **`start.sh` e `stop.sh`** — comando único: `start.sh` faz compose up + terraform apply +
  espera health + imprime URL da Swagger UI; `stop.sh` faz compose down preservando `data/`
  (FR-021/US4/SC-008).
- **T006** [P] Configuração externalizada (`application.yml` + env): endpoint LocalStack, `data/`
  base path, modelo/chave da IA, timeouts Resilience4j (§12).
- **T007** [P] Logging estruturado (Logback JSON) nos pontos de entrada/saída/falha (§5).
- **T008** [P] GitHub Actions `ci.yml`: build Maven + testes (com LocalStack/Testcontainers) + JaCoCo
  (§6).

## Fase 1 — Domínio (núcleo, sem framework) [bloqueia aplicação]

- **T009** [P] Entidades + value objects: `Unit`, `Attachment`, `Note`, `Topic`, `GeneratedContent`,
  `RecurringError`, `Progress` (regras: número único, enums de status) — FR-001/003/004/005/015.
- **T010** [P] Erros de domínio explícitos: `UnitAlreadyExistsException`,
  `InsufficientBaseException`, `ExtractionFailedException`, etc. (tratamento de erro de 1ª classe).
- **T011** [P] **Portas** (interfaces no domínio): `UnitRepository`, `ArtifactStore`, `SearchIndex`,
  `PdfTextExtractor`, `ContentGenerator` — define o contrato que os adapters implementam.
- **T012** [P] Testes unitários do domínio (invariantes de Unit, enums, erros) — §3.

## Fase 2 — US1: Organizar units e materiais com persistência local (P1 / MVP)

> Independent test: criar unit, anexar 2 PDFs, anotar, reabrir e tudo persiste (offline).

- **T013** [P] Teste unitário use case `CreateUnit` (cria meta + dispara criação de pasta) — FR-001/002.
- **T014** Use case `CreateUnit` + `AttachFile` + `EditNote` + `RegisterTopics`/`RegisterCorrection`
  (orquestram ArtifactStore + UnitRepository) — FR-001..005.
- **T015** Adapter `FileSystemArtifactStore`: cria `data/units/unit-NN/`, grava PDFs/`notes.md`/
  `topics.json`/`unit.json` (fonte da verdade) — FR-002/007.
- **T016** Adapter `DynamoDbUnitRepository` (single-table, acesso só aqui) — FR-006/008; §4.
- **T017** Adapter `PdfBoxTextExtractor` (extrai texto; marca `NO_TEXT` em PDF só-imagem) — FR-005/edge.
- **T018** Reconciliação na inicialização: ler `data/` e (re)popular o índice DynamoDB — FR-009/010,
  reconstrução do índice (edge: arquivos editados fora).
- **T019** Endpoints REST US1: `POST /units`, `GET /units`, `GET /units/{n}`,
  `POST /units/{n}/attachments`, `PUT /units/{n}/notes`, `PUT /units/{n}/topics`,
  `PUT /units/{n}/correction` — FR-017.
- **T020** Teste de **integração** US1 com LocalStack (Testcontainers): cria→anexa→anota→reinicia→
  consulta; valida persistência e offline-read (SC-002/SC-006).
- **T021** Teste de **contrato** dos endpoints US1 contra `openapi.yaml` (§11).

## Fase 3 — US4: Bootstrap de comando único (P1) — validação

> Em paralelo lógico à US1 (depende de T003–T006).

- **T022** Teste/script de fumaça: `./start.sh` num ambiente limpo sobe LocalStack+app+tabela e o
  health responde; `./stop.sh` derruba preservando `data/` (SC-008).
- **T023** Documentar pré-requisitos e fluxo no `quickstart.md`/`README.md` do repo-alvo (DoD §8).

## Fase 4 — US2: Geração assistida usando a base local (P2)

> Independent test: gerar resumo + ≥5 exercícios (mirando erros recorrentes) + ≥10 flashcards, salvos.

- **T024** [P] Teste unitário dos use cases de geração (mock de `ContentGenerator`): valida que o
  prompt inclui contexto da unit + erros recorrentes anteriores e que conta ≥5 / ≥10 — SC-003/SC-004.
- **T025** Adapter `ClaudeContentGenerator` com **Resilience4j** (timeout/retry/circuit breaker),
  chave via env, log de falha externa — FR-011/012/013; §2/§5/§9; ADR-002.
- **T026** Use cases `GenerateSummary` (→`summary.md`), `GenerateExercises` (→`exercises.md`, usa
  erros recorrentes), `GenerateFlashcards` (→`flashcards.json`); persistência automática + proveniência
  — FR-006/010/011/012/013.
- **T027** Tratamento de indisponibilidade (offline/base insuficiente): retornar 503/422 sem quebrar
  leitura da base — edge cases / FR-019.
- **T028** Endpoints `POST /units/{n}/generate/{summary|exercises|flashcards}` + `GET /export` — FR-020.
- **T029** Teste de integração US2 (geração com `ContentGenerator` stub determinístico): conta ≥5
  exercícios / ≥10 flashcards e confirma referência a erro recorrente anterior — SC-003/SC-004.

## Fase 5 — US3: Progresso, erros recorrentes, status e busca (P3)

- **T030** [P] Use case `ConsolidateRecurringErrors`: extrai de correções/anotações; grava
  `errors.json` por unit + `knowledge/recurring-errors.json` — FR-014.
- **T031** Use case `MarkStatus` (tema/unit → revisado/reforçar/dominado) — FR-015.
- **T032** Use case `GetProgress` (derivado: materiais/homework/correção/pendências) — FR-016.
- **T033** Use case `SearchKnowledgeBase` + adapter `DynamoDbSearchIndex` (itens `TERM#token`); busca
  em notas/temas/vocabulário/exercícios/flashcards/erros — FR-018/SC-005.
- **T034** Endpoints `GET /progress`, `GET /errors`, `GET /search` — FR-014/016/018.
- **T035** Teste de integração US3: progresso, consolidação de erros e busca por palavra-chave
  retornando categorias relevantes — SC-005.

## Fase 6 — Acabamento & DoD

- **T036** Garantir cobertura JaCoCo no mínimo exigido e **suíte 100% verde** (§3); corrigir gaps.
- **T037** Revisar OpenAPI publicado (Swagger UI) vs. `contracts/openapi.yaml`; versionar `/api/v1`
  (§11).
- **T038** README do repo-alvo: visão, comando único, estrutura `data/`, offline, export (DoD §8).
- **T039** Conferir Definition of Done (testes, ADRs versionados, logs, segredos via env, IaC) — §8.

---

## Mapa cobertura FR → tasks

| FR | Tasks |
|---|---|
| FR-001/002 | T013–T016, T019 |
| FR-003 | T014, T015, T019 |
| FR-004/005 | T014, T015, T017, T019 |
| FR-006/008/010 | T015, T016, T026 |
| FR-007 | T015 |
| FR-009 | T018 |
| FR-011/012/013 | T024–T029 |
| FR-014 | T030, T034 |
| FR-015 | T031 |
| FR-016/017 | T019, T032, T034 |
| FR-018 | T033, T034 |
| FR-019 | T018, T020, T027 |
| FR-020 | T028 |
| FR-021 | T003–T006, T022 |

**MVP** = Fase 0 + Fase 1 + US1 (T013–T021) + US4 (T022–T023). US2 e US3 são incrementos sobre o MVP.
