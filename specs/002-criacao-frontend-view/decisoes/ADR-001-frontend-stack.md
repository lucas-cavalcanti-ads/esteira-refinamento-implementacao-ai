# ADR-001: Stack de Frontend (Vite + TypeScript + Material Web)

**Status**: Aceito
**Date**: 2026-06-22
**Feature**: criacao-frontend-view
**Scope**: por-demanda (não altera a constituição)

---

## Contexto

A constituição (v1.0.0, §2) prescreve Java 21 + Maven + Spring Boot para o backend e Python 3.13 para funções serverless. Não há prescrição para camadas de UI/frontend.

A demanda requer criar uma aplicação frontend local (`english-partner-view`) que consuma a API REST do backend. A interface deve usar a biblioteca Material Web (`@material/web`).

---

## Decisão

O frontend `english-partner-view` será implementado com:

- **Vite 6.x** — bundler e dev server
- **TypeScript 5.x** — linguagem
- **@material/web 2.x** — biblioteca de UI (Material Design 3, Web Components)
- **marked 15.x** — rendering de Markdown
- **Vitest** — testes unitários
- **@playwright/test** — smoke tests e2e

Sem framework JS (vanilla TypeScript); sem biblioteca de state management.

---

## Justificativa

1. **§2 da constituição é backend-centric**: as prescrições de Java/Spring/Python se aplicam ao backend e a funções serverless, respectivamente. A constituição não prescreve nem veda stacks para a camada de UI.

2. **Princípio §7 (local-first) é mantido**: Vite dev server roda inteiramente local; nenhuma funcionalidade depende de serviços externos.

3. **Princípios §9 e §12 são mantidos**: `VITE_API_URL` externalizada em `.env.local`; sem segredos no código.

4. **Princípio §3 é mantido**: Vitest cobre a lógica do api client; Playwright cobre os fluxos principais.

5. **Material Web é requisito explícito** do usuário, não uma escolha arquitetural opcional.

---

## Consequências

- Esta exceção aplica-se **somente** ao projeto `english-partner-view`.
- Qualquer outro projeto backend ou serverless continua sujeito às prescrições de §2.
- Se um segundo projeto frontend for criado no futuro, este ADR serve de precedente e pode ser promovido a princípio constitucional via PR ao `arquitetura-referencia`.

---

## Alternativas consideradas

| Alternativa | Razão da rejeição |
|---|---|
| Backend Java servindo HTML estático (Thymeleaf) | Misturaria responsabilidades; complicaria o bootstrap |
| React + Material UI | Over-engineering para SPA single-user; peer dependency desnecessária |
| Swagger UI exclusivo (sem frontend dedicado) | Já foi a decisão da v1 do backend; esta demanda supera essa limitação |
