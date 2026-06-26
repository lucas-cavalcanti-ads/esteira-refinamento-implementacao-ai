# Feature Specification: English Partner View — Interface de Estudos

**Feature Branch**: `claude-criacao-frontend-view`

**Created**: 2026-06-21

**Status**: Draft

**Input**: Criar a aplicação frontend english-partner-view (Vite + vanilla JS + Material Web) que consome a API REST do backend english-partner-backend local. A interface deve cobrir: listagem e criação de units, detalhes de unit (metadados, anexos PDF, anotações, tópicos, erros recorrentes, conteúdos gerados), geração de resumo/exercícios/flashcards, exportação, progresso global e busca.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Navegar e gerenciar units (Priority: P1)

O usuário abre a aplicação e encontra a lista de todas as units cadastradas. A partir daí consegue criar uma nova unit, abrir uma existente para ver seus dados e editar informações básicas.

**Why this priority**: É o fluxo central — sem listar e criar units nada mais funciona. Toda sessão de estudo começa aqui.

**Independent Test**: Pode ser testado completamente acessando a aplicação do zero, criando uma unit com número, título, data e status, verificando que ela aparece na lista e que seu detalhe exibe os campos corretos.

**Acceptance Scenarios**:

1. **Given** que o backend está rodando com units cadastradas, **When** o usuário abre a tela inicial, **Then** a lista de units é exibida com número, título e status de cada uma.
2. **Given** que nenhuma unit existe, **When** o usuário acessa a listagem, **Then** uma mensagem de estado vazio é exibida com opção de criar a primeira unit.
3. **Given** a lista de units, **When** o usuário clica em "Nova unit", **Then** um formulário é exibido com campos número, título, data, status e observações.
4. **Given** o formulário preenchido com dados válidos, **When** o usuário confirma, **Then** a unit é criada e a listagem é atualizada imediatamente.
5. **Given** que o usuário tenta criar uma unit com número duplicado, **When** confirma, **Then** uma mensagem de erro clara é exibida ("unit já existe") sem submeter dados corrompidos.
6. **Given** a lista de units, **When** o usuário clica em uma unit, **Then** a tela de detalhes dessa unit é aberta.

---

### User Story 2 — Ver e enriquecer os dados de uma unit (Priority: P1)

O usuário abre uma unit e encontra agrupados: metadados, anexos, anotações, tópicos de estudo, erros recorrentes e conteúdos gerados. Pode registrar e editar cada um desses elementos sem sair da tela da unit.

**Why this priority**: A tela da unit é o núcleo da operação diária de estudos. Concentra todo o trabalho de anotação e acompanhamento.

**Independent Test**: Com uma unit criada, o usuário consegue registrar uma anotação, um tópico, marcar o tópico como dominado e registrar um erro recorrente — tudo na mesma tela, sem navegação adicional.

**Acceptance Scenarios**:

1. **Given** a tela de uma unit, **When** carregada, **Then** exibe: número, título, data, status, observações, lista de anexos, anotações, tópicos (com status de domínio), erros recorrentes e referências de conteúdos gerados.
2. **Given** a tela da unit, **When** o usuário registra ou edita uma anotação e salva, **Then** a anotação é persistida e exibida atualizada.
3. **Given** a tela da unit, **When** o usuário adiciona um tópico (tipo, descrição) e salva, **Then** o tópico aparece na lista de tópicos da unit.
4. **Given** um tópico listado, **When** o usuário altera seu status de domínio (REVISADO / PRECISO_REFORCAR / DOMINADO), **Then** o novo status é salvo e refletido visualmente.
5. **Given** a tela da unit, **When** o usuário registra um erro recorrente, **Then** o erro é salvo e exibido na seção de erros da unit.
6. **Given** que existem conteúdos gerados para a unit, **When** a tela carrega, **Then** exibe referências desses conteúdos (tipo, data de geração, quantidade, formato).

---

### User Story 3 — Anexar materiais à unit (Priority: P2)

O usuário seleciona um PDF de material de aula, homework ou correção e o associa a uma unit. A correção também pode ser registrada em texto quando não há PDF.

