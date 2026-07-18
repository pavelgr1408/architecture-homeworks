#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

rm -rf .cache/rendered
mkdir -p .cache/rendered/plantuml .cache/rendered/structurizr

while IFS= read -r -d '' homework_dir; do
  slug="$(basename "$homework_dir")"

  if [[ -d "$homework_dir/plantuml" ]] && find "$homework_dir/plantuml" -maxdepth 1 -name '*.puml' -print -quit | grep -q .; then
    mkdir -p ".cache/rendered/plantuml/$slug"
    docker run --rm \
      --user "$(id -u):$(id -g)" \
      -v "$ROOT_DIR:/workspace" \
      -w /workspace \
      plantuml/plantuml:1.2025.4 \
      -tsvg \
      -charset UTF-8 \
      -o "/workspace/.cache/rendered/plantuml/$slug" \
      "/workspace/$homework_dir/plantuml/"*.puml
  fi

  workspace="$homework_dir/structurizr/workspace.json"
  if [[ -f "$workspace" ]]; then
    mkdir -p ".cache/rendered/structurizr/$slug"

    docker run --rm \
      --user 0:0 \
      -v "$ROOT_DIR:/usr/local/structurizr" \
      structurizr/structurizr:latest \
      validate \
      -workspace "/usr/local/structurizr/$workspace"

    docker run --rm \
      --user 0:0 \
      -v "$ROOT_DIR:/usr/local/structurizr" \
      structurizr/structurizr:latest \
      export \
      -workspace "/usr/local/structurizr/$workspace" \
      -format static \
      -output "/usr/local/structurizr/.cache/rendered/structurizr/$slug"

    chown -R "$(id -u):$(id -g)" ".cache/rendered/structurizr/$slug" 2>/dev/null || true
  fi
done < <(find homeworks -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
