#!/usr/bin/env bash
# metrics.sh — utilitários de telemetria da esteira.
#
# Subcomandos:
#   now                              -> imprime componentes de data/hora em UTC-3 (p/ naming de branch)
#   slug "texto livre"               -> sugere um slug de três palavras (heurístico; revise)
#   diffstat <repo_dir> <base> <head>-> JSON com arquivos e testes criados/alterados/excluídos
#
# Observações:
# - 'diffstat' compara dois refs git (ex: main e a branch de implementação).
# - A classificação de "teste" é heurística por caminho; ajuste TEST_REGEX à sua stack.
# - Contagem de testes que PASSARAM/FALHARAM vem do runner de testes (pytest/jest/etc.),
#   não daqui — capture a saída do runner na Etapa 3 e combine com este diffstat.
set -euo pipefail

TEST_REGEX='(^|/)(tests?|__tests__|spec)(/|$)|\.(test|spec)\.[a-zA-Z0-9]+$|_test\.[a-zA-Z0-9]+$|test_.*\.[a-zA-Z0-9]+$'

cmd_now() {
  echo "yyyymmdd=$(TZ=America/Sao_Paulo date '+%Y%m%d')"
  echo "hhmmss=$(TZ=America/Sao_Paulo date '+%H%M%S')"
  echo "iso=$(TZ=America/Sao_Paulo date '+%Y-%m-%dT%H:%M:%S%z')"
}

cmd_slug() {
  local text="${1:-}"
  echo "$text" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cs 'a-z0-9' ' ' \
    | awk '{ n = (NF<3?NF:3); for (i=1;i<=n;i++){ printf "%s%s", $i, (i<n?"-":"") } }'
  echo ""
}

cmd_diffstat() {
  local repo="$1" base="$2" head="$3"
  cd "$repo"

  # Lista de mudanças com status (A=added, M=modified, D=deleted, R=renamed).
  # Usamos name-status para classificar.
  local raw
  raw="$(git diff --name-status "$base" "$head")"

  echo "$raw" | python3 - "$TEST_REGEX" <<'PY'
import sys, re, json
test_regex = re.compile(sys.argv[1])
raw = sys.stdin.read().splitlines()

counts = {"criados":0,"alterados":0,"excluidos":0}
tcounts = {"criados":0,"alterados":0,"excluidos":0}

def bump(c, status):
    if status.startswith("A"): c["criados"] += 1
    elif status.startswith("M"): c["alterados"] += 1
    elif status.startswith("D"): c["excluidos"] += 1
    elif status.startswith("R"): c["alterados"] += 1  # rename conta como alteração

for line in raw:
    if not line.strip(): continue
    parts = line.split("\t")
    status = parts[0]
    path = parts[-1]  # para rename, o destino é o último campo
    bump(counts, status)
    if test_regex.search(path):
        bump(tcounts, status)

print(json.dumps({"arquivos": counts, "testes": tcounts}, ensure_ascii=False))
PY
}

case "${1:-}" in
  now)      cmd_now ;;
  slug)     shift; cmd_slug "${1:-}" ;;
  diffstat) shift; cmd_diffstat "${1:?repo}" "${2:?base}" "${3:?head}" ;;
  *) echo "uso: metrics.sh {now | slug \"texto\" | diffstat <repo> <base> <head>}" >&2; exit 1 ;;
esac
