# Feature Requirements Quality Checklist: English Partner View

**Purpose**: Validar completude, clareza, consistência e mensurabilidade dos requisitos antes de iniciar o planejamento técnico.
**Created**: 2026-06-22
**Feature**: [spec.md](../spec.md)

---

## Requirement Completeness — Navegação e Estrutura

- [ ] CHK001 - O spec define os itens exatos da navegação principal (Visão Geral, Units, Progresso, Erros Recorrentes, Busca)? São suficientes para cobrir todos os fluxos de FR-001 a FR-030? [Completeness, Spec §FR-001]
- [ ] CHK002 - São definidos requisitos para o conteúdo da Visão Geral além do resumo genérico? O spec especifica quais métricas exibir (contagem de units por status, total de tópicos pendentes etc.)? [Clarity, Spec §FR-002]
- [ ] CHK003 - O spec define requisitos para o estado vazio da listagem de units (nenhuma unit cadastrada)? [Coverage, Spec §FR-007]
- [ ] CHK004 - Existe requisito documentado para navegação de retorno (ex.: unidade → listagem, busca → resultado)? [Gap]
- [ ] CHK005 - O spec define o comportamento da navegação quando o backend está offline ao carregar a tela inicial? [Edge Case, Spec §FR-004]

---

## Requirement Completeness — Units (criação e listagem)

- [ ] CHK006 - O enum de status (AGENDADA, REALIZADA, EM_REVISAO, CONCLUIDA) está definido em todos os pontos do spec onde "status" é referenciado? [Consistency, Spec §FR-008, Key Entities]
- [ ] CHK007 - O spec define quais campos são obrigatórios vs. opcionais no formulário de criação de unit? [Clarity, Spec §FR-008]
- [ ] CHK008 - São definidos requisitos para a ordenação da listagem de units? (ex.: por número, por data, por status) [Gap, Spec §FR-007]
- [ ] CHK009 - O spec define o comportamento ao tentar criar uma unit com número duplicado em todos os cenários de aceite relevantes? [Coverage, Spec §US1-AC5]
- [ ] CHK010 - Há requisito documentado para edição de uma unit existente (campos editáveis, campos bloqueados)? [Gap]

---

## Requirement Completeness — Detalhes da Unit

- [ ] CHK011 - O spec define a estrutura visual dos detalhes de uma unit com clareza suficiente (quais seções, quais dados de cada seção)? [Completeness, Spec §FR-009]
- [ ] CHK012 - Existe requisito para o estado de carregamento dos detalhes de uma unit enquanto a API responde? [Coverage, Spec §FR-003]
- [ ] CHK013 - O spec define o comportamento quando uma unit inexistente é acessada diretamente (ex.: URL inválida)? [Edge Case, Spec §FR-004]

---

## Requirement Clarity — Anotações

- [ ] CHK014 - O requisito FR-013 está suficientemente claro sobre o comportamento do editor Markdown? (ex.: é um textarea simples com preview, ou editor com formatação ao vivo?) [Clarity, Spec §FR-013]
- [ ] CHK015 - O spec define o comportamento da anotação quando está vazia pela primeira vez? (ex.: placeholder, prompt de edição) [Edge Case, Gap]
- [ ] CHK016 - Há requisito que defina o que acontece se o salvamento da anotação falhar? [Exception Flow, Spec §FR-004]

---

## Requirement Completeness — Tópicos

- [ ] CHK017 - O spec define a lista canônica e exaustiva de tipos de tópico (gramática, vocabulário, expressões, pronúncia, erros recorrentes)? Essa lista fecha o enum ou admite novos tipos? [Clarity, Spec §FR-014]
- [ ] CHK018 - Existe requisito documentado para a remoção de um tópico? [Gap, Spec §FR-015]
- [ ] CHK019 - O spec define o comportamento esperado quando não existem tópicos cadastrados para uma unit? [Edge Case, Coverage]
- [ ] CHK020 - O requisito FR-016 define um comportamento de fallback quando a atualização do status de domínio falha? [Exception Flow, Spec §FR-004]

---

## Requirement Completeness — Anexos

- [ ] CHK021 - O spec define o tamanho máximo permitido para arquivos PDF? Ou assume qualquer tamanho? [Clarity, Gap]
- [ ] CHK022 - Há requisito para o estado de progresso de upload de um PDF? (ex.: barra de progresso, feedback de envio) [Completeness, Spec §FR-003]
- [ ] CHK023 - O spec define o que acontece ao tentar anexar um PDF de tipo já existente para a mesma unit? (ex.: substituir ou bloquear?) [Edge Case, Gap]
- [ ] CHK024 - Existe requisito documentado para visualizar/abrir um PDF já anexado? [Gap]

---

## Requirement Completeness — Erros Recorrentes

- [ ] CHK025 - O spec define os atributos de um erro recorrente além de "descrição"? (ex.: categoria, data, severidade) [Clarity, Spec §Key Entities — RecurringError]
- [ ] CHK026 - Há requisito para edição ou remoção de um erro recorrente registrado? [Gap]
- [ ] CHK027 - O spec define o comportamento do filtro por unit na tela de erros consolidados quando nenhum filtro está aplicado? [Clarity, Spec §FR-025]

---

## Requirement Completeness — Geração de Conteúdo

