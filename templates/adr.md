# ADR-{NNN}: {título curto da decisão}

> Architecture Decision Record. Registra decisões relevantes e exceções constitucionais concedidas
> a esta demanda. Vai para `refinamentos-gen-ai/<slug>/decisoes/`. É a memória organizacional: runs
> futuras leem os ADRs para entender o porquê de decisões passadas.

- **Demanda (slug):** {slug}
- **Run ID:** {run_id}
- **Data (UTC-3):** {aaaa-mm-dd hh:mm:ss}
- **Status:** {proposta | aceita | substituída por ADR-XXX}
- **Tipo:** {decisão de design | decisão em aberto resolvida | exceção constitucional}

## Contexto

{Qual o problema/ambiguidade? Por que uma decisão era necessária?}

## Decisão

{O que foi decidido.}

## Alternativas consideradas

- {alternativa A — por que não}
- {alternativa B — por que não}

## Consequências

{Impacto da decisão. Trade-offs aceitos.}

## Se for exceção constitucional

- **Regra da constituição afetada:** {citar a regra}
- **Versão da arquitetura:** {arquitetura_version} · **SHA:** {constitution_sha}
- **Escopo:** vale **apenas** para esta demanda; não altera a constituição.
- **Justificativa da exceção:** {por que a arquitetura de referência foi excepcionada aqui}
- **Aprovada por:** {usuário}
