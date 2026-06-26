# Research: English Partner View

**Feature**: `specs/002-criacao-frontend-view`
**Date**: 2026-06-22

---

## Decisão 1: Build tool e runtime

**Decision**: Vite 6.x como bundler e dev server.

**Rationale**: Vite oferece HMR (Hot Module Replacement) extremamente rápido, suporte nativo a TypeScript e ESM, e configuração mínima para um SPA local. É a escolha padrão da comunidade para projetos frontend modernos sem framework opinionado.

**Alternatives considered**:
- esbuild puro: mais rápido para build, mas sem dev server nem HMR out-of-the-box.
- Webpack: maduro, mas configuração verbosa e muito mais pesada para um projeto local simples.
- Parcel: zero-config, mas menor controle sobre a estrutura de build.

---

## Decisão 2: Linguagem — TypeScript vs JavaScript

**Decision**: TypeScript 5.x.

**Rationale**: Os DTOs do backend têm tipagem precisa (records Java com campos bem definidos). Espehar essas types em TypeScript previne erros de runtime (campo `null` não tratado, typos em nomes de campos) sem custo de setup adicional — Vite já suporta TS nativamente. Para um projeto que vai crescer com mais telas e chamadas de API, TS paga o custo imediatamente.

**Alternatives considered**:
- Vanilla JS: sem custo de compilação, mas perde autocomplete e type safety nos contratos de API.
- JSDoc tipado: meio-termo, mas verbose e sem o ecosistema de ferramentas TS.

---

## Decisão 3: UI library — Material Web (@material/web)

**Decision**: `@material/web` 2.x (Web Components nativos do Google, Material Design 3).

**Rationale**: Requisito explícito do usuário. Material Web é a implementação oficial de Material Design 3 em Web Components puros, compatível com qualquer framework (ou sem framework). Instalação via npm, tree-shakeable, funciona com Vite sem adaptadores.

**Alternatives considered**:
- MUI (React): requer React como peer dependency.
- Shoelace: excelente, mas não é Material Design.
- CDN import: funciona, mas impede tree-shaking e versioning.

---

## Decisão 4: Roteamento — hash-based vs history API

**Decision**: Hash-based routing (`#/units`, `#/units/1`, etc.) implementado manualmente (~50 linhas).

**Rationale**: O hash routing não requer nenhuma configuração de servidor — o Vite dev server serve `index.html` para qualquer rota por padrão, mas evitar dependência de rewrite rules simplifica o setup. Para um SPA local com ≤6 telas e single-user, um router minimalista customizado é suficiente e elimina uma dependência externa.

**Alternatives considered**:
- History API com `vite.config` `historyApiFallback`: funciona em dev, mas precisaria de configuração adicional em outros contextos.
- TanStack Router / React Router: requerem React ou são over-engineering para este escopo.

---

## Decisão 5: Markdown — rendering da nota da unit

**Decision**: `marked` 15.x para rendering de Markdown para HTML.

**Rationale**: `marked` é pequeno (~25kb), rápido, sem dependências e amplamente usado. Para a nota da unit (bloco único editável), o fluxo é: `<textarea>` para edição → `marked.parse(content)` para preview. Sem need de editor WYSIWYG.

**Alternatives considered**:
- `markdown-it`: mais features e plugins, mas mais pesado para o caso de uso simples.
- `showdown`: menos mantido ativamente.
- Editor rico (CodeMirror, Monaco): over-engineering; um textarea + preview é suficiente para anotações de estudo.

---

## Decisão 6: HTTP client

**Decision**: `fetch` nativo com wrapper customizado em `api/client.ts`.

**Rationale**: `fetch` está disponível em todos os navegadores modernos sem instalação. O wrapper customizado adiciona: tratamento unificado de erros (lança `ApiError` com `status` e `message`), headers padrão (`Content-Type: application/json`), e extração de mensagem de erro do body JSON do backend Spring Boot.

