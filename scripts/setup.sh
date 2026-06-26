#!/usr/bin/env bash
# setup.sh — instala os comandos do Spec Kit e puxa skills compartilhadas.
# Normalmente chamado pelo bootstrap.sh, mas pode rodar sozinho.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT/harness.config.json"

cfg() {
  python3 -c "import json,sys; d=json.load(open('$CONFIG'));
keys='$1'.split('.');
v=d
[v:=v[k] for k in keys];
print(v if v is not None else '')"
}

echo "==> Harness em: $ROOT"

# 1) Spec Kit ---------------------------------------------------------------
# A CLI 'specify' (github/spec-kit) instala as skills speckit-*/ em .claude/skills/
# e a estrutura .specify/. NÃO escrevemos esses comandos à mão — eles vêm do toolkit.
echo "==> Instalando/atualizando comandos do Spec Kit..."
if command -v specify >/dev/null 2>&1; then
  SPECIFY="specify"
elif command -v uvx >/dev/null 2>&1; then
  SPECIFY="uvx --from git+https://github.com/github/spec-kit.git specify"
else
  echo "!! Nem 'specify' nem 'uvx' encontrados. Rode o bootstrap (check-prereqs) ou instale o uv."
  exit 1
fi

# Preserva TODOS os arquivos NOSSOS que o 'specify init --force' poderia sobrescrever ao mesclar
# num diretório não-vazio. Colisões conhecidas: CLAUDE.md e .specify/memory/constitution.md (o
# Spec Kit gera os dois a partir de templates próprios). Por segurança, blindamos também nossos
# comandos de orquestração, agents, settings e o .gitignore (que ignora o workspace/). Se o Spec
# Kit não tocar neles, o restore lá embaixo é um no-op inofensivo. NUNCA listamos as skills speckit-*
# aqui — essas são do Spec Kit e devem ser (re)geradas por ele.
BACKUP="$(mktemp -d)"
PRESERVE=(
  "CLAUDE.md"
  ".gitignore"
  ".specify/memory/constitution.md"
  ".claude/settings.json"
  ".claude/commands/run.md"
  ".claude/commands/etapa1.md"
  ".claude/commands/etapa2.md"
  ".claude/commands/etapa3.md"
  ".claude/agents"
)
for rel in "${PRESERVE[@]}"; do
  if [ -e "$ROOT/$rel" ]; then
    mkdir -p "$BACKUP/$(dirname "$rel")"
    cp -R "$ROOT/$rel" "$BACKUP/$rel"
  fi
done

# A flag de agente mudou entre versões do Spec Kit:
#   recentes: --integration claude   |   antigas: --ai claude
# --force: mescla em diretório não-vazio sem confirmação.
# --ignore-agent-tools: não falha se a CLI 'claude' não estiver no PATH desta shell.
init_ok=0
for FLAG in "--integration" "--ai"; do
  if ( cd "$ROOT" && $SPECIFY init --here "$FLAG" claude --force --ignore-agent-tools ); then
    init_ok=1; echo "   ok ($FLAG claude)"; break
  fi
  echo "   (tentativa com $FLAG falhou; tentando alternativa...)"
done

# Restaura nossos arquivos, caso o init os tenha sobrescrito (no-op se o Spec Kit não tocou neles).
for rel in "${PRESERVE[@]}"; do
  [ -e "$BACKUP/$rel" ] || continue
  if [ -d "$BACKUP/$rel" ]; then
    mkdir -p "$ROOT/$rel"
    cp -R "$BACKUP/$rel/." "$ROOT/$rel/"
  else
    mkdir -p "$ROOT/$(dirname "$rel")"
    cp "$BACKUP/$rel" "$ROOT/$rel"
  fi
done
rm -rf "$BACKUP"

if [ "$init_ok" -ne 1 ]; then
  echo "!! Falha ao inicializar o Spec Kit com --integration e com --ai."
  echo "   Veja as opções da sua versão: $SPECIFY init --help"
  exit 1
fi
echo "   Skills speckit-* instaladas em .claude/skills (CLAUDE.md e constituição preservados)."

# 2) Skills compartilhadas (opcional) ---------------------------------------
SKILLS_URL="$(cfg skills_compartilhadas.url || true)"
if [ -n "${SKILLS_URL:-}" ]; then
  SKILLS_BRANCH="$(cfg skills_compartilhadas.branch || echo main)"
  echo "==> Puxando skills compartilhadas de $SKILLS_URL ($SKILLS_BRANCH)..."
  TMP="$(mktemp -d)"
  git clone --depth 1 --branch "$SKILLS_BRANCH" "$SKILLS_URL" "$TMP/shared"
  if [ -d "$TMP/shared/skills" ]; then cp -Rn "$TMP/shared/skills/." "$ROOT/.claude/skills/" 2>/dev/null || true; fi
  if [ -d "$TMP/shared/agents" ]; then cp -Rn "$TMP/shared/agents/." "$ROOT/.claude/agents/" 2>/dev/null || true; fi
  rm -rf "$TMP"
  echo "   Skills/agents compartilhados mesclados."
else
  echo "==> Sem repo de skills compartilhadas configurado (usando apenas o acervo local)."
fi

echo "==> setup.sh concluído."
