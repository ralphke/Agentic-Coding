#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
cleanup() {
  rm -f "$tmp/bin/docker" "$tmp/bin/wslc" "$tmp/engine.log" \
    "$tmp/.devcontainer/devcontainer-workflow.sh" "$tmp/.devcontainer/devcontainer.json" \
    "$tmp/.devcontainer/devcontainer.json.bak" "$tmp/.devcontainer/devcontainer-wslc.json"
  rmdir "$tmp/bin" "$tmp/.devcontainer" "$tmp"
}
trap cleanup EXIT

mkdir "$tmp/bin" "$tmp/.devcontainer"
cp "$root/.devcontainer/devcontainer-workflow.sh" "$tmp/.devcontainer/"
printf 'original\n' > "$tmp/.devcontainer/devcontainer.json"
printf 'wsl config\n' > "$tmp/.devcontainer/devcontainer-wslc.json"
cat > "$tmp/bin/docker" <<'EOF'
#!/usr/bin/env bash
printf 'docker %s\n' "$*" >> "$ENGINE_LOG"
EOF
cat > "$tmp/bin/wslc" <<'EOF'
#!/usr/bin/env bash
printf 'wslc %s\n' "$*" >> "$ENGINE_LOG"
if [[ "${FAIL_INSPECT:-0}" == 1 && "$1 $2" == "image inspect" ]]; then exit 1; fi
EOF
chmod +x "$tmp/bin/docker" "$tmp/bin/wslc"
export PATH="$tmp/bin:$PATH" ENGINE_LOG="$tmp/engine.log"
script="$tmp/.devcontainer/devcontainer-workflow.sh"

cd "$tmp/bin"
bash "$script" build test
DEVCONTAINER_ENGINE=wslc bash "$script" build-and-push test
grep -Fx 'docker build -f .devcontainer/Dockerfile -t ghcr.io/ralphke/agentic-coding-image:test .' "$ENGINE_LOG"
grep -Fx 'wslc build -f .devcontainer/Dockerfile -t ghcr.io/ralphke/agentic-coding-image:test .' "$ENGINE_LOG"
grep -Fx 'wslc image inspect ghcr.io/ralphke/agentic-coding-image:test' "$ENGINE_LOG"
grep -Fx 'wslc push ghcr.io/ralphke/agentic-coding-image:test' "$ENGINE_LOG"

if FAIL_INSPECT=1 DEVCONTAINER_ENGINE=wslc bash "$script" push missing; then
  echo "Missing image unexpectedly pushed" >&2
  exit 1
fi
if DEVCONTAINER_ENGINE=invalid bash "$script" build; then
  echo "Invalid engine unexpectedly accepted" >&2
  exit 1
fi

bash "$script" use-wslc
grep -Fx 'original' "$tmp/.devcontainer/devcontainer.json.bak"
grep -Fx 'wsl config' "$tmp/.devcontainer/devcontainer.json"
bash "$script" use-wslc
printf 'changed\n' > "$tmp/.devcontainer/devcontainer.json"
if bash "$script" use-wslc; then
  echo "Existing backup unexpectedly overwritten" >&2
  exit 1
fi
grep -Fx 'original' "$tmp/.devcontainer/devcontainer.json.bak"
grep -Fx 'changed' "$tmp/.devcontainer/devcontainer.json"
echo "Devcontainer workflow tests passed"
