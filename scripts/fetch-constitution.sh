#!/usr/bin/env bash
# fetch-constitution.sh — obtém o CONSTITUTION.md canônico do repo de arquitetura,
# materializa em .specify/memory/constitution.md e imprime a VERSÃO semântica + o SHA do commit.
#
# Fonte: usa repos.arquitetura_referencia.local_path se configurado e existente (alinhado ao
# "tudo roda localmente"); senão clona repos.arquitetura_referencia.url. Leitura determinística,
# nunca inferência por LLM.
#
# Saída (stdout, últimas linhas):
#   ARQUITETURA_VERSION=<x.y.z>
#   CONSTITUTION_SHA=<sha>
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT/harness.config.json"
DEST="$ROOT/.specify/memory/constitution.md"

cfg() {
  python3 -c "import json; d=json.load(open('$CONFIG'));
keys='$1'.split('.');
v=d
[v:=v[k] for k in keys];
print(v if v is not None else '')"
}

REPO_URL="$(cfg repos.arquitetura_referencia.url)"
BRANCH="$(cfg repos.arquitetura_referencia.branch)"
CPATH="$(cfg repos.arquitetura_referencia.constitution_path)"
LOCAL_PATH="$(cfg repos.arquitetura_referencia.local_path || true)"

SRC=""
SHA=""
SOURCE_DESC=""
CLEANUP=""

if [ -n "${LOCAL_PATH:-}" ] && [ -f "$LOCAL_PATH/$CPATH" ]; then
  # ---- Fonte LOCAL ----
  SRC="$LOCAL_PATH/$CPATH"
  SOURCE_DESC="local:$LOCAL_PATH"
  echo "==> Constituição (fonte local): $SRC" >&2
  if git -C "$LOCAL_PATH" rev-parse --git-dir >/dev/null 2>&1; then
    SHA="$(git -C "$LOCAL_PATH" rev-parse HEAD 2>/dev/null || echo 'local-uncommitted')"
    # Avisa se o CONSTITUTION.md local tem mudanças não commitadas (o SHA não as reflete).
    if ! git -C "$LOCAL_PATH" diff --quiet -- "$CPATH" 2>/dev/null; then
      echo "   AVISO: $CPATH tem mudanças não commitadas; o SHA pode não refletir o conteúdo atual." >&2
      SHA="${SHA}+dirty"
    fi
  else
    SHA="local-nogit"
  fi
else
  # ---- Fonte REMOTA (clone) ----
  if [ -n "${LOCAL_PATH:-}" ]; then
    echo "==> local_path configurado mas sem $CPATH; caindo para clone remoto." >&2
  fi
  echo "==> Constituição (fonte remota): $REPO_URL ($BRANCH) :: $CPATH" >&2
  TMP="$(mktemp -d)"; CLEANUP="$TMP"; trap 'rm -rf "$CLEANUP"' EXIT
  if ! git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP/arch" >/dev/null 2>&1; then
    echo "!! Não consegui clonar o repo de arquitetura. Verifique auth/permissões/rede." >&2
    exit 2
  fi
  SRC="$TMP/arch/$CPATH"
  SOURCE_DESC="remote:$REPO_URL@$BRANCH"
  if [ ! -f "$SRC" ]; then
    echo "" >&2
    echo "!! O repo de arquitetura NÃO tem '$CPATH' ainda." >&2
    echo "   BOOTSTRAP necessário: copie templates/CONSTITUTION.template.md para o repo de" >&2
    echo "   arquitetura como '$CPATH', preencha as regras e commite. Depois rode de novo." >&2
    echo "   (A constituição é explícita e escrita à mão; não é inferida de código.)" >&2
    exit 3
  fi
  SHA="$(cd "$TMP/arch" && git rev-parse HEAD)"
fi

# Extrai a versão semântica do marcador: <!-- arquitetura_version: X.Y.Z -->
VERSION="$(grep -oE 'arquitetura_version:[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+' "$SRC" | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)"
[ -z "$VERSION" ] && VERSION="desconhecida"

# Materializa com cabeçalho de proveniência.
{
  echo "<!-- MATERIALIZADO em $(TZ=America/Sao_Paulo date '+%Y-%m-%d %H:%M:%S') (UTC-3) -->"
  echo "<!-- Fonte: $SOURCE_DESC :: $CPATH -->"
  echo "<!-- arquitetura_version: $VERSION -->"
  echo "<!-- constitution_sha: $SHA -->"
  echo "<!-- NÃO EDITE AQUI. Edite o CONSTITUTION.md no repo de arquitetura. -->"
  echo ""
  cat "$SRC"
} > "$DEST"

echo "   Materializada em $DEST (versão $VERSION, sha ${SHA:0:12})" >&2
echo "ARQUITETURA_VERSION=$VERSION"
echo "CONSTITUTION_SHA=$SHA"
