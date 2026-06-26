# Quickstart — Guia de Validação: English Partner View

**Feature**: `specs/002-criacao-frontend-view`
**Date**: 2026-06-22

Este guia descreve como validar que a feature foi implementada corretamente end-to-end, sem incluir código de implementação.

---

## Pré-requisitos

1. Node.js ≥ 20 instalado (`node --version`)
2. Backend `english-partner-backend` em execução (`http://localhost:8080/actuator/health` retorna `UP`)
3. Diretório `english-partner-view/` com o projeto inicializado (`npm install` concluído)

---

## Setup do Frontend

```bash
cd english-partner-view
cp .env.example .env.local     # VITE_API_URL=http://localhost:8080
npm install
npm run dev                    # inicia em http://localhost:5173
```

---

## Cenários de Validação

### V1 — Bootstrap completo via script raiz

```bash
cd english-partner/            # diretório raiz
./start.sh
```

**Resultado esperado**:
- Terminal exibe passo a passo (backend → health check → frontend)
- Ao final: URLs do backend (Swagger UI) e do frontend impressas
- `http://localhost:5173` abre no navegador e exibe a Visão Geral

```bash
./stop.sh
```

**Resultado esperado**: frontend encerrado, containers do backend parados, dados preservados.

---

### V2 — Criar e listar uma unit

1. Abrir `http://localhost:5173/#/units`
2. Clicar em "Nova unit"
3. Preencher: número=1, título="Present Perfect", data=hoje, status=AGENDADA
4. Confirmar

**Resultado esperado**: unit aparece na listagem com número, título e status.

---

### V3 — Detalhe da unit, anotação e tópico

1. Clicar na unit criada em V2
2. Editar a nota com texto Markdown: `# Notas\n\n**Conteúdo importante**`
3. Salvar a nota
4. Adicionar tópico: tipo=VOCABULARY, label="present perfect continuous", status=PRECISO_REFORCAR
5. Salvar tópicos
6. Alterar status do tópico para DOMINADO

**Resultado esperado**:
- Nota exibe o HTML renderizado do Markdown ao salvar
- Tópico aparece na lista com status DOMINADO após alteração

---

### V4 — Anexar PDF de material

1. Na tela da unit, clicar em "Anexar material"
2. Selecionar qualquer arquivo PDF local
3. Confirmar upload

**Resultado esperado**: arquivo listado em "Anexos" com tipo MATERIAL.

---

### V5 — Registrar erros recorrentes e visualizar lista consolidada

1. Na tela da unit, registrar um erro: label="confundir 'since' e 'for'", categoria=grammar
2. Salvar
3. Navegar para `#/errors`

**Resultado esperado**: erro aparece na lista consolidada com unit de origem.

---

### V6 — Geração de conteúdo

1. Com material anexado na unit, clicar em "Gerar resumo"
2. Aguardar indicador de carregamento

**Resultado esperado**: após conclusão, referência ao resumo aparece em "Conteúdos gerados" com tipo, data e contagem.

---

### V7 — Exportação

1. Na tela da unit com conteúdo gerado, clicar em "Exportar"
2. Selecionar formato Markdown

**Resultado esperado**: download de arquivo `.md` inicia automaticamente.

---

### V8 — Progresso global

1. Criar mais de uma unit em estados diferentes
2. Navegar para `#/progress`

**Resultado esperado**: cada unit exibe indicadores de material, homework, correção e tópicos pendentes.

---

### V9 — Busca

1. Com units e tópicos cadastrados, navegar para `#/search`
2. Digitar "present" e buscar

**Resultado esperado**: resultados agrupados por tipo (ex.: VOCABULARY, UNIT) com snippets.

---

### V10 — Estados de erro

1. Parar o backend
2. Tentar criar uma unit no frontend

**Resultado esperado**: mensagem "Não foi possível conectar ao backend" sem tela em branco.

---

## Testes automatizados

```bash
# Unitários
npm run test

# E2E (requer backend em execução)
npm run test:e2e
```

**Critério de merge**: `npm run test` passa 100% (zero falhas). E2E: smoke test V2+V3 passando.

---

## Referências

- [Contrato da API](contracts/api-contract.md)
- [Data Model](data-model.md)
- [Spec](spec.md)
