#!/usr/bin/env bash
# bootstrap.sh — ponto de entrada ÚNICO do setup da esteira.
#
# Roda, em ordem:
#   1) check-prereqs.sh  — verifica as ferramentas (aborta se faltar obrigatório)
#   2) chmod +x          — dá permissão de execução a todos os scripts
#   3) setup.sh          — instala os comandos do Spec Kit (+ skills compartilhadas)
#   4) fetch-constitution.sh — materializa a constituição e imprime versão + SHA
#
# PRIMEIRA VEZ (os scripts ainda não têm +x): rode com  ->  bash scripts/bootstrap.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "======================================================"
echo " Bootstrap — Esteira de Refinamento e Desenvolvimento"
echo " Diretório: $ROOT"
echo "======================================================"

# 1) Pré-requisitos — aborta aqui se faltar algo obrigatório.
echo ""
bash "$ROOT/scripts/check-prereqs.sh"

# 2) Permissões executáveis para todos os scripts.
echo ""
echo "==> Tornando os scripts executáveis (chmod +x scripts/*.sh)..."
chmod +x "$ROOT"/scripts/*.sh
echo "   ok"

# 3) Spec Kit + skills compartilhadas.
echo ""
"$ROOT/scripts/setup.sh"

# 4) Verificação: materializar a constituição (versão + SHA).
echo ""
echo "==> Verificando a constituição..."
if "$ROOT/scripts/fetch-constitution.sh"; then
  echo "   Constituição materializada com sucesso."
else
  echo ""
  echo "!! fetch-constitution.sh falhou (ex: CONSTITUTION.md ausente, sem auth ou sem rede)."
  echo "   Resolva conforme a mensagem acima e rode novamente: bash scripts/bootstrap.sh"
  exit 1
fi

echo ""
echo "======================================================"
echo " Bootstrap concluído."
echo " Abra o Claude Code neste diretório e rode /run."
echo "======================================================"