**Why this priority**: Parte fundamental do fluxo de estudo, mas pode ser feito após a unit já estar cadastrada.

**Independent Test**: Na tela de uma unit, o usuário faz upload de um PDF de material e de um PDF de homework, e constata que ambos aparecem na lista de anexos com tipo identificado.

**Acceptance Scenarios**:

1. **Given** a tela de uma unit, **When** o usuário seleciona um arquivo PDF e escolhe o tipo "material", **Then** o arquivo é enviado e listado como anexo de material.
2. **Given** a tela de uma unit, **When** o usuário seleciona um PDF e escolhe o tipo "homework", **Then** o arquivo é enviado e listado como anexo de homework.
3. **Given** a tela de uma unit, **When** o usuário digita a correção em texto e salva, **Then** a correção é persistida e exibida.
4. **Given** a tela de uma unit, **When** o usuário seleciona um PDF de correção, **Then** o arquivo é enviado e listado como correção.
5. **Given** que o envio do PDF falha, **When** o upload é concluído, **Then** uma mensagem de erro clara é exibida e nenhum dado incompleto é salvo.

---

### User Story 4 — Gerar e exportar conteúdos de uma unit (Priority: P2)

O usuário solicita a geração de resumo de revisão, exercícios de prática ou flashcards para uma unit. Também pode exportar conteúdos nos formatos disponíveis.

**Why this priority**: Agrega o valor intelectual principal ao fluxo de estudos.

**Independent Test**: Com uma unit que possui material e tópicos, o usuário clica em "Gerar resumo" e após a conclusão vê o resumo referenciado na tela; em seguida exporta em Markdown.

**Acceptance Scenarios**:

1. **Given** a tela de uma unit com base suficiente, **When** o usuário aciona "Gerar resumo", **Then** o sistema exibe um indicador de progresso e, ao concluir, a referência ao resumo aparece na seção de conteúdos gerados.
2. **Given** a tela de uma unit com base suficiente, **When** o usuário aciona "Gerar exercícios", **Then** o resultado é referenciado na seção de conteúdos gerados.
3. **Given** a tela de uma unit com base suficiente, **When** o usuário aciona "Gerar flashcards", **Then** o resultado é referenciado na seção de conteúdos gerados.
4. **Given** que a base da unit é insuficiente para geração, **When** o usuário aciona qualquer geração, **Then** uma mensagem explicativa é exibida (ex: "base insuficiente para geração") sem travar a interface.
5. **Given** conteúdos gerados existentes, **When** o usuário aciona exportação e escolhe um formato (Markdown, JSON ou PDF), **Then** o arquivo é baixado no formato selecionado.
6. **Given** que a IA está indisponível, **When** o usuário tenta gerar conteúdo, **Then** uma mensagem clara informa a indisponibilidade sem dados corrompidos.

---

### User Story 5 — Acompanhar progresso e erros recorrentes (Priority: P3)

O usuário acessa a tela de progresso e vê, por unit, se há material, homework, correção e quantos tópicos ainda precisam de revisão. Na tela de erros recorrentes, vê a lista consolidada e pode filtrar por unit.

**Why this priority**: Visão de cobertura e lacunas do estudo; importante, mas não bloqueia a operação básica.

**Independent Test**: Com três units em estados diferentes, o usuário acessa "Progresso" e identifica qual unit está mais incompleta.

**Acceptance Scenarios**:

1. **Given** que existem units cadastradas, **When** o usuário acessa a tela de progresso, **Then** cada unit é exibida com indicadores visuais de: presença de material, homework, correção e contagem de tópicos pendentes de revisão.
2. **Given** a tela de progresso, **When** o usuário identifica uma unit incompleta, **Then** consegue navegar diretamente para essa unit clicando nela.
3. **Given** que existem erros recorrentes em múltiplas units, **When** o usuário acessa a tela de erros, **Then** a lista consolidada é exibida com descrição e, quando disponível, unit de origem.
4. **Given** a tela de erros consolidados, **When** o usuário aplica filtro por unit, **Then** somente os erros daquela unit são exibidos.

---

