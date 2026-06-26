# Implementation Plan: Assistente Local de Estudos de Inglês

**Branch**: `claude-assistente-estudos-ingles` | **Date**: 2026-06-20 | **Spec**: ./spec.md

**Input**: Feature specification from `./spec.md`

**Constituição**: arquitetura-referencia v1.0.0 · SHA `57a3cd1afa1551a430521f967918cc3703028057`

## Summary

App **local-first** de estudo de inglês que organiza units, anexos (PDFs de material/homework/
correção) e anotações numa árvore de arquivos legível, e gera conteúdo de estudo (resumo, ≥5
exercícios, ≥10 flashcards, erros recorrentes consolidados) usando a base local como contexto
contínuo. Abordagem técnica: serviço **Spring Boot (Java 21)** com **Clean Architecture/DDD**,
expondo **API REST com contrato OpenAPI**; persistência **híbrida** — o **filesystem é a fonte da
verdade** dos artefatos (`data/units/unit-NN/...`) e o **DynamoDB (on-demand, emulado via LocalStack)**
guarda metadados, índice de busca e progresso (acesso só via camada de repositório). Extração de PDF
com **Apache PDFBox**. Geração via **Claude API** (integração externa com **Resilience4j**:
timeout/retry/circuit breaker). Todo o ambiente sobe/derruba com **um único comando** (`./start.sh` /
`./stop.sh` sobre **Docker Compose** + **Terraform** para a tabela no LocalStack).

## Technical Context

**Language/Version**: Java 21 (LTS, Temurin via SDKMAN)

**Primary Dependencies**: Spring Boot (Web, Validation), AWS SDK v2 (DynamoDB Enhanced Client),
Apache PDFBox, Anthropic Java SDK (cliente Claude), Resilience4j (starter Spring Boot),
springdoc-openapi (geração do contrato OpenAPI), Testcontainers (LocalStack) para testes de integração

**Storage**: Híbrido — (1) **filesystem** `data/units/unit-NN/` como fonte da verdade dos artefatos
(PDFs, `notes.md`, `summary.md`, `exercises.md`, `flashcards.json`); (2) **DynamoDB** on-demand
(single-table) para metadados/índice/progresso, emulado localmente por **LocalStack**

**Testing**: JUnit 5 + Mockito (unitários), Testcontainers + LocalStack (integração de repositório),
testes de contrato dos endpoints REST (springdoc/OpenAPI). Cobertura via JaCoCo

**Target Platform**: Desktop local (macOS/Linux) via Docker; nenhuma dependência de nuvem em runtime

**Project Type**: Web service local (backend REST single-app) — interface consumida via Swagger UI

**Performance Goals**: Uso pessoal; respostas de leitura/listagem < 300 ms p95 local. Geração via IA
limitada pela latência do provedor externo (assíncrona/com timeout explícito)

**Constraints**: **Offline-first para a base já salva** (FR-019): abrir, listar e ler artefatos não
pode depender de internet. Geração nova pode exigir rede. **Single-command bootstrap** (FR-021)

**Scale/Scope**: 1 usuário, dezenas de units, poucos PDFs por unit. Sem concorrência multiusuário

## Constitution Check

*GATE: avaliado contra a constituição materializada v1.0.0.*

| # | Regra constitucional | Decisão no plano | Status |
|---|---|---|---|
| 1 | Clean Architecture + DDD; dependências para dentro | Camadas domain/application/infrastructure/interface; regras no domínio; portas/adapters | ✅ PASS |
| 2 | Java 21 + Maven + Spring Boot (REST); Resilience4j em toda integração externa | Stack adotada; chamada à Claude API encapsulada com Resilience4j (timeout 5s, retry idempotente, circuit breaker) | ✅ PASS |
| 3 | Todo código novo com testes; pirâmide; suíte 100% | Unit + integração (Testcontainers/LocalStack) + contrato; JaCoCo | ✅ PASS |
| 4 | DynamoDB on-demand; acesso só via repositório | DynamoDB single-table on-demand para metadados/índice/progresso; SDK só dentro de adapters de repositório | ✅ PASS (ver ADR-001) |
| 5 | Logs estruturados em entrada/saída/falha; toda falha externa logada | Logback JSON; falhas da Claude API e de IO logadas com contexto | ✅ PASS |
| 6 | CI em GitHub Actions; merge exige build verde + testes | Workflow `ci.yml`: build Maven + testes + JaCoCo + LocalStack | ✅ PASS |
| 7 | **Tudo roda localmente (não negociável)**; Terraform; Docker + LocalStack | `./start.sh` sobe Docker Compose (LocalStack + app) e aplica Terraform (tabela). Nada exige nuvem | ✅ PASS (reforça FR-019/FR-021) |
| 8 | ADRs para decisões relevantes; DoD | ADR-001 (persistência híbrida) e ADR-002 (geração via Claude API) registrados | ✅ PASS |
| 9 | Segredos fora do repo; via env | `ANTHROPIC_API_KEY` via variável de ambiente/`.env` (gitignored); nunca commitada | ✅ PASS |
| 10 | LGPD: minimização | Apenas dados de estudo do próprio usuário, locais. Sem PII de terceiros; sem telemetria externa | ✅ PASS |
| 11 | Endpoints com contrato OpenAPI; versionamento; teste de contrato | springdoc gera OpenAPI; prefixo `/api/v1`; testes de contrato por endpoint | ✅ PASS |
| 12 | Configuração externalizada | `application.yml` + env (endpoint LocalStack, caminho de dados, chave da IA); nada hardcoded | ✅ PASS |
| 13 | Colaboração com IA segue tabela de autonomia | Geração assistida é ação explícita do usuário; sem auto-escrita silenciosa na base sem persistência rastreável | ✅ PASS |

