# CONSTITUTION.template.md

> **Como usar:** copie este arquivo para a raiz do repositório `arquitetura-referencia` como
> `CONSTITUTION.md`, preencha as regras com a SUA arquitetura, e commite. A esteira passa a buscá-lo
> automaticamente. Esta é a pedra angular: conformidade e quase todas as notas medem contra ela.
>
> **Importante:** mantenha o marcador `<!-- arquitetura_version: X.Y.Z -->` na PRIMEIRA linha do
> arquivo final. A esteira lê esse marcador em run-time para carimbar cada nota com a versão da
> arquitetura. Sem ele, a versão não é capturada.

<!-- COPIE A LINHA ABAIXO PARA O TOPO DO CONSTITUTION.md FINAL (e atualize o número a cada bump): -->
<!-- arquitetura_version: 1.0.0 -->

## Princípios de redação (leia antes de escrever)

- **Prescritivo, não descritivo.** Escreva imperativos verificáveis, não descrições de código.
  - ✅ "Controller NUNCA acessa repository diretamente."
  - ❌ "Geralmente usamos uma arquitetura em camadas."
- **Cada regra é checável.** Um revisor (humano ou agent) consegue dizer PASS/FAIL olhando o código.
- **Finito e enxuto.** Poucas regras fortes valem mais que muitas regras vagas.
- **Versione.** Todo bump muda a régua; registre no histórico abaixo e atualize o marcador no topo.
  A esteira carimba a versão semântica + o SHA do commit em cada run para manter as notas
  comparáveis.

---

## Versão

- **Versão:** 1.0.0
- **Última atualização:** AAAA-MM-DD
- **Resumo da mudança:** versão inicial.

---

## 1. Princípios gerais

- _Ex: Segurança em primeiro lugar — toda entrada externa é validada antes de processada._
- _Ex: Todo código novo é coberto por testes automatizados._
- _(substitua pelos seus)_

## 2. Arquitetura e camadas

- _Ex: Fluxo de camadas: controller → service → repository. Controller não acessa repository direto._
- _Ex: Comunicação entre domínios é via mensageria; chamada síncrona direta entre domínios é proibida._
- _(substitua pelos seus)_

## 3. Dados e persistência

- _Ex: Acesso a dados sempre via repository. SQL inline em service é proibido._
- _Ex: Migrações de schema são versionadas e reversíveis._
- _(substitua pelos seus)_

## 4. Contratos e APIs

- _Ex: Todo endpoint expõe contrato OpenAPI e tem teste de integração._
- _Ex: Mudança de contrato público exige versionamento._
- _(substitua pelos seus)_

## 5. Qualidade, testes e observabilidade

- _Ex: Cobertura mínima de X% nos módulos de negócio._
- _Ex: Todo ponto de falha externo tem timeout e tratamento de erro explícito._
- _Ex: Logs estruturados em pontos de entrada e falha._
- _(substitua pelos seus)_

## 6. Segurança

- _Ex: Segredos nunca em código; sempre via cofre/variáveis de ambiente._
- _(substitua pelos seus)_

---

## Exceções concedidas (registro)

Exceções a estas regras concedidas a demandas específicas são registradas como ADRs no repositório
`refinamentos-gen-ai` (`<slug>/decisoes/`). Uma exceção vale só para a demanda que a recebeu; ela
**não** altera esta constituição. Para mudar uma regra de forma durável, edite este arquivo via PR
(e suba a versão).

## Histórico de versões

| Versão | Data | Mudança |
|---|---|---|
| 1.0.0 | AAAA-MM-DD | Versão inicial. |
