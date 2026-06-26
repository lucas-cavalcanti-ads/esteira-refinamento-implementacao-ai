# Research & Decisões Técnicas — Assistente de Estudos de Inglês

Constituição v1.0.0 · SHA `57a3cd1`. Cada decisão referencia a regra que a governa.

## R1 — Persistência híbrida (filesystem fonte da verdade + DynamoDB índice)

- **Decisão**: artefatos (PDFs, `.md`, `.json`) vivem em `data/units/unit-NN/` (fonte da verdade);
  DynamoDB single-table on-demand guarda metadados de unit, índice de busca e progresso. O índice é
  derivado e reconstruível a partir do disco.
- **Por quê**: concilia o critério de aceite "estrutura legível, acessível manualmente fora do
  sistema" (SC-007/FR-007) com a constituição §4 (DynamoDB via repositório). Ver **ADR-001**.
- **Alternativas rejeitadas**: só-arquivos (fere §4); só-DynamoDB com export (fere SC-007/FR-007).

## R2 — Modelagem DynamoDB single-table

- **Decisão**: tabela única `english_partner` on-demand. `PK = UNIT#<num>`; `SK` discrimina o item
  (`META`, `NOTE`, `TOPIC#<id>`, `GEN#<tipo>#<id>`, `ERROR#<id>`). Itens de índice de busca:
  `PK = TERM#<token>`, `SK = REF#<tipo>#<id>` para busca por palavra-chave. Acesso só via repositório
  (§4).
- **Por quê**: padrões de acesso são "tudo de uma unit" e "buscar por termo". Single-table atende
  ambos sem scan caro.

## R3 — Extração de PDF: Apache PDFBox

- **Decisão**: PDFBox extrai texto dos PDFs anexados para alimentar índice/geração. PDF original
  permanece intacto no disco.
- **Por quê**: lib Java madura, offline, sem serviço externo (alinha §7). OCR de PDF só-imagem fica
  **fora do escopo v1** (Assumption da spec); anexo é preservado e marcado como "sem texto extraído".

## R4 — Geração via Claude API (integração externa resiliente)

- **Decisão**: usar a **Claude API** (Anthropic Java SDK) para resumo/exercícios/flashcards. Modelo
  default `claude-sonnet-4-6` (bom custo/qualidade); configurável para `claude-opus-4-8`. Chamada
  encapsulada por **Resilience4j**: timeout ~5s (configurável p/ geração mais longa), retry com
  backoff+jitter **apenas idempotente**, circuit breaker 50%/10s. `ANTHROPIC_API_KEY` via env (§9).
- **Por quê**: melhor qualidade de geração; integração externa exige resiliência (§2). Ver **ADR-002**.
- **Offline (FR-019)**: só a *geração nova* depende de rede; abrir/listar/ler a base salva é 100%
  offline. Falha de rede → erro tratado com aviso, sem derrubar leitura da base.
- **Alternativa registrada (aberta, baixa prioridade)**: motor LLM local (Ollama) para geração 100%
  offline — maior custo de setup e menor qualidade; não adotado em v1.

## R5 — Interface de entrega: REST + OpenAPI via Swagger UI (sem SPA em v1)

- **Decisão**: a interface v1 é a **API REST** (`/api/v1`) documentada por OpenAPI (springdoc),
  operável via **Swagger UI** local. Um frontend web dedicado fica **fora do escopo v1**.
- **Por quê**: satisfaz §11 (OpenAPI + teste de contrato) e §2 (Spring Boot quando há REST) e mantém
  o escopo honesto. **Decisão em aberto** levada ao gate: incluir ou não uma UI web mínima.

## R6 — Single-command bootstrap (FR-021)

- **Decisão**: `./start.sh` executa `docker compose up -d` (LocalStack + app) e `terraform apply` (cria
  a tabela no LocalStack); `./stop.sh` derruba tudo preservando `data/`. Pré-requisitos (Docker,
  Terraform, JDK 21) documentados no quickstart.
- **Por quê**: atende FR-021 sem violar §7 (Docker+LocalStack+Terraform). O usuário roda um comando.

## R7 — Testes com LocalStack

- **Decisão**: testes de integração de repositório usam **Testcontainers** subindo LocalStack
  efêmero; testes de contrato validam os endpoints contra o OpenAPI; unitários cobrem domínio/use
  cases com portas mockadas.
- **Por quê**: §3 (pirâmide, suíte verde) + §7 (rodar local).
