#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Install pre-commit hook for g doctor
# -----------------------------------------------------------------------------

# Only run inside a git repository
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

HOOK_DIR=".git/hooks"
HOOK_FILE="$HOOK_DIR/pre-commit"

echo "Installing git pre-commit hook for g doctor..."

mkdir -p "$HOOK_DIR"

cat > "$HOOK_FILE" <<'EOF'
#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Pre-commit hook: g doctor
#
# Rules:
# - Only run when there are staged changes
# - Skip metadata-only commits (e.g. commit --amend message)
# - Be completely silent when green
# -----------------------------------------------------------------------------

# No staged changes → nothing to validate
if git diff --cached --quiet; then
  exit 0
fi

# Run g doctor in a controlled zsh environment
if ! zsh -c '
  source ~/.zshrc
  g doctor
' >/dev/null 2>&1; then
  echo
  echo "❌ g doctor failed. Aborting commit."
  exit 1
fi

exit 0
EOF

chmod +x "$HOOK_FILE"

echo "Pre-commit hook installed."
