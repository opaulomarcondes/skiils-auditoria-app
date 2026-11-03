#!/usr/bin/env bash
# Instala as skills do repositório no Claude Code.
#
# Uso:
#   ./scripts/install.sh                      instala todas em ~/.claude/skills
#   ./scripts/install.sh nome1 nome2          instala somente as skills indicadas
#   ./scripts/install.sh --link               usa links simbólicos (git pull atualiza)
#   ./scripts/install.sh --projeto DIR        instala em DIR/.claude/skills
#   ./scripts/install.sh --help

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_DIR/skills"
DEST="${HOME}/.claude/skills"
LINK=0
NAMES=()

usage() {
  sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
  case "$1" in
    --link) LINK=1 ;;
    --projeto)
      shift
      [ $# -gt 0 ] || { echo "Erro: --projeto exige um diretório." >&2; exit 1; }
      [ -d "$1" ] || { echo "Erro: diretório não encontrado: $1" >&2; exit 1; }
      DEST="$(cd "$1" && pwd)/.claude/skills"
      ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "Opção desconhecida: $1" >&2; usage; exit 1 ;;
    *) NAMES+=("$1") ;;
  esac
  shift
done

if [ ${#NAMES[@]} -eq 0 ]; then
  for d in "$SRC"/*/; do NAMES+=("$(basename "$d")"); done
fi

mkdir -p "$DEST"
echo "Destino: $DEST"

for n in "${NAMES[@]}"; do
  if [ ! -f "$SRC/$n/SKILL.md" ]; then
    echo "Skill inexistente neste repositório: $n" >&2
    exit 1
  fi
  rm -rf "${DEST:?}/$n"
  if [ "$LINK" -eq 1 ]; then
    ln -s "$SRC/$n" "$DEST/$n"
    echo "  link   $n"
  else
    cp -r "$SRC/$n" "$DEST/$n"
    echo "  copiada $n"
  fi
done

echo "Concluído. Reinicie a sessão do Claude Code para carregar as skills."
