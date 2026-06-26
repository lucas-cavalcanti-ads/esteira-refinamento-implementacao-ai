# Checklist de Qualidade dos Requisitos — `assistente-estudos-ingles`

Portão antes do plan/tasks. Marcado após escrever spec + plan.

## Completude
- [x] Todos os requisitos da demanda têm FR correspondente (FR-001..FR-021)
- [x] Todos os critérios de aceite têm cobertura em Acceptance Scenarios e/ou Success Criteria
- [x] Requisito extra (bootstrap de comando único) capturado (FR-021, US4, SC-008)
- [x] Entidades-chave identificadas (Unit, Attachment, Note, Topic, GeneratedContent, RecurringError, Progress)

## Testabilidade
- [x] Cada User Story tem Independent Test
- [x] Success Criteria são mensuráveis (≥5, ≥10, zero perda, offline, 1 comando)
- [x] Acceptance Scenarios em formato Given/When/Then

## Clareza / ambiguidade
- [x] Sem `[NEEDS CLARIFICATION]` pendente bloqueante na spec
- [x] Edge cases enumerados (PDF sem texto, IA offline, base insuficiente, unit duplicada)
- [x] Decisões D1–D4 + bootstrap resolvidas e refletidas na spec/plano
- [ ] **Decisão em aberto (não bloqueante)**: UI web mínima vs. apenas Swagger UI em v1 (R5) → levada ao gate
- [ ] **Decisão em aberto (baixa prioridade)**: motor de IA local (Ollama) como alternativa offline à Claude API (R4)

## Conformidade constitucional
- [x] Constitution Check preenchido no plan (13 regras) sem violações
- [x] Tensões demanda × constituição resolvidas a favor da constituição, com ADR (ADR-001, ADR-002)
- [x] Segredos via env (§9); persistência via repositório (§4); Resilience4j em integração externa (§2)

## Escopo
- [x] MVP identificável (US1 + US4 = base local utilizável e operável por 1 comando)
- [x] Fora de escopo explícito: OCR de PDF só-imagem, SPA web dedicada, multiusuário
