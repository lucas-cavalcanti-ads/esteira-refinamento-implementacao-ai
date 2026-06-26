# Implementation Plan: English Partner View — Frontend de Estudos

**Branch**: `claude-criacao-frontend-view` | **Date**: 2026-06-22 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/002-criacao-frontend-view/spec.md`

---

## Summary

Criar a aplicação frontend `english-partner-view` que consome a API REST do backend `english-partner-backend`. SPA com roteamento hash, construída com Vite + TypeScript + Material Web (@material/web), cobrindo todas as telas de gestão de units, geração de conteúdo, progresso e busca. Também reorganizar os scripts de bootstrap (`start.sh` / `stop.sh`) para o diretório raiz `english-partner/`.

---

## Technical Context

**Language/Version**: TypeScript 5.x (frontend) + Bash (scripts)

**Primary Dependencies**:
- `vite` 6.x — bundler e dev server local
- `@material/web` 2.x — componentes Material Design 3
- `marked` 15.x — rendering de Markdown para a nota da unit
- Sem framework JS (vanilla TS); sem biblioteca de state management

**Storage**: N/A — dados persistidos exclusivamente pelo backend via API REST

**Testing**:
- `vitest` — testes unitários (api client, utilitários)
- `@playwright/test` — smoke tests e2e opcionais (local only)

**Target Platform**: Navegador moderno local (Chrome/Firefox), acessado via `http://localhost:5173`

**Project Type**: SPA (Single Page Application) — frontend local, sem SSR, sem build para produção em nuvem

**Performance Goals**: resposta visual em ≤200ms para operações locais; indicador de carregamento para chamadas à API

**Constraints**: offline-first não é requisito; requer backend saudável para funcionar; sem autenticação; Node.js necessário para Vite

**Scale/Scope**: single-user local; ≤50 units; sem paginação necessária

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Seção da Constituição | Veredicto | Justificativa |
|---|---|---|
| §1 Clean Architecture | EXCEÇÃO (ADR-001) | Frontend é camada de apresentação pura; não há domínio nem casos de uso. |
| §2 Stacks (Java 21/Spring) | EXCEÇÃO (ADR-001) | Projeto frontend — Vite + TypeScript é o stack adequado. §2 prescreve backend. |
| §3 Qualidade e Testes | APLICA | Vitest (unitário) + Playwright (e2e smoke). Gate: suíte passa 100%. |
| §4 DynamoDB | N/A | Frontend não acessa banco. |
| §5 Observabilidade | PARCIAL | Console.error estruturado nos error boundaries; sem tracing distribuído (local). |
| §6 CI/CD | APLICA | Pipeline GitHub Actions: lint, test, build. |
| §7 Local-first | CONFORME | Vite dev server local; tudo roda sem internet. |
| §8 Governança | APLICA | ADR-001 documenta exceções de stack. |
| §9 Segurança | CONFORME | `VITE_API_URL` via `.env.local`; sem segredos no código. |
| §10 LGPD | CONFORME | Dados locais; nenhuma informação trafega externamente. |
| §11 APIs/OpenAPI | N/A | Frontend é consumidor; backend já expõe OpenAPI. |
| §12 Configuração | CONFORME | URL do backend externalizada via variável de ambiente. |
| §13 Colaboração IA | PADRÃO | — |

---

## Project Structure

### Documentation (this feature)

```text
specs/002-criacao-frontend-view/
├── plan.md            # Este arquivo
├── research.md        # Decisões técnicas e alternativas
├── data-model.md      # Tipos TypeScript (espelham os DTOs do backend)
├── quickstart.md      # Guia de validação end-to-end
├── contracts/
│   └── api-contract.md  # Contrato da API REST consumida
├── checklists/
│   ├── requirements.md  # Checklist de qualidade dos requisitos
│   └── feature.md       # Checklist feature (55 itens)
├── decisoes/
│   └── ADR-001-frontend-stack.md
└── tasks.md           # Gerado por /speckit-tasks
```

### Source Code (english-partner-view/)

```text
english-partner-view/
├── package.json
├── vite.config.ts
├── tsconfig.json
├── index.html
├── .env.example        # VITE_API_URL=http://localhost:8080
├── src/
│   ├── main.ts
│   ├── router.ts       # Hash-based SPA router (~50 linhas)
│   ├── types.ts        # Interfaces TypeScript (DTOs)
│   ├── api/
│   │   ├── client.ts   # fetch wrapper com error handling
│   │   ├── units.ts    # endpoints de units
│   │   ├── knowledge.ts # endpoints de progresso/erros/busca
│   │   └── generation.ts # endpoints de geração/export
│   ├── pages/
│   │   ├── dashboard.ts
│   │   ├── units-list.ts
│   │   ├── unit-detail.ts
│   │   ├── progress.ts
│   │   ├── errors.ts
│   │   └── search.ts
│   ├── components/
│   │   ├── app-shell.ts    # nav drawer + main layout
│   │   ├── loading.ts      # md-circular-progress
│   │   └── error-banner.ts # md-banner de erros
│   └── styles/
│       └── main.css
└── test/
    ├── unit/
    │   └── api-client.test.ts
    └── e2e/
        └── smoke.spec.ts

# Scripts no diretório raiz (NÃO rastreados em git — decisão D2)
english-partner/
├── start.sh   # Bootstrap: backend → health check → frontend
└── stop.sh    # Teardown: frontend → backend
```

**Structure Decision**: SPA com hash routing (`#/units`, `#/units/1`, etc.) para funcionar sem configuração de servidor. Sem framework JS para manter a build leve e o projeto simples. Material Web via npm (tree-shakeable).

---

## Complexity Tracking

| Exceção/Decisão | Por que necessária | Alternativa rejeitada |
|---|---|---|
| TypeScript em vez de Java | Frontend é camada de UI; Java/Spring não se aplica a SPA local | React + Java = overhead desnecessário para uso single-user |
| Sem state management (Zustand/Redux) | Escopo single-user + fetch-on-navigate elimina necessidade | Adicionaria complexidade sem benefício para ≤50 units |
| Hash routing em vez de history API | Funciona com Vite dev server sem configuração de fallback | history API requer servidor com rewrite rules |
| Scripts fora do git | Decisão D2 do usuário (Etapa 1) | Rastrear no frontend-view repo (rejeitado pelo usuário) |