- [ ] CHK028 - O spec define o comportamento caso o usuário acione uma nova geração enquanto outra já está em progresso? [Edge Case, Gap]
- [ ] CHK029 - Há requisito documentado para o que acontece ao tentar gerar conteúdo novamente quando já existe conteúdo gerado? (substituição, adição ou bloqueio?) [Clarity, Spec §FR-018–020]
- [ ] CHK030 - O spec define um timeout máximo esperado pelo usuário para operações de geração? [Non-Functional, Gap]
- [ ] CHK031 - Os requisitos FR-018 a FR-020 são consistentes com o critério de sucesso SC-003 (reflexo imediato)? (geração é assíncrona e não pode refletir imediatamente) [Consistency, Spec §SC-003]

---

## Requirement Completeness — Exportação

- [ ] CHK032 - O spec define o comportamento de exportação quando não há conteúdo gerado para exportar? [Edge Case, Spec §FR-022]
- [ ] CHK033 - Há requisito documentado sobre como o download do arquivo exportado se manifesta para o usuário? (ex.: download automático, dialog de salvar) [Clarity, Spec §FR-022]
- [ ] CHK034 - O spec define quais conteúdos específicos são incluídos em cada formato de exportação (Markdown, JSON, PDF)? Ou delega completamente ao backend? [Clarity, Spec §Assumptions]

---

## Requirement Completeness — Progresso

- [ ] CHK035 - O spec define o critério exato de "tópico pendente de revisão" para o cálculo na tela de progresso? (ex.: apenas PRECISO_REFORCAR, ou também REVISADO?) [Clarity, Spec §FR-023]
- [ ] CHK036 - Há requisito para ordenação ou agrupamento das units na tela de progresso? (ex.: por percentual de completude, por status) [Gap]

---

## Requirement Completeness — Busca

- [ ] CHK037 - O spec define o comprimento mínimo da palavra-chave de busca? [Clarity, Spec §FR-026]
- [ ] CHK038 - Há requisito para o comportamento de busca com resultados parciais ou busca incremental (enquanto o usuário digita)? [Clarity, Gap]
- [ ] CHK039 - O spec define se clicar em resultados de outros tipos (nota, vocabulário, erro) além de unit navega para algum destino? [Gap, Spec §US6-AC3]

---

## Requirement Completeness — Bootstrap e Ciclo de Vida

- [ ] CHK040 - O spec define o timeout máximo que o start.sh aguardará antes de declarar falha no health check do backend? [Clarity, Spec §FR-028]
- [ ] CHK041 - Há requisito documentado sobre o comportamento do stop.sh quando um dos processos já está encerrado? [Edge Case, Gap]
- [ ] CHK042 - O spec define a porta padrão do frontend e se ela é configurável? [Completeness, Gap]
- [ ] CHK043 - O critério SC-001 (3 minutos de inicialização) é mensurável de forma objetiva no contexto de máquinas diferentes? [Measurability, Spec §SC-001]

---

## Requirement Consistency — Cruzamentos

- [ ] CHK044 - O critério SC-003 ("reflexo imediato após confirmação da API") é consistente com os cenários de geração assíncrona de conteúdo (FR-018–020), que por definição demoram? [Consistency, Spec §SC-003 vs §FR-018]
- [ ] CHK045 - O requisito FR-013 (anotação Markdown, bloco único) está consistente com todos os cenários de aceite da US2 que mencionam "editar anotações"? [Consistency, Spec §US2-AC2 vs §FR-013]
- [ ] CHK046 - Os tipos de resultado de busca em FR-026 ("unit, nota, vocabulário, exercício, flashcard, erro") são consistentes com os tipos de conteúdo definidos nas demais seções? [Consistency, Spec §FR-026 vs Key Entities]

---

## Non-Functional Requirements — UX e Responsividade

- [ ] CHK047 - O spec quantifica "telas menores" com breakpoints específicos ou faixas de largura mínima? [Clarity, Spec §FR-005]
- [ ] CHK048 - Existe requisito de acessibilidade (navegação por teclado, contraste, ARIA) definido no spec? [Gap]
- [ ] CHK049 - O critério SC-006 (200ms para operações locais) é suficientemente claro sobre quais operações se qualificam como "locais" vs. "dependentes da API"? [Clarity, Spec §SC-006]

---

## Edge Case Coverage

- [ ] CHK050 - O spec endereça o que acontece quando o backend sobe mas retorna erros inesperados (ex.: 500) em qualquer endpoint? [Coverage, Spec §FR-004]
- [ ] CHK051 - Há requisito para comportamento da interface após perda de conexão com o backend no meio de uma operação (ex.: salvar anotação)? [Exception Flow, Gap]
- [ ] CHK052 - O spec define o comportamento da interface durante o primeiro acesso (base completamente vazia — zero units, zero tópicos)? [Edge Case, Coverage]

---

## Dependencies & Assumptions

- [ ] CHK053 - A assunção "backend expõe API em http://localhost:8080 configurável por env var" está refletida em algum requisito funcional ou apenas em Assumptions? [Traceability, Spec §Assumptions]
- [ ] CHK054 - A assunção de que o formato de exportação é inteiramente do backend está documentada de forma que seja verificável (não há requisito de frontend sobre o conteúdo exportado)? [Assumption, Spec §Assumptions]
- [ ] CHK055 - O spec documenta a dependência do Docker como pré-requisito para o start.sh? [Dependency, Spec §US7-AC1]

---

## Notes

- Itens marcados `[Gap]` indicam requisitos ausentes que devem ser resolvidos antes de iniciar o plan.
- Itens marcados `[Consistency]` indicam possíveis conflitos entre seções que precisam de alinhamento.
- Itens CHK031 e CHK044 são os de maior impacto: o SC-003 pode criar expectativas incorretas sobre geração assíncrona.
- Marque com `[x]` ao validar; anote `[ISSUE: descrição]` se o item falhar.