### User Story 6 — Buscar na base de conhecimento (Priority: P3)

O usuário digita uma palavra-chave e a aplicação retorna resultados agrupados por tipo: unit, nota, vocabulário, exercício, flashcard ou erro.

**Why this priority**: Complementa o fluxo de revisão; útil mas não bloqueia as funcionalidades principais.

**Independent Test**: Com dados persistidos, o usuário busca por "past perfect" e vê resultados agrupados por tipo indicando onde o termo aparece.

**Acceptance Scenarios**:

1. **Given** a tela de busca, **When** o usuário digita um termo e confirma, **Then** os resultados são exibidos agrupados por tipo (unit, nota, vocabulário, exercício, flashcard, erro).
2. **Given** que o termo não encontra resultados, **When** a busca é executada, **Then** uma mensagem de "nenhum resultado encontrado" é exibida de forma clara.
3. **Given** resultados de busca, **When** o usuário clica em um resultado do tipo unit, **Then** é levado à tela daquela unit.

---

### User Story 7 — Iniciar e desligar a solução completa (Priority: P1)

O usuário executa um único comando (`./start.sh`) no diretório raiz do projeto e a solução completa (backend + frontend) sobe em ordem. Ao final, as URLs do backend e do frontend são exibidas. O desligamento ocorre com `./stop.sh`.

**Why this priority**: Sem bootstrap funcional o usuário não consegue acessar nenhuma parte da solução.

**Independent Test**: A partir de um estado desligado, o usuário executa `./start.sh` e em até 2 minutos vê as URLs no terminal; a aplicação frontend abre no navegador e lista units existentes.

**Acceptance Scenarios**:

1. **Given** que Docker está disponível e o backend tem os pré-requisitos, **When** o usuário executa `./start.sh` na raiz `english-partner/`, **Then** o backend é iniciado primeiro, o health check é aguardado e o frontend é iniciado somente após o backend estar saudável.
2. **Given** que a inicialização concluiu, **When** o terminal exibe o resultado, **Then** as URLs do backend (Swagger UI) e do frontend são exibidas claramente.
3. **Given** que o sistema está em execução, **When** o usuário executa `./stop.sh` na raiz, **Then** o frontend é desligado e em seguida o backend é encerrado de forma ordenada.
4. **Given** que o backend não sobe dentro do timeout, **When** o script detecta a falha, **Then** uma mensagem de erro é exibida e o frontend não é iniciado.

---

### Edge Cases

- O que acontece quando o backend está offline ao abrir o frontend? → A interface exibe mensagem de conectividade com o backend indisponível, sem travar ou exibir tela em branco.
- O que acontece ao tentar gerar conteúdo para uma unit sem material anexado? → Mensagem explicativa ("base insuficiente para geração") sem iniciar o processo.
- O que acontece ao fazer upload de um arquivo que não é PDF? → Mensagem de validação antes do envio.
- O que acontece quando a geração de conteúdo demora? → Indicador de carregamento visível; o usuário não perde o contexto da tela.
- O que acontece ao reiniciar a solução? → Os dados persistidos pelo backend continuam disponíveis; o frontend exibe o estado anterior normalmente.

---

## Requirements *(mandatory)*

### Functional Requirements

**Navegação e estrutura**
- **FR-001**: O sistema DEVE prover navegação principal com acesso a: Visão Geral, Units, Progresso, Erros Recorrentes e Busca.
- **FR-002**: O sistema DEVE exibir na Visão Geral um resumo das units cadastradas, do progresso global e das pendências de revisão.
- **FR-003**: O sistema DEVE exibir estados de carregamento durante chamadas à API.
- **FR-004**: O sistema DEVE exibir mensagens de erro compreensíveis quando o backend retornar falhas (unit duplicada, unit não encontrada, base insuficiente, IA indisponível).
- **FR-005**: A interface DEVE funcionar em tela desktop e adaptar-se a telas menores (responsividade).
- **FR-006**: O sistema NÃO DEVE exigir autenticação, login ou cadastro de usuário.

