#!/usr/bin/env bash
# check-prereqs.sh — verifica as ferramentas de pré-requisito ANTES de qualquer setup.
# Sai com código != 0 se faltar algo obrigatório. Pode rodar sozinho ou via bootstrap.sh.
#
# Obrigatórios: git, python3, e (uv/uvx OU specify) para o Spec Kit.
# Recomendado:  gh (GitHub CLI) para abrir PRs.
#
# Nota: NÃO uso 'set -e' aqui de propósito — quero acumular e reportar TODAS as faltas de uma vez.
set -uo pipefail

miss_required=0

check() {
  # check <comando> <required|opcional> <dica>
  local cmd="$1" level="$2" hint="$3"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf "  [ok]      %-12s %s\n" "$cmd" "$(command -v "$cmd")"
  elif [ "$level" = "required" ]; then
    printf "  [FALTA]   %-12s (obrigatório) — %s\n" "$cmd" "$hint"
    miss_required=$((miss_required + 1))
  else
    printf "  [aviso]   %-12s (recomendado) — %s\n" "$cmd" "$hint"
  fi
}

echo "==> Verificando pré-requisitos..."

check git     required "instale o Git"
check python3 required "instale o Python 3"

# Spec Kit precisa de 'specify' OU de 'uv/uvx' (que roda o specify via uvx).
if command -v specify >/dev/null 2>&1; then
  printf "  [ok]      %-12s %s\n" "specify" "$(command -v specify)"
elif command -v uvx >/dev/null 2>&1 || command -v uv >/dev/null 2>&1; then
  printf "  [ok]      %-12s (disponível para rodar o Spec Kit)\n" "uv/uvx"
else
  printf "  [FALTA]   %-12s (obrigatório) — instale o uv (https://docs.astral.sh/uv/) ou a CLI specify\n" "uv|specify"
  miss_required=$((miss_required + 1))
fi

check gh opcional "GitHub CLI — recomendado para abrir PRs (https://cli.github.com/)"

echo ""
if [ "$miss_required" -gt 0 ]; then
  echo "!! Faltam $miss_required ferramenta(s) obrigatória(s). Instale-as e rode de novo."
  exit 1
fi
echo "Pré-requisitos obrigatórios OK."
exit 0