**Resultado:** sem violações. Dois pontos exigiram justificativa registrada como ADR (ver
Complexity Tracking) — ambos resolvem tensões demanda × constituição **a favor da constituição**.

## Project Structure

### Documentation (this feature)

```text
specs/001-assistente-estudos-ingles/
├── spec.md
├── plan.md              # este arquivo
├── research.md          # decisões técnicas e alternativas
├── data-model.md        # entidades + modelagem DynamoDB single-table + layout de arquivos
├── quickstart.md        # pré-requisitos + comando único de bootstrap
├── contracts/
│   └── openapi.yaml      # contrato REST /api/v1
├── checklists/
│   └── requirements.md   # quality gate dos requisitos
└── tasks.md             # gerado pelo /speckit-tasks
```

### Source Code (repository root do repo-alvo `english-partner`)

```text
english-partner/
├── pom.xml
├── docker-compose.yml          # LocalStack + app
├── start.sh                    # COMANDO ÚNICO: sobe tudo (compose up + terraform apply)
├── stop.sh                     # COMANDO ÚNICO: derruba tudo
├── .env.example                # ANTHROPIC_API_KEY=...
├── infra/terraform/            # IaC: tabela DynamoDB (aplicada contra LocalStack)
├── src/main/java/com/englishpartner/
│   ├── domain/                 # entidades, value objects, erros de domínio, PORTAS (interfaces)
│   │   ├── unit/  note/  topic/  error/  generated/  progress/
│   │   └── ports/              # ArtifactStore, UnitRepository, SearchIndex, ContentGenerator, PdfTextExtractor
│   ├── application/            # USE CASES (um por intenção de negócio)
│   │   └── usecase/            # CreateUnit, AttachFile, EditNote, RegisterCorrection, GenerateSummary,
│   │                           #   GenerateExercises, GenerateFlashcards, ConsolidateRecurringErrors,
│   │                           #   MarkStatus, GetUnitView, GetProgress, SearchKnowledgeBase, ExportContent
│   ├── infrastructure/         # ADAPTERS
│   │   ├── fs/                 # FileSystemArtifactStore (fonte da verdade)
│   │   ├── dynamo/             # DynamoDbUnitRepository, DynamoDbSearchIndex (single-table)
│   │   ├── pdf/                # PdfBoxTextExtractor
│   │   ├── ai/                 # ClaudeContentGenerator (Resilience4j)
│   │   └── config/             # configuração externalizada
│   └── interface/rest/         # controllers /api/v1, DTOs, OpenAPI, handlers de erro
├── src/test/java/com/englishpartner/
│   ├── unit/                   # domínio + use cases (mock das portas)
│   ├── integration/            # repositórios contra LocalStack (Testcontainers)
│   └── contract/               # contrato dos endpoints REST
└── data/units/                 # árvore de artefatos (FONTE DA VERDADE) — gitignored
```

**Structure Decision**: app único Spring Boot em Clean Architecture. O **domínio** não conhece
Spring, DynamoDB nem HTTP — depende apenas de **portas**. Os **adapters** (fs, dynamo, pdf, ai)
implementam as portas na infraestrutura. A interface REST é uma borda fina sobre os use cases. O
filesystem (`data/units/`) é a fonte da verdade; o DynamoDB é índice/metadados derivados e
reconstruíveis.

## Complexity Tracking

> Pontos onde a régua constitucional impõe complexidade acima do "mínimo ingênuo" de um app pessoal —
> justificados e aceitos (a arquitetura prevalece). Detalhe em `decisoes/`.

| Violação aparente | Por que é necessário | Alternativa simples rejeitada porque |
|---|---|---|
| DynamoDB + LocalStack para um app pessoal (vs. só arquivos/SQLite) | Constituição §4 exige DynamoDB on-demand via repositório; §7 exige LocalStack para rodar local | Só-arquivos quebraria §4; SQLite quebraria §4. Resolvido com **híbrido**: arquivos como fonte da verdade + DynamoDB como índice (ADR-001) |
| Terraform para criar uma tabela local (vs. script aws-cli) | §7 exige IaC com Terraform | Criar a tabela via aws-cli no script quebraria §7; Terraform fica embutido no `start.sh` para manter o comando único |
| Integração externa com Resilience4j para a Claude API | §2/resiliência exigem timeout/retry/circuit breaker em toda integração externa | Chamada HTTP "crua" sem resiliência quebraria a constituição |
