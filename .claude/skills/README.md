# Acervo de Skills

Skills são o lugar onde mora **"como fazer X na minha arquitetura"**. Elas tornam a implementação
ao mesmo tempo mais AI-driven e mais consistente: o `implementer` consulta a skill aplicável antes
de escrever código de um tipo coberto.

## Formato

Cada skill é uma pasta com um `SKILL.md` (frontmatter `name` + `description`, depois o procedimento).
O Claude Code carrega a skill quando ela é relevante para a tarefa.

```
.claude/skills/
  exemplo-endpoint/
    SKILL.md          # exemplo/modelo — substitua pelo conteúdo da sua arquitetura
  <sua-skill>/
    SKILL.md
```

## Skills locais vs compartilhadas

- **Locais**: ficam aqui, versionadas junto do harness.
- **Compartilhadas** (opcional): um repositório externo de skills/agents reutilizáveis entre vários
  harnesses. Configure `skills_compartilhadas.url` em `harness.config.json` e o `scripts/setup.sh`
  as puxa para cá no início. Comece local; migre para submodule/repo compartilhado quando tiver
  muitos projetos.

## Padrão "começa restrito, promove se merecer"

Uma skill pode nascer específica de uma demanda e, se provar que vale, ser promovida ao acervo
compartilhado — mesmo princípio que usamos para os adendos da constituição.

> A skill `exemplo-endpoint/` é só um molde demonstrando o formato. Edite-a (ou remova) e crie as
> skills reais da sua arquitetura de referência.
