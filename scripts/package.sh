#!/usr/bin/env bash
# Gera um .zip por skill em dist/, pronto para envio no aplicativo Claude.
# Cada zip contém a pasta da skill na raiz, com o SKILL.md dentro dela.
#
# Uso:
#   ./scripts/package.sh                 empacota todas
#   ./scripts/package.sh nome1 nome2     empacota somente as indicadas

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_DIR/skills"
OUT="$REPO_DIR/dist"
NAMES=("$@")

if [ ${#NAMES[@]} -eq 0 ]; then
  for d in "$SRC"/*/; do NAMES+=("$(basename "$d")"); done
fi

mkdir -p "$OUT"

for n in "${NAMES[@]}"; do
  [ -f "$SRC/$n/SKILL.md" ] || { echo "Skill inexistente: $n" >&2; exit 1; }
  rm -f "$OUT/$n.zip"
  if command -v zip >/dev/null 2>&1; then
    (cd "$SRC" && zip -qr "$OUT/$n.zip" "$n")
  else
    python3 - "$SRC" "$OUT" "$n" <<'PY'
import os, sys, zipfile
src, out, name = sys.argv[1:4]
with zipfile.ZipFile(os.path.join(out, name + ".zip"), "w", zipfile.ZIP_DEFLATED) as z:
    for root, _, files in os.walk(os.path.join(src, name)):
        for f in files:
            full = os.path.join(root, f)
            z.write(full, os.path.relpath(full, src))
PY
  fi
  echo "  gerado dist/$n.zip"
done

echo "Concluído. Envie os arquivos de dist/ em Configurações, na seção de Skills."