**Units — listagem e criação**
- **FR-007**: O usuário DEVE conseguir listar todas as units cadastradas.
- **FR-008**: O usuário DEVE conseguir criar uma nova unit informando número, título, data, status (AGENDADA | REALIZADA | EM_REVISAO | CONCLUIDA) e observações.
- **FR-009**: O usuário DEVE conseguir visualizar os detalhes de uma unit específica, incluindo: metadados, anexos, anotações, tópicos, erros recorrentes e referências de conteúdos gerados.

**Units — anexos**
- **FR-010**: O usuário DEVE conseguir anexar um PDF de material principal a uma unit.
- **FR-011**: O usuário DEVE conseguir anexar um PDF de homework a uma unit.
- **FR-012**: O usuário DEVE conseguir registrar a correção de homework em texto ou anexar PDF de correção.

**Units — anotações**
- **FR-013**: Cada unit possui um único bloco de anotações em formato Markdown; o usuário DEVE conseguir editar e salvar esse bloco. O bloco começa vazio no editor a cada abertura da unit (o backend persiste o conteúdo, mas não expõe endpoint de leitura do conteúdo — apenas o caminho do arquivo). O conteúdo salvo não é pré-carregado no editor: limitação da API atual do backend.

**Units — tópicos**
- **FR-014**: O usuário DEVE conseguir registrar tópicos de uma unit informando tipo (gramática, vocabulário, expressões, pronúncia, erros) e descrição.
- **FR-015**: O usuário DEVE conseguir editar tópicos de uma unit — incluindo alterar o tipo (`kind`) e o texto descritivo (`label`) de um tópico existente. A edição atualiza o array completo via `PUT /topics`.
- **FR-016**: O usuário DEVE conseguir marcar um tópico com status de domínio: REVISADO, PRECISO_REFORCAR ou DOMINADO.

**Units — erros recorrentes**
- **FR-017**: O usuário DEVE conseguir registrar erros recorrentes associados a uma unit.

**Geração de conteúdo**
- **FR-018**: O usuário DEVE conseguir solicitar a geração de resumo de revisão para uma unit.
- **FR-019**: O usuário DEVE conseguir solicitar a geração de exercícios de prática para uma unit.
- **FR-020**: O usuário DEVE conseguir solicitar a geração de flashcards para uma unit.
- **FR-021**: O sistema DEVE exibir referências dos conteúdos gerados (tipo, caminho, quantidade e data de geração quando disponíveis).

**Exportação**
- **FR-022**: O usuário DEVE conseguir exportar conteúdos de uma unit nos formatos Markdown, JSON e PDF.

**Progresso**
- **FR-023**: O sistema DEVE exibir uma tela de progresso mostrando, por unit: presença de material, homework, correção e quantidade de tópicos ainda pendentes de revisão.

**Erros recorrentes consolidados**
- **FR-024**: O sistema DEVE exibir a lista consolidada de erros recorrentes de todas as units.
- **FR-025**: O usuário DEVE conseguir filtrar os erros recorrentes consolidados por unit.

**Busca**
- **FR-026**: O usuário DEVE conseguir buscar por palavra-chave na base local, com resultados exibidos por tipo: unit, nota, vocabulário, exercício, flashcard ou erro.

**Bootstrap e ciclo de vida**
- **FR-027**: O usuário DEVE conseguir iniciar backend e frontend com um único comando (`./start.sh`) a partir do diretório raiz `english-partner/`.
- **FR-028**: O script de inicialização DEVE aguardar o backend estar saudável antes de iniciar o frontend.
- **FR-029**: Ao final da inicialização, as URLs do backend (Swagger UI) e do frontend DEVEM ser exibidas no terminal.
- **FR-030**: O usuário DEVE conseguir encerrar a solução completa com `./stop.sh` a partir do diretório raiz.

### Key Entities

