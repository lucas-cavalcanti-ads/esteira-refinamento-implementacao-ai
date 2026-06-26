---
name: exemplo-endpoint
description: MODELO/EXEMPLO de skill. Demonstra o formato de uma skill de implementação. Substitua o conteúdo pelos padrões reais da sua arquitetura de referência (este texto é placeholder).
---

# Skill (EXEMPLO): Como adicionar um endpoint

> ⚠️ Este é um **molde de demonstração**. O conteúdo abaixo é genérico e ilustrativo. Reescreva-o
> com as convenções reais da sua `arquitetura-referencia` (ou apague esta skill).

Use esta skill quando uma tarefa pedir a criação de um novo endpoint na API.

## Passos

1. Respeite o fluxo de camadas da constituição (ex: controller → service → repository). O controller
   não acessa o repository diretamente.
2. Defina o contrato (ex: OpenAPI) antes da implementação.
3. Valide toda entrada externa antes de chegar ao service.
4. Implemente a regra de negócio no service; acesso a dados sempre via repository.
5. Escreva o teste de integração do endpoint cobrindo o critério de aceite correspondente.
6. Atualize a documentação do contrato.

## Checklist de conformidade

- [ ] Camadas respeitadas (sem atalho controller→repository).
- [ ] Entrada validada explicitamente.
- [ ] Contrato exposto e documentado.
- [ ] Teste de integração cobrindo o critério de aceite.

> Substitua os itens acima pelas regras verdadeiras da sua arquitetura. Quanto mais a skill espelhar
> a constituição, mais a implementação sai conforme "de primeira".
