# ADR-001: Persistência híbrida — filesystem fonte da verdade + DynamoDB índice

- **Demanda (slug):** assistente-estudos-ingles
- **Run ID:** 0C7ED1DD-841A-4047-8D56-E02D2A99AE8C
- **Data (UTC-3):** 2026-06-20
- **Status:** aceita
- **Tipo:** decisão de design (resolve tensão demanda × constituição — **a favor da constituição**)

## Contexto

A demanda exige (critério de aceite SC-007 / FR-007) uma "estrutura de arquivos legível, acessível
manualmente fora do sistema" (`units/unit-NN/material.pdf, notes.md, flashcards.json...`). A
constituição §4 exige **DynamoDB on-demand**, com acesso **somente via repositório**. Tomar os dois
ao pé da letra parece conflitar: arquivos legíveis vs. banco DynamoDB.

## Decisão

Adotar persistência **híbrida**: a árvore `data/units/unit-NN/` no filesystem é a **fonte da verdade**
dos artefatos (PDFs e conteúdos `.md`/`.json`); o **DynamoDB** (on-demand, single-table, emulado por
LocalStack) guarda **metadados, índice de busca e progresso** — sempre acessado via camada de
repositório. O índice no DynamoDB é **derivado e reconstruível** a partir do disco.

## Alternativas consideradas

- **Só-arquivos (sem DynamoDB)** — rejeitada: viola §4.
- **Só-DynamoDB, com export sob demanda** — rejeitada: viola SC-007/FR-007 ("acessível manualmente
  fora do sistema" como estrutura viva, não export pontual).

## Consequências

- Satisfaz simultaneamente o critério de aceite e §4. Trade-off: dupla escrita (disco + índice) e
  necessidade de reconciliação na inicialização (o disco vence). Aceito.
- Busca (FR-018) usa o índice DynamoDB; se corrompido/ausente, é reconstruído lendo `data/`.

## Se for exceção constitucional

Não é exceção — **cumpre** a constituição (§4 atendida via DynamoDB; nada é excepcionado). Apenas
registra a conciliação com o requisito de arquivos legíveis.
