# ADR-002: Geração de conteúdo via Claude API (com Resilience4j), não LLM local em v1

- **Demanda (slug):** assistente-estudos-ingles
- **Run ID:** 0C7ED1DD-841A-4047-8D56-E02D2A99AE8C
- **Data (UTC-3):** 2026-06-20
- **Status:** aceita
- **Tipo:** decisão de design / decisão em aberto resolvida

## Contexto

O sistema precisa **gerar** resumos, exercícios e flashcards (FR-011/012/013). A demanda exige que o
**acesso aos arquivos já salvos** não dependa de internet (FR-019), mas não proíbe rede para a
geração em si. Era preciso decidir o motor de geração: serviço de IA em nuvem vs. LLM local offline.

## Decisão

Usar a **Claude API** (Anthropic Java SDK) como motor de geração, modelo default `claude-sonnet-4-6`
(configurável para `claude-opus-4-8`). A chamada é encapsulada por **Resilience4j** (timeout, retry
idempotente com backoff+jitter, circuit breaker), conforme §2/resiliência. A `ANTHROPIC_API_KEY` vem
de variável de ambiente (§9). Acesso/leitura da base salva permanece **100% offline** (FR-019); só a
geração nova requer rede, com erro tratado e aviso quando indisponível.

## Alternativas consideradas

- **LLM local (Ollama)** — geração 100% offline; rejeitada em v1 por maior custo de setup e qualidade
  inferior. **Mantida como decisão em aberto de baixa prioridade** para uma evolução futura (a porta
  `ContentGenerator` permite trocar o adapter sem tocar no domínio).

## Consequências

- Melhor qualidade de geração. Dependência de rede e de uma chave de API **apenas** no momento da
  geração. A arquitetura de portas/adapters isola o motor, permitindo adicionar um adapter Ollama
  depois sem reescrever use cases.

## Se for exceção constitucional

Não é exceção — cumpre §2 (Resilience4j na integração externa), §9 (segredo via env) e §7 (a base
local roda offline; a geração é um recurso externo opcional).
