# Quickstart — Assistente Local de Estudos de Inglês

## Pré-requisitos (instalar uma vez)

- **JDK 21** (Temurin via SDKMAN) — apenas se for rodar o app fora do container
- **Docker** + **Docker Compose**
- **Terraform**
- (Opcional, p/ geração com IA) uma `ANTHROPIC_API_KEY`

## Configuração

```bash
cp .env.example .env
# edite .env e preencha ANTHROPIC_API_KEY se for usar a geração assistida
# (sem a chave, todo o resto — cadastro, anexos, anotações, busca, leitura — funciona offline)
```

## Subir TUDO com um único comando (FR-021)

```bash
./start.sh
```

`start.sh` faz, em sequência:
1. `docker compose up -d` → sobe **LocalStack** (emula DynamoDB) e o **app** Spring Boot.
2. `terraform -chdir=infra/terraform init && terraform -chdir=infra/terraform apply -auto-approve`
   → cria a tabela `english_partner` no LocalStack.
3. Aguarda o health do app e imprime a URL da **Swagger UI** (`http://localhost:8080/swagger-ui`).

## Usar

- Abra a Swagger UI e use os endpoints `/api/v1/...` (criar unit, anexar PDF, anotar, gerar, buscar).
- Os arquivos ficam em `data/units/unit-NN/` — abra-os direto no Finder/editor quando quiser.

## Encerrar com um único comando

```bash
./stop.sh      # docker compose down; preserva data/
```

## Offline

Com a rede desligada: `./start.sh` sobe LocalStack + app localmente e você consegue listar units e
ler todos os artefatos salvos. Apenas a **geração nova** (resumo/exercícios/flashcards) precisa de
rede para falar com a Claude API.

## Rodar os testes

```bash
./mvnw test          # unit + integração (Testcontainers sobe LocalStack efêmero) + contrato
```
