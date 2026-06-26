# Data Model — Assistente de Estudos de Inglês

Dois planos de dados: (A) **layout de arquivos** (fonte da verdade) e (B) **DynamoDB single-table**
(metadados/índice/progresso, derivado). Acesso ao Dynamo **só via repositório** (§4).

## A. Layout de arquivos (fonte da verdade — FR-007/SC-007)

```text
data/
└── units/
    └── unit-01/
        ├── unit.json          # metadados da unit (espelho legível; Dynamo é o índice)
        ├── material.pdf        # anexo: material principal
        ├── homework.pdf        # anexo: homework preenchido
        ├── correction.pdf      # anexo OU correction.md (correção registrada)
        ├── notes.md            # anotações livres editáveis
        ├── topics.json         # temas registrados/extraídos + status de domínio
        ├── summary.md          # resumo de revisão gerado
        ├── exercises.md        # exercícios gerados (≥5)
        ├── flashcards.json     # flashcards gerados (≥10)
        └── errors.json         # erros recorrentes desta unit
data/knowledge/
    └── recurring-errors.json   # visão consolidada de erros recorrentes (todas as units)
```

Regra: o sistema sempre pode **reconstruir o índice DynamoDB** lendo `data/`. Edições manuais nos
arquivos são reconciliadas na inicialização.

## B. Entidades de domínio

### Unit
- `number` (int, único, ≥1) — identidade
- `title` (string, obrigatório)
- `date` (date)
- `status` (enum: `EM_ANDAMENTO`, `CONCLUIDA`)
- `observations` (string)
- Invariante: `number` único; criar unit cria a pasta `units/unit-NN/`.

### Attachment
- `unitNumber`, `type` (enum: `MATERIAL`, `HOMEWORK`, `CORRECTION`), `path`, `addedAt`
- `extractionStatus` (enum: `EXTRACTED`, `NO_TEXT`, `PENDING`)

### Note
- `unitNumber`, `content` (markdown), `updatedAt`

### Topic
- `id`, `unitNumber`, `kind` (enum: `GRAMMAR`, `VOCABULARY`, `EXPRESSION`, `PRONUNCIATION`,
  `RECURRING_ERROR`), `label`, `masteryStatus` (enum: `REVISADO`, `PRECISO_REFORCAR`, `DOMINADO`)

### GeneratedContent
- `id`, `unitNumber`, `type` (enum: `SUMMARY`, `EXERCISES`, `FLASHCARDS`), `path`, `generatedAt`
- `provenance` (lista de fontes usadas: anexos/notas/erros)

### RecurringError
- `id`, `label`, `sourceUnits` (lista), `occurrences` (int), `category` (gramática/vocabulário/etc.)

### Progress (derivado)
- por unit: `hasMaterial`, `hasHomework`, `hasCorrection`, `pendingReviewTopics`, `masterySummary`

## C. DynamoDB single-table (`english_partner`, on-demand)

| Item | PK | SK | Atributos principais |
|---|---|---|---|
| Unit meta | `UNIT#01` | `META` | title, date, status, observations |
| Attachment | `UNIT#01` | `ATT#MATERIAL` | path, extractionStatus, addedAt |
| Note | `UNIT#01` | `NOTE` | updatedAt (conteúdo no arquivo) |
| Topic | `UNIT#01` | `TOPIC#<id>` | kind, label, masteryStatus |
| Generated | `UNIT#01` | `GEN#SUMMARY` / `GEN#EXERCISES` / `GEN#FLASHCARDS` | path, generatedAt, provenance |
| Recurring error | `ERROR#<id>` | `META` | label, occurrences, sourceUnits, category |
| Search token | `TERM#<token>` | `REF#<tipo>#<id>` | snippet, unitNumber |

- **Padrões de acesso**: (1) `Query PK=UNIT#NN` → tudo da unit; (2) `Query PK=TERM#token` → busca por
  palavra-chave; (3) `Query begins_with(PK,'ERROR#')` ou item agregado → erros recorrentes.
- **On-demand** (§4). Nenhum acesso ao SDK fora dos adapters `infrastructure/dynamo`.

## D. Mapa requisito → dado

| FR | Onde |
|---|---|
| FR-001/002 | Unit meta + criação de pasta |
| FR-003 | Attachment (3 tipos) + arquivos |
| FR-004 | Note (`notes.md`) |
| FR-005 | Topic (`topics.json`) |
| FR-006/008/010 | persistência automática nos dois planos |
| FR-011/012/013 | GeneratedContent (`summary.md`/`exercises.md`/`flashcards.json`) |
| FR-014 | RecurringError (`errors.json` + `recurring-errors.json`) |
| FR-015 | Topic.masteryStatus / Unit.status |
| FR-016/017 | Progress (derivado) + Query UNIT#NN |
| FR-018 | Search token items |
| FR-019 | leitura via filesystem sempre offline |
| FR-020 | export Markdown/JSON/PDF dos GeneratedContent |
