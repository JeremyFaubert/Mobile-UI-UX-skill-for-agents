#!/usr/bin/env bash
set -euo pipefail

scope="project"
target="both"
project="$(pwd)"
skill_name="mobile-ui-ux-designer"
source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: ./install.sh [--scope project|user] [--target codex|claude|both] [--project PATH]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope) scope="$2"; shift 2 ;;
    --target) target="$2"; shift 2 ;;
    --project) project="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

[[ "$scope" == "project" || "$scope" == "user" ]] || { echo "Invalid scope" >&2; exit 2; }
[[ "$target" == "codex" || "$target" == "claude" || "$target" == "both" ]] || { echo "Invalid target" >&2; exit 2; }

install_skill() {
  local destination="$1"
  if [[ "$(cd "$(dirname "$destination")" 2>/dev/null && pwd)/$(basename "$destination")" == "$source_dir" ]]; then
    echo "Refusing to replace the source directory: $source_dir" >&2
    exit 2
  fi
  rm -rf "$destination"
  mkdir -p "$destination"
  for item in SKILL.md README.md NOTICE.md references assets scripts evals; do
    if [[ -e "$source_dir/$item" ]]; then
      cp -R "$source_dir/$item" "$destination/"
    fi
  done
  echo "Installed $skill_name -> $destination"
}

if [[ "$scope" == "project" ]]; then
  project="$(cd "$project" && pwd)"
  [[ "$target" == "codex" || "$target" == "both" ]] && install_skill "$project/.agents/skills/$skill_name"
  [[ "$target" == "claude" || "$target" == "both" ]] && install_skill "$project/.claude/skills/$skill_name"
else
  [[ "$target" == "codex" || "$target" == "both" ]] && install_skill "$HOME/.agents/skills/$skill_name"
  [[ "$target" == "claude" || "$target" == "both" ]] && install_skill "$HOME/.claude/skills/$skill_name"
fi

echo "Done. Restart the coding agent if the skill does not appear automatically."
