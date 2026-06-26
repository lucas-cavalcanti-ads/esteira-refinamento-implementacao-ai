# Feature Specification: Assistente Local de Estudos de Inglês com Base de Conhecimento Contínua

**Feature Branch**: `claude-assistente-estudos-ingles`

**Created**: 2026-06-20

**Status**: Refined (Etapa 2)

**Input**: User description: "Sistema local que organiza o material de estudo de inglês (PDFs de
material, homework, correção), anotações por unit, e gera/guarda conteúdos de estudo (resumos,
exercícios, flashcards, erros recorrentes), criando uma memória contínua reutilizada a cada início."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Organizar units e materiais com persistência local (Priority: P1)

Como estudante, quero cadastrar uma unit e anexar a ela meus PDFs (material, homework preenchido,
correção da professora) e minhas anotações livres, num arquivamento local legível, para que tudo
fique organizado por unidade e continue disponível sempre que eu reabrir o sistema.

**Why this priority**: É o núcleo do produto e o MVP. Sem cadastro de unit, anexos e persistência
local reutilizável, nenhum outro recurso (geração, progresso, busca) tem matéria-prima. Entrega
valor sozinha: já substitui o "monte de PDFs soltos" por uma base organizada.

**Independent Test**: Criar a Unit 01, anexar um `material.pdf` e um `homework.pdf`, escrever uma
anotação, fechar o sistema, reabrir e confirmar que a unit, os arquivos e a anotação continuam lá e
acessíveis também pelo gerenciador de arquivos do SO.

**Acceptance Scenarios**:

1. **Given** o sistema iniciado sem nenhuma unit, **When** o usuário cria uma unit informando título
   e número, **Then** o sistema cria automaticamente a pasta `units/unit-01/` e registra a unit com
   status inicial.
2. **Given** uma unit existente, **When** o usuário anexa um PDF de material e um PDF de homework,
   **Then** os arquivos são salvos em `units/unit-01/material.pdf` e `units/unit-01/homework.pdf` e
   ficam vinculados à unit.
3. **Given** uma unit existente, **When** o usuário registra e depois edita uma anotação, **Then** o
   conteúdo é salvo em `units/unit-01/notes.md` e a edição persiste.
4. **Given** dados cadastrados, **When** o usuário fecha e reabre o sistema, **Then** todas as units,
   arquivos, anotações e conteúdos gerados anteriormente continuam disponíveis e consultáveis.
5. **Given** a base local existente, **When** o sistema é reiniciado, **Then** ele carrega a base e
   permite consultar units anteriores sem recomeçar do zero.

### User Story 2 - Geração assistida usando a base local como contexto (Priority: P2)

Como estudante, quero que o sistema gere um resumo de revisão, exercícios de prática e flashcards de
uma unit usando o conteúdo da unit **e** o histórico salvo (inclusive erros recorrentes de units
anteriores), para reforçar justamente onde erro mais, sem recomeçar do zero a cada unidade.

**Why this priority**: É o diferencial sobre uma simples pasta organizada — transforma a base em
estudo ativo. Depende da P1 (precisa de conteúdo cadastrado) mas é o segundo maior valor.

**Independent Test**: Numa unit com material e anotações cadastrados e com erros recorrentes salvos
de uma unit anterior, acionar a geração e verificar que sai um resumo de revisão, ≥5 exercícios
(alguns mirando os erros recorrentes) e ≥10 flashcards — todos salvos em arquivo.

**Acceptance Scenarios**:

1. **Given** uma unit com anotações e material registrados, **When** o usuário pede a revisão,
   **Then** o sistema gera um resumo de revisão baseado nas anotações e no histórico salvo e o grava
   em `units/unit-01/summary.md`.
2. **Given** uma unit com conteúdo e erros recorrentes salvos de units anteriores, **When** o usuário
   pede exercícios, **Then** o sistema gera **pelo menos 5** exercícios considerando o conteúdo da
   unit e os erros recorrentes anteriores, gravando em `units/unit-01/exercises.md`.
