# API Contract: English Partner Backend

**Consumed by**: `english-partner-view` (frontend)
**Base URL**: `${VITE_API_URL}` (default: `http://localhost:8080`)
**API Version**: v1
**Date**: 2026-06-22

O backend já expõe documentação OpenAPI em `http://localhost:8080/swagger-ui`. Este documento registra o subconjunto consumido pelo frontend, com detalhes de error handling relevantes para a implementação da UI.

---

## Convenções

- Todos os bodies JSON usam `Content-Type: application/json`.
- Datas são strings ISO 8601: `"2026-06-21"` (date) ou `"2026-06-21T19:00:00Z"` (datetime).
- Erros retornam o formato Spring Boot:
  ```json
  { "status": 404, "error": "Not Found", "message": "Unit 99 not found", "path": "..." }
  ```
- Upload de arquivos usa `multipart/form-data` (sem `Content-Type` manual — o browser define o boundary).

---

## Units

### `GET /api/v1/units`

Lista todas as units.

**Response 200**:
```json
[
  { "number": 1, "title": "Present Perfect", "date": "2026-06-01", "status": "CONCLUIDA", "observations": null }
]
```

---

### `POST /api/v1/units`

Cria uma nova unit.

**Request body**:
```json
{ "number": 2, "title": "Past Simple", "date": "2026-06-15", "status": "AGENDADA", "observations": "Revisar irregular verbs" }
```

**Response 201**: `UnitResponse`

**Errors**:
- `409 Conflict` — unit com o mesmo número já existe → exibir: "Já existe uma unit com este número."
- `400 Bad Request` — número ausente/inválido ou título vazio → exibir validação do campo.

---

### `GET /api/v1/units/{number}`

Retorna a visão completa de uma unit.

**Response 200**: `UnitViewResponse`

**Errors**:
- `404 Not Found` → exibir: "Unit não encontrada."

---

### `POST /api/v1/units/{number}/attachments` (multipart/form-data)

Faz upload de um PDF.

**Form fields**:
- `type`: `MATERIAL` | `HOMEWORK` | `CORRECTION`
- `file`: arquivo PDF (binary)

**Response 201**: `AttachmentResponse`

**Errors**:
- `404` — unit não encontrada
- `400` — tipo inválido ou arquivo ausente

---

### `PUT /api/v1/units/{number}/correction`

Registra ou atualiza a correção em texto.

**Request body**: `{ "content": "texto da correção..." }`

**Response 200**: sem body.

---

### `PUT /api/v1/units/{number}/notes`

Salva (substitui integralmente) a nota Markdown da unit.

**Request body**: `{ "content": "# Notas\n\nConteúdo em **Markdown**..." }`

**Response 200**: sem body.

> ⚠️ **Limitação conhecida**: Não existe `GET /api/v1/units/{number}/notes`. A `UnitViewResponse` retorna apenas `notesPath` (caminho do arquivo no servidor), não o conteúdo. O editor de notas sempre inicia vazio no frontend; o conteúdo previamente salvo não é pré-carregado.

---

### `PUT /api/v1/units/{number}/topics`

Substitui a lista completa de tópicos da unit.

**Request body**:
```json
[
  { "id": "uuid-existente", "kind": "VOCABULARY", "label": "run out of", "masteryStatus": "DOMINADO" },
  { "id": null, "kind": "GRAMMAR", "label": "present perfect continuous", "masteryStatus": "PRECISO_REFORCAR" }
]
```

**Response 200**: `TopicDto[]` (com IDs gerados para os novos tópicos)

---

### `PUT /api/v1/units/{number}/topics/{topicId}/status`

Atualiza apenas o status de domínio de um tópico individual.

**Request body**: `{ "masteryStatus": "DOMINADO" }`

**Response 200**: `TopicDto` atualizado.

**Errors**:
- `404` — unit ou tópico não encontrado.

---

### `PUT /api/v1/units/{number}/errors`

Registra/atualiza a lista de erros recorrentes de uma unit.

**Request body**:
```json
[
  { "id": null, "label": "confundir 'since' e 'for'", "category": "grammar" }
]
```

**Response 200**: sem body.

---

## Geração de Conteúdo

### `POST /api/v1/units/{number}/generate/summary`
### `POST /api/v1/units/{number}/generate/exercises`
### `POST /api/v1/units/{number}/generate/flashcards`

**Response 200**: `GeneratedRefResponse`
```json
{ "type": "SUMMARY", "path": "data/unit-1/summary.md", "count": 1, "generatedAt": "2026-06-22T10:00:00Z" }
```

**Errors**:
- `422 Unprocessable Entity` — base insuficiente para geração → exibir: "Base insuficiente para geração. Adicione material ou tópicos à unit."
- `503 Service Unavailable` — IA indisponível → exibir: "Serviço de IA temporariamente indisponível. Tente novamente mais tarde."

---

## Exportação

### `GET /api/v1/units/{number}/export?format=md|json|pdf`

**Response 200**: arquivo binário com headers:
- `Content-Disposition: attachment; filename="unit-1-export.md"`
- `Content-Type`: `text/markdown` | `application/json` | `application/pdf`

O frontend deve disparar o download via `URL.createObjectURL(blob)`.

---

## Progresso, Erros e Busca

### `GET /api/v1/progress`

**Response 200**:
```json
[
  { "number": 1, "hasMaterial": true, "hasHomework": true, "hasCorrection": false, "pendingReviewTopics": 3 }
]
```

---

### `GET /api/v1/errors?unit={number}`

`unit` é opcional. Se omitido, retorna todos os erros consolidados.

**Response 200**:
```json
[
  { "id": "uuid", "label": "confundir 'since' e 'for'", "category": "grammar", "occurrences": 3, "sourceUnits": [1, 2] }
]
```

---

### `GET /api/v1/search?q={query}`

**Response 200**:
```json
[
  { "kind": "VOCABULARY", "unitNumber": 1, "snippet": "...run out of time...", "ref": "data/unit-1/..." }
]
```

**Errors**:
- `400` — query vazia ou muito curta (se o backend validar).

---

## Mapa de Erros → Mensagens UI

| Status | Contexto | Mensagem exibida |
|---|---|---|
| 409 | Criar unit | "Já existe uma unit com este número." |
| 404 | Qualquer recurso | "Recurso não encontrado." |
| 422 | Geração de conteúdo | "Base insuficiente para geração. Adicione material ou tópicos à unit." |
| 503 | Geração de conteúdo | "Serviço de IA temporariamente indisponível. Tente novamente." |
| 400 | Formulários | Mensagem do campo `message` retornada pelo backend. |
| 0 / Network | Qualquer | "Não foi possível conectar ao backend. Verifique se o serviço está em execução." |