**Alternatives considered**:
- `axios`: matura e ergonômica, mas adiciona ~15kb de bundle sem benefício real para este escopo.
- `ky`: wrapper leve sobre fetch, mas dependência extra desnecessária.

---

## Decisão 7: Testes

**Decision**: `vitest` para unitários; `@playwright/test` para smoke tests e2e.

**Rationale**: Vitest tem integração nativa com Vite (configuração zero), API compatível com Jest, e execução extremamente rápida. Playwright é o padrão para e2e em aplicações web locais. Foco nos testes: (a) api/client.ts — lógica de error handling; (b) router.ts — lógica de parsing de hash; (c) e2e smoke — create unit + list.

**Alternatives considered**:
- Jest: requer configuração adicional para ESM/Vite.
- Cypress: alternativa válida para e2e, mas Playwright tem melhor suporte a múltiplos navegadores.

---

## Decisão 8: Bootstrap scripts

**Decision**: `start.sh` e `stop.sh` no diretório raiz `english-partner/`, não rastreados em git (decisão D2 do usuário).

**Rationale**:
- `start.sh`: chama o start.sh do backend (que já gerencia Docker + LocalStack + Terraform + health check), aguarda o health do backend em `http://localhost:8080/actuator/health`, então inicia `vite dev` via npm em background no diretório `english-partner-view/`.
- `stop.sh`: mata o processo Vite (via PID file ou pkill), então chama o stop.sh do backend.

**Detalhes do health check**: loop de 60 tentativas com sleep de 3s (máximo 3 minutos), mesma abordagem do backend.

**Frontend URL**: `http://localhost:5173` (porta padrão do Vite).

---

## Contratos da API (levantados dos DTOs do backend)

Todos os endpoints estão em `http://localhost:8080` (configurável via `VITE_API_URL`).

### Units
| Método | Path | Request | Response |
|---|---|---|---|
| GET | `/api/v1/units` | — | `UnitResponse[]` |
| POST | `/api/v1/units` | `CreateUnitRequest` | `UnitResponse` (201) |
| GET | `/api/v1/units/{n}` | — | `UnitViewResponse` |
| POST | `/api/v1/units/{n}/attachments` | `multipart: type, file` | `AttachmentResponse` (201) |
| PUT | `/api/v1/units/{n}/correction` | `ContentRequest` | 200 |
| PUT | `/api/v1/units/{n}/notes` | `ContentRequest` | 200 |
| PUT | `/api/v1/units/{n}/topics` | `TopicDto[]` | `TopicDto[]` |
| PUT | `/api/v1/units/{n}/topics/{id}/status` | `MasteryStatusRequest` | `TopicDto` |
| PUT | `/api/v1/units/{n}/errors` | `RecurringErrorRequest[]` | 200 |

### Geração e export
| Método | Path | Request | Response |
|---|---|---|---|
| POST | `/api/v1/units/{n}/generate/summary` | — | `GeneratedRefResponse` |
| POST | `/api/v1/units/{n}/generate/exercises` | — | `GeneratedRefResponse` |
| POST | `/api/v1/units/{n}/generate/flashcards` | — | `GeneratedRefResponse` |
| GET | `/api/v1/units/{n}/export?format=md\|json\|pdf` | — | file download |

### Progresso, erros, busca
| Método | Path | Request | Response |
|---|---|---|---|
| GET | `/api/v1/progress` | — | `UnitProgressResponse[]` |
| GET | `/api/v1/errors?unit={n}` | — | `RecurringErrorResponse[]` |
| GET | `/api/v1/search?q={query}` | — | `SearchHitResponse[]` |

### Tratamento de erros do backend
O Spring Boot retorna erros no formato:
```json
{ "timestamp": "...", "status": 404, "error": "Not Found", "message": "Unit 99 not found", "path": "/api/v1/units/99" }
```
O api client extrai `message` para exibir ao usuário.