- **Unit**: Unidade de estudo. Atributos principais: número (identificador único inteiro), título, data da aula, status (enum: AGENDADA | REALIZADA | EM_REVISAO | CONCLUIDA), observações livres.
- **Attachment**: Arquivo PDF associado à unit. Tipos: material principal, homework, correção.
- **Correction**: Texto de correção de homework associado a uma unit (alternativa ao PDF).
- **Note**: Bloco único de texto em formato Markdown por unit. Começa vazio; cada salvamento substitui o conteúdo anterior integralmente.
- **Topic**: Tópico de estudo da unit. Atributos: tipo (gramática, vocabulário, expressões, pronúncia, erros recorrentes), descrição, status de domínio (REVISADO / PRECISO_REFORCAR / DOMINADO).
- **RecurringError**: Erro recorrente registrado em uma unit; também aparece na lista consolidada.
- **GeneratedContent**: Referência a conteúdo gerado para a unit. Tipos: resumo, exercícios, flashcards. Atributos de referência: tipo, caminho/formato, quantidade, data de geração.
- **Progress**: Visão calculada por unit: presença de material, homework, correção, contagem de tópicos pendentes.
- **SearchResult**: Resultado de busca por palavra-chave, tipado (unit, nota, vocabulário, exercício, flashcard, erro).

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: O usuário consegue iniciar a solução completa (backend + frontend) a partir do diretório raiz com um único comando e ver as URLs no terminal em até 3 minutos.
- **SC-002**: O usuário consegue criar uma unit, registrar um tópico e consultar a listagem em menos de 2 minutos a partir de zero.
- **SC-003**: Qualquer ação de escrita (criar unit, registrar tópico, salvar anotação) é refletida na interface imediatamente após a confirmação da API, sem necessidade de recarregar a página. Exceção: operações de geração de conteúdo (FR-018–020) são assíncronas e exibem indicador de progresso até a conclusão.
- **SC-004**: Mensagens de erro do backend são exibidas de forma compreensível em todos os cenários mapeados (duplicidade, base insuficiente, IA indisponível, backend offline).
- **SC-005**: Após reiniciar a solução, o frontend exibe todos os dados persistidos anteriormente sem degradação ou perda de informação.
- **SC-006**: A interface responde a interações do usuário em menos de 200ms para operações locais (sem aguardar a API); operações que dependem da API exibem indicador de carregamento enquanto aguardam.
- **SC-007**: O usuário consegue buscar por palavra-chave e receber resultados agrupados por tipo em menos de 3 segundos para bases com até 50 units.

---

## Assumptions

- O backend `english-partner-backend` já está implementado e funcional, expondo a API REST em `http://localhost:8080` (URL configurável via variável de ambiente).
- O sistema roda exclusivamente de forma local; não há acesso de outros usuários ou dispositivos simultâneos.
- Não há requisito de autenticação ou controle de sessão, pois o sistema é single-user e local.
- A interface será utilizada primariamente em desktop; suporte a telas menores é desejado mas não é o caso de uso principal.
- Os scripts `start.sh` e `stop.sh` na raiz `english-partner/` não serão rastreados em git; vivem apenas no filesystem.
- Os scripts `start.sh` e `stop.sh` dentro de `english-partner-backend/` são mantidos sem alteração para possibilitar uso standalone do backend.
- O frontend assume que o backend está disponível para uso; a tela de "backend indisponível" é informativa, não um modo offline funcional.
- Os formatos de exportação (Markdown, JSON, PDF) são definidos e implementados pelo backend; o frontend apenas aciona o endpoint de exportação e faz o download.
- A geração de conteúdo (resumo, exercícios, flashcards) é computacionalmente custosa; o usuário é informado de que a operação pode demorar.

---

## Clarifications

### Session 2026-06-22

- Q: Quais são os valores canônicos do campo status da unit? → A: AGENDADA, REALIZADA, EM_REVISAO, CONCLUIDA
- Q: A anotação por unit é um bloco único ou uma lista de múltiplas anotações? → A: Um bloco único de texto Markdown, editável e salvo como substituição integral por unit.
- Correção analyze C1: backend não expõe GET /notes — editor de nota inicia vazio; `notesPath` é apenas referência de arquivo. FR-013 atualizado.
- Correção analyze H1: SC-003 restrito para excluir operações de geração assíncronas (FR-018–020).
- Correção analyze H2: FR-015 expandido para incluir edição de kind + label de tópico existente; T029 atualizado.