3. **Given** uma unit com vocabulário/expressões, **When** o usuário pede flashcards, **Then** o
   sistema gera **pelo menos 10** flashcards e os grava em `units/unit-01/flashcards.json`.
4. **Given** geração concluída, **When** o sistema termina, **Then** os conteúdos gerados são salvos
   automaticamente (sem ação extra do usuário) e passam a integrar a base para gerações futuras.

### User Story 3 - Progresso, erros recorrentes, status e busca (Priority: P3)

Como estudante, quero ver o progresso por unit, marcar conteúdos como "revisado / preciso reforçar /
dominado", consultar a lista consolidada de erros recorrentes e buscar por palavra-chave em toda a
base, para saber o que ainda falta revisar e encontrar rapidamente o que preciso.

**Why this priority**: Camada de navegação e acompanhamento. Agrega muito valor, mas só faz sentido
depois que há units, conteúdo e geração (P1+P2).

**Independent Test**: Com algumas units cadastradas e homeworks corrigidos, abrir a visão de
progresso, marcar um tema como "dominado", ver a lista consolidada de erros recorrentes e buscar um
termo, confirmando que o resultado aponta as units/anotações/exercícios/erros relacionados.

**Acceptance Scenarios**:

1. **Given** units com diferentes materiais e homeworks, **When** o usuário abre a visão de progresso,
   **Then** o sistema mostra, por unit, quais materiais existem, quais homeworks foram feitos/
   corrigidos e o que ainda precisa de revisão.
2. **Given** um conteúdo ou unit, **When** o usuário marca como "revisado", "preciso reforçar" ou
   "dominado", **Then** o status é salvo e refletido na visão de progresso.
3. **Given** homeworks corrigidos e anotações com erros, **When** o usuário abre os erros recorrentes,
   **Then** o sistema exibe a lista consolidada por unit e a visão geral de todos os erros.
4. **Given** a base populada, **When** o usuário busca por uma palavra-chave, **Then** o sistema
   retorna units, anotações, vocabulário, exercícios, flashcards e erros recorrentes relacionados ao
   termo.

### User Story 4 - Subir e encerrar o sistema com um único comando (Priority: P1)

Como estudante no meu próprio computador, quero iniciar todo o sistema (todas as camadas) com **um
único comando/script** e encerrá-lo do mesmo jeito, para não ter que ligar/desligar várias camadas
manualmente.

**Why this priority**: Requisito de usabilidade que atravessa o MVP — se o usuário não consegue subir
o sistema sozinho de forma simples, o resto não é utilizável no dia a dia.

**Independent Test**: Num computador com os pré-requisitos documentados instalados, rodar um único
comando e confirmar que todas as camadas sobem e o sistema fica pronto para uso; rodar o comando de
encerramento e confirmar que tudo é desligado de forma limpa.

**Acceptance Scenarios**:

1. **Given** o repositório clonado e os pré-requisitos instalados, **When** o usuário roda o comando
   único de inicialização, **Then** todas as camadas necessárias sobem e o sistema fica utilizável,
   sem passos manuais adicionais por camada.
2. **Given** o sistema no ar, **When** o usuário roda o comando único de encerramento, **Then** todas
   as camadas são desligadas de forma limpa, preservando a base local.

### Edge Cases

- Unit duplicada (mesmo número) → o sistema deve impedir ou avisar, não sobrescrever silenciosamente.
- PDF ilegível/protegido/escaneado sem texto → o anexo é preservado, mas a extração de texto pode
  falhar; o sistema registra o anexo e sinaliza que não conseguiu extrair conteúdo para geração.
- Geração solicitada sem material/anotação suficiente → o sistema avisa que não há base suficiente em
  vez de gerar conteúdo vazio/alucinado.
- Geração com o motor de IA indisponível (sem internet, no caso de motor em nuvem) → o acesso e a
  leitura da base local continuam funcionando; apenas a geração nova fica indisponível, com aviso
  claro. Acesso offline aos arquivos já salvos é sempre garantido.
