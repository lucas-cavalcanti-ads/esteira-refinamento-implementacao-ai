# Data Model: English Partner View

**Feature**: `specs/002-criacao-frontend-view`
**Date**: 2026-06-22

Todos os tipos abaixo espelham os DTOs do backend. O frontend não possui modelo de dados próprio — apenas consome e exibe o que a API retorna.

---

## Enums

```typescript
type UnitStatus = 'AGENDADA' | 'REALIZADA' | 'EM_REVISAO' | 'CONCLUIDA';

type AttachmentType = 'MATERIAL' | 'HOMEWORK' | 'CORRECTION';

type ExtractionStatus = 'PENDING' | 'DONE' | 'FAILED';

type TopicKind = 'GRAMMAR' | 'VOCABULARY' | 'EXPRESSION' | 'PRONUNCIATION' | 'ERROR';

type MasteryStatus = 'PRECISO_REFORCAR' | 'REVISADO' | 'DOMINADO';

type GeneratedContentType = 'SUMMARY' | 'EXERCISES' | 'FLASHCARDS';

type SearchHitKind = 'UNIT' | 'NOTE' | 'VOCABULARY' | 'EXERCISE' | 'FLASHCARD' | 'ERROR';
```

---

## Tipos de Resposta (API → Frontend)

```typescript
/** GET /api/v1/units  |  POST /api/v1/units → 201 */
interface UnitResponse {
  number: number;
  title: string;
  date: string;           // ISO 8601: "2026-06-21"
  status: UnitStatus;
  observations: string | null;
}

/** GET /api/v1/units/{number} */
interface UnitViewResponse {
  unit: UnitResponse;
  attachments: AttachmentResponse[];
  notesPath: string | null;   // caminho do arquivo de notas no servidor
  topics: TopicDto[];
  generated: GeneratedRefResponse[];
}

/** Sub-recurso de UnitViewResponse */
interface AttachmentResponse {
  type: AttachmentType;
  path: string;
  extractionStatus: ExtractionStatus;
}

/** Sub-recurso de UnitViewResponse  |  PUT /api/v1/units/{n}/topics → [] */
interface TopicDto {
  id: string;
  kind: TopicKind;
  label: string;
  masteryStatus: MasteryStatus;
}

/** Sub-recurso de UnitViewResponse  |  POST .../generate/* */
interface GeneratedRefResponse {
  type: GeneratedContentType;
  path: string;
  count: number;
  generatedAt: string;  // ISO 8601 timestamp
}

/** GET /api/v1/progress */
interface UnitProgressResponse {
  number: number;
  hasMaterial: boolean;
  hasHomework: boolean;
  hasCorrection: boolean;
  pendingReviewTopics: number;
}

/** GET /api/v1/errors */
interface RecurringErrorResponse {
  id: string;
  label: string;
  category: string;
  occurrences: number;
  sourceUnits: number[];
}

/** GET /api/v1/search */
interface SearchHitResponse {
  kind: SearchHitKind;
  unitNumber: number;
  snippet: string;
  ref: string;
}
```

---

## Tipos de Requisição (Frontend → API)

```typescript
/** POST /api/v1/units */
interface CreateUnitRequest {
  number: number;          // obrigatório, ≥ 1
  title: string;           // obrigatório, não-vazio
  date?: string;           // opcional, ISO 8601
  status?: UnitStatus;     // opcional
  observations?: string;   // opcional
}

/** PUT /api/v1/units/{n}/notes  |  PUT /api/v1/units/{n}/correction */
interface ContentRequest {
  content: string;
}

/** PUT /api/v1/units/{n}/topics — array completo de tópicos da unit */
type TopicsRequest = TopicDto[];   // id pode ser null/undefined para novos tópicos

/** PUT /api/v1/units/{n}/topics/{id}/status */
interface MasteryStatusRequest {
  masteryStatus: MasteryStatus;
}

/** PUT /api/v1/units/{n}/errors — array de erros */
interface RecurringErrorRequest {
  id?: string;
  label: string;     // obrigatório, não-vazio
  category?: string;
}

/** POST /api/v1/units/{n}/attachments — multipart/form-data */
// Não há interface TS; usar FormData:
// formData.append('type', AttachmentType)
// formData.append('file', File)
```

---

## Estado Local da UI (não persistido)

Estes tipos existem apenas na memória do SPA, não são enviados ao backend:

```typescript
/** Estado de uma chamada assíncrona em andamento */
interface LoadingState {
  isLoading: boolean;
  error: string | null;
}

/** Erro normalizado do api client */
interface ApiError {
  status: number;
  message: string;
}
```

---

## Relacionamentos

```
UnitResponse
  └── [via GET /units/{n}] → UnitViewResponse
        ├── attachments: AttachmentResponse[]
        ├── notesPath: string | null          (nota Markdown salva no servidor)
        ├── topics: TopicDto[]
        └── generated: GeneratedRefResponse[]

UnitProgressResponse (por unit, calculado pelo backend)

RecurringErrorResponse (consolidado; sourceUnits[] referencia UnitResponse.number)

SearchHitResponse.unitNumber → UnitResponse.number (navegação)
```
