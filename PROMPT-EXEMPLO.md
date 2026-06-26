# Prompt de Exemplo

Exemplo pronto para um primeiro teste ponta a ponta da esteira. É uma demanda **pequena**, mas com
tudo que a Etapa 1 precisa: contexto, requisitos, critérios de aceite testáveis e o repo-alvo.

> A esteira constrói **software**. Por isso a necessidade ("estudar inglês além das aulas") vira a
> demanda de uma **ferramenta** a ser implementada.

## Como usar este exemplo

1. Crie (vazio) o repo-alvo no GitHub: `ingles-study-companion` (ou aponte para um já existente).
2. No Claude Code, com a esteira aberta, rode `/run`.
3. Cole o bloco abaixo.

## Prompt

```
Demanda: Assistente local de estudos de inglês com base de conhecimento contínua

Contexto: Atualmente estudo inglês com duas aulas ao vivo por semana, usando PDFs fornecidos pela professora. Ao final de cada unidade, recebo o material da unit e um PDF separado de homework, que preencho e envio para correção. Também faço anotações constantes das aulas separadas por unidade. Quero um sistema local, rodando apenas no meu computador, que organize esse material, salve tudo que for gerado e reutilize essa base sempre que for iniciado novamente, criando uma memória contínua dos meus estudos.

Requisitos:

* Permitir cadastrar uma nova unit de estudo com título, número, data, status e observações gerais.
* Permitir anexar, para cada unit, o PDF da aula/material principal.
* Permitir anexar, para cada unit, o PDF de homework preenchido.
* Permitir anexar ou registrar a correção do homework feita pela professora.
* Permitir criar, editar e salvar anotações livres da aula separadas por unit.
* Salvar localmente todos os dados gerados pelo sistema, incluindo resumos, exercícios, flashcards, listas de erros, vocabulário e progresso.
* Criar uma base de conhecimento local que seja consultada sempre que o sistema for iniciado.
* Usar a base local existente como contexto para novas gerações, evitando recomeçar do zero.
* Alimentar continuamente a base local com novos materiais, novas anotações, novas correções e novos conteúdos gerados.
* Organizar os arquivos em uma estrutura local clara, por exemplo: units/unit-01/material.pdf, homework.pdf, correction.pdf, notes.md, summary.md, exercises.md e flashcards.json.
* Extrair ou permitir registrar os principais temas de cada unit, como gramática, vocabulário, expressões, pronúncia e erros recorrentes.
* Gerar uma revisão resumida da unit com base nos materiais, anotações e histórico salvo.
* Gerar exercícios de prática com base no conteúdo da unit e também nos erros recorrentes de units anteriores.
* Gerar flashcards de vocabulário e expressões relevantes da unit.
* Criar uma lista consolidada de erros recorrentes identificados nos homeworks corrigidos e nas anotações.
* Permitir marcar conteúdos como “revisado”, “preciso reforçar” ou “dominado”.
* Ter uma visão geral do progresso por unit, mostrando quais materiais existem, quais homeworks foram feitos/corrigidos e quais conteúdos ainda precisam de revisão.
* Permitir busca por palavra-chave nas anotações, temas, vocabulário, exercícios, flashcards e erros recorrentes.
* Funcionar localmente no computador, sem exigir armazenamento em nuvem, login ou banco de dados online.
* Permitir exportar ou visualizar os conteúdos gerados em formatos simples e legíveis, como Markdown, JSON ou PDF.

Critérios de aceite:

* O usuário consegue criar uma nova unit informando título e número da unidade.
* O sistema cria automaticamente uma pasta local para cada unit criada.
* O usuário consegue anexar pelo menos um PDF de material e um PDF de homework a uma unit.
* O usuário consegue registrar anotações em texto para uma unit e editá-las posteriormente.
* O sistema salva automaticamente as anotações, resumos, exercícios, flashcards e listas de erros gerados.
* Após fechar e abrir novamente o sistema, todos os dados cadastrados e gerados anteriormente continuam disponíveis.
* Ao reiniciar, o sistema carrega a base local existente e consegue consultar units anteriores.
* O sistema consegue gerar novos exercícios considerando erros recorrentes já salvos de units anteriores.
* O sistema consegue exibir, para uma unit específica, os arquivos vinculados, as anotações, os temas registrados e os conteúdos gerados.
* O sistema consegue gerar um resumo de revisão da unit com base nas anotações cadastradas e no histórico salvo.
* O sistema consegue gerar pelo menos 5 exercícios de prática a partir do conteúdo registrado na unit.
* O sistema consegue gerar pelo menos 10 flashcards de vocabulário ou expressões a partir da unit.
* O usuário consegue marcar uma unit ou tema como “revisado”, “preciso reforçar” ou “dominado”.
* O sistema consegue exibir uma lista consolidada de erros recorrentes por unit e também uma visão geral de todos os erros.
* A busca por palavra-chave retorna units, anotações, vocabulários, exercícios ou erros relacionados ao termo pesquisado.
* A estrutura de arquivos gerada é legível e pode ser acessada manualmente pelo usuário fora do sistema.
* O sistema funciona sem depender de internet para acessar os arquivos já salvos localmente.



Repositório-alvo: /Users/lucavpa/Documents/tech/gen-ai/projects/english-partner
(branch base: main; branch de implementação: criar a partir da main)

Repositório-refinamento: /Users/lucavpa/Documents/tech/gen-ai/refinamentos-gen-ai

```

## O que esperar

- A Etapa 1 deve reconhecer este perfil como **COMPLETO** (não há link de spec) e provavelmente fará
  uma ou duas perguntas de refinamento antes do gate.
- Os critérios são estruturais de propósito (arquivo válido, ≥10 vocábulos, 3 tipos, sem duplicar
  homework, gabarito separado, comportamento de CLI), então dá para testar mesmo que o miolo use um
  LLM.