- Reabertura com arquivos editados manualmente fora do sistema → o sistema trata o que está no disco
  como fonte da verdade dos artefatos e reconstrói o índice a partir dele.
- Homework sem correção ainda → a unit aparece como "homework feito, correção pendente" no progresso.

## Requirements *(mandatory)*

### Functional Requirements

**Cadastro e organização**
- **FR-001**: O sistema MUST permitir cadastrar uma unit com título, número, data, status e
  observações gerais.
- **FR-002**: O sistema MUST criar automaticamente uma pasta local própria para cada unit
  (`units/unit-NN/`) no momento da criação.
- **FR-003**: O sistema MUST permitir anexar a cada unit o PDF do material principal, o PDF do
  homework preenchido e o registro/anexo da correção do homework.
- **FR-004**: O sistema MUST permitir criar, editar e salvar anotações livres da aula por unit.
- **FR-005**: O sistema MUST permitir **registrar manualmente** os principais temas de cada unit
  (gramática, vocabulário, expressões, pronúncia, erros recorrentes). Em v1 o registro manual é o
  caminho garantido; a **extração automática** de temas a partir do texto do material é um auxílio
  opcional (best-effort) que apenas **pré-popula sugestões** editáveis, nunca substitui o registro
  do usuário.

**Persistência e base contínua**
- **FR-006**: O sistema MUST salvar localmente todos os dados gerados (resumos, exercícios,
  flashcards, listas de erros, vocabulário, progresso) automaticamente, sem ação extra do usuário.
- **FR-007**: O sistema MUST organizar os artefatos numa estrutura local legível e estável por unit
  (ex.: `material.pdf`, `homework.pdf`, `correction.pdf`, `notes.md`, `summary.md`, `exercises.md`,
  `flashcards.json`), acessível manualmente fora do sistema.
- **FR-008**: O sistema MUST persistir toda a base de forma que, após fechar e reabrir, todos os
  dados cadastrados e gerados continuem disponíveis.
- **FR-009**: O sistema MUST, ao iniciar, carregar a base local existente e permitir consultar units
  anteriores.
- **FR-010**: O sistema MUST usar a base local existente como contexto para novas gerações (não
  recomeçar do zero) e alimentá-la continuamente com novos materiais, anotações, correções e
  conteúdos gerados.

**Geração de conteúdo de estudo**
- **FR-011**: O sistema MUST gerar um resumo de revisão da unit a partir dos materiais, anotações e
  histórico salvo.
- **FR-012**: O sistema MUST gerar exercícios de prática (≥5 por unit) com base no conteúdo da unit
  **e** nos erros recorrentes de units anteriores.
- **FR-013**: O sistema MUST gerar flashcards de vocabulário/expressões relevantes da unit (≥10 por
  unit), em formato JSON.
- **FR-014**: O sistema MUST consolidar uma lista de erros recorrentes a partir dos homeworks
  corrigidos e das anotações, exibível por unit e em visão geral. Em v1, o erro recorrente é uma
  entrada **registrada/confirmada pelo usuário** (a partir da correção/anotação); a sugestão
  automática a partir do texto é auxílio opcional, não a fonte autoritativa.

**Acompanhamento e navegação**
- **FR-015**: O sistema MUST permitir marcar conteúdos/temas/units como "revisado", "preciso
  reforçar" ou "dominado", e persistir o status.
- **FR-016**: O sistema MUST oferecer uma visão de progresso por unit (materiais existentes, homeworks
  feitos/corrigidos, conteúdos pendentes de revisão).
- **FR-017**: O sistema MUST exibir, para uma unit, os arquivos vinculados, as anotações, os temas
  registrados e os conteúdos gerados.
- **FR-018**: O sistema MUST permitir busca por palavra-chave em anotações, temas, vocabulário,
  exercícios, flashcards e erros recorrentes, retornando os itens relacionados.

