#!/usr/bin/env bash
# scorecard-trend.sh — agrega o quality-log.jsonl e mostra a tendência de qualidade do harness.
#
# uso: scorecard-trend.sh <caminho/para/quality-log.jsonl>
#
# Compara notas apenas dentro da MESMA rubric_version (e idealmente mesma arquitetura_version):
# um bump de rubrica ou de arquitetura = quebra de série. Mostra médias por fase, por versão de
# rubrica e de arquitetura, e a evolução recente.
set -euo pipefail

LOG="${1:?informe o caminho do quality-log.jsonl}"
[ -f "$LOG" ] || { echo "!! Arquivo não encontrado: $LOG" >&2; exit 1; }

python3 - "$LOG" <<'PY'
import sys, json
from collections import defaultdict

rows = []
with open(sys.argv[1]) as f:
    for line in f:
        line = line.strip()
        if not line: continue
        try: rows.append(json.loads(line))
        except json.JSONDecodeError: pass

if not rows:
    print("Log vazio."); raise SystemExit(0)

print(f"Total de registros: {len(rows)}\n")

# Agrupa por (rubric_version, arquitetura_version, fase)
groups = defaultdict(list)
for r in rows:
    groups[(r.get("rubric_version","?"), r.get("arquitetura_version","?"), r.get("fase","?"))].append(r)

print("== Média de nota por versão (rubrica + arquitetura) e fase ==")
for (rv, av, fase), items in sorted(groups.items()):
    notas = [i.get("nota_final") for i in items if isinstance(i.get("nota_final"), (int,float))]
    if notas:
        media = sum(notas)/len(notas)
        print(f"  rub {rv} | arq {av} | {fase:5} | n={len(notas):3} | média={media:.2f} | "
              f"min={min(notas):.1f} | max={max(notas):.1f}")

# Conformidade e testes (fase impl)
impl = [r for r in rows if r.get("fase")=="impl"]
if impl:
    fails = sum(1 for r in impl if (r.get("testes") or {}).get("falharam",0) > 0)
    nonconf = sum(1 for r in impl
                  if (r.get("conformidade") or {}).get("spec")=="FAIL"
                  or (r.get("conformidade") or {}).get("arquitetura")=="FAIL")
    print(f"\n== Saúde da implementação ({len(impl)} runs) ==")
    print(f"  runs com teste falhando: {fails}")
    print(f"  runs com não-conformidade: {nonconf}")

# Evolução recente (últimos 10 por timestamp)
print("\n== Últimos registros ==")
for r in sorted(rows, key=lambda x: x.get("ts",""))[-10:]:
    print(f"  {r.get('ts','?')[:19]} | {r.get('fase','?'):5} | "
          f"nota={r.get('nota_final','?'):>4} | rub={r.get('rubric_version','?')} | "
          f"arq={r.get('arquitetura_version','?')} | const={str(r.get('constitution_sha',''))[:7]} | "
          f"{r.get('slug','?')}")

# Sub-notas médias (ajuda a achar a dimensão fraca do harness)
print("\n== Sub-notas médias (onde o harness é mais fraco) ==")
sub = defaultdict(list)
for r in rows:
    for k, v in (r.get("subnotas") or {}).items():
        if isinstance(v,(int,float)): sub[k].append(v)
for k in sorted(sub):
    vals = sub[k]
    print(f"  {k}: média={sum(vals)/len(vals):.2f} (n={len(vals)})")
PY