**Local-first e exportação**
- **FR-019**: O sistema MUST funcionar localmente, sem exigir login, armazenamento em nuvem ou banco
  de dados online para acessar os arquivos já salvos; o acesso e a leitura da base local NÃO podem
  depender de internet.
- **FR-020**: O sistema MUST permitir exportar/visualizar os conteúdos gerados em formatos simples e
  legíveis (Markdown, JSON e/ou PDF).
- **FR-021**: O sistema MUST poder ser iniciado e encerrado por um **único comando/script** que
  orquestra todas as camadas, sem o usuário subir/derrubar camadas manualmente.

### Key Entities *(include if feature involves data)*

- **Unit**: unidade de estudo. Atributos: número, título, data, status, observações. Relaciona-se a
  arquivos, anotações, temas e conteúdos gerados.
- **Anexo (Attachment)**: arquivo vinculado a uma unit (material, homework, correção). Atributos:
  tipo, caminho do arquivo, data, status de extração de texto.
- **Anotação (Note)**: texto livre por unit, editável, salvo a cada gravação.
- **Tema (Topic)**: assunto da unit (gramática, vocabulário, expressão, pronúncia, erro recorrente),
  com status de domínio (revisado/reforçar/dominado).
- **Conteúdo Gerado (GeneratedContent)**: resumo, exercício, flashcard — derivado da base, com
  proveniência (de quais fontes foi gerado).
- **Erro Recorrente (RecurringError)**: padrão de erro extraído de correções/anotações, com unit(s)
  de origem e contagem de recorrência.
- **Progresso (Progress)**: estado de revisão/domínio agregado por unit e por tema.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: O usuário cria uma unit informando título e número e o sistema cria a pasta local
  correspondente automaticamente em 100% das criações.
- **SC-002**: Após fechar e reabrir o sistema, 100% dos dados cadastrados e gerados continuam
  disponíveis e consultáveis (zero perda).
- **SC-003**: Para uma unit com conteúdo registrado, o sistema gera **≥5 exercícios** e **≥10
  flashcards** numa única solicitação.
- **SC-004**: Quando existir histórico de erros, ≥1 exercício gerado contém o `label` literal de um
  `RecurringError` cujo `sourceUnits` inclui uma unit anterior (critério verificável de forma
  determinística no teste).
- **SC-005**: Para um token presente no índice, a busca retorna ≥1 hit em **cada categoria** (unit,
  anotação, vocabulário, exercício, flashcard, erro) cujo conteúdo indexado contenha aquele token.
- **SC-006**: Com a rede desligada, o usuário consegue abrir o sistema, listar units e ler todos os
  artefatos já salvos.
- **SC-007**: A árvore de arquivos gerada é navegável e legível manualmente fora do sistema (abrindo
  os arquivos no gerenciador/editor do SO).
- **SC-008**: O sistema sobe e é encerrado por um único comando cada, sem passos manuais por camada.

## Assumptions

- Estudante individual, uso pessoal num único computador (não multiusuário, não concorrente).
- Volume modesto: dezenas de units, alguns PDFs por unit (não é carga de produção).
- Os PDFs de material/homework majoritariamente contêm texto extraível (não apenas imagem escaneada);
  PDFs só-imagem são anexados, mas a extração automática pode não render conteúdo (ver Edge Cases).
- A *geração* de conteúdo novo (resumos/exercícios/flashcards) pode usar um serviço de IA externo e,
  portanto, exigir internet **apenas no momento da geração**; o acesso à base já salva é sempre
  offline (FR-019). Decidido na Etapa 1 (D3 = Claude API); alternativa offline (LLM local) registrada
  como decisão em aberto de menor prioridade.
- Pré-requisitos de ambiente (runtime + container local) estão instalados; o "único comando" assume
  esses pré-requisitos, documentados no quickstart.
- A árvore `units/unit-NN/` no sistema de arquivos é a **fonte da verdade** dos artefatos; o índice de
  busca/metadados é derivado e reconstruível a partir dela (D1 = híbrido).
