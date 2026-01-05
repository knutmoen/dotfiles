# -----------------------------------------------------------------------------
# Tmux helpers + optional auto-attach
# -----------------------------------------------------------------------------

# Default session names / directories (override via env if needed)
: "${TMUX_DEFAULT_SESSION:=default}"
: "${FRONTEND_DIR:=}"
: "${BACKEND_DIR:=}"
: "${COMMANDS_DIR:=}"

# Attach to an existing session or create it (optional per-name dirs)
t() {
  local session="${1:-$TMUX_DEFAULT_SESSION}"
  local start_dir="$PWD"

  case "$session" in
    frontend) [[ -n "$FRONTEND_DIR" ]] && start_dir="$FRONTEND_DIR" ;;
    backend)  [[ -n "$BACKEND_DIR"  ]] && start_dir="$BACKEND_DIR" ;;
    commands) [[ -n "$COMMANDS_DIR" ]] && start_dir="$COMMANDS_DIR" ;;
  esac

  if tmux has-session -t "$session" 2>/dev/null; then
    tmux attach -t "$session"
  else
    tmux new -s "$session" -c "$start_dir"
  fi
}

# Bootstrap common sessions (if dirs are set)
tboot() {
  tmux start-server
  [[ -n "$FRONTEND_DIR" ]] && tmux has-session -t frontend 2>/dev/null || tmux new-session -d -s frontend -c "$FRONTEND_DIR"
  [[ -n "$BACKEND_DIR"  ]] && tmux has-session -t backend  2>/dev/null || tmux new-session -d -s backend  -c "$BACKEND_DIR"
  [[ -n "$COMMANDS_DIR" ]] && tmux has-session -t commands 2>/dev/null || tmux new-session -d -s commands -c "$COMMANDS_DIR"
}

alias tf='t frontend'
alias tb='t backend'
alias tc='t commands'
alias td='t dev'
alias tmuxstatus='[ -n "$TMUX" ] && echo "i tmux" || echo "ikke i tmux"'

# Auto-attach if tmux exists and we're not already inside tmux.
# Set TMUX_AUTO_ATTACH=0 to disable.
if command -v tmux >/dev/null 2>&1 && [[ -z "$TMUX" ]] && [[ "${TMUX_AUTO_ATTACH:-1}" != "0" ]]; then
  # Ensure default session exists, then attach
  tmux has-session -t "$TMUX_DEFAULT_SESSION" 2>/dev/null || tmux new-session -d -s "$TMUX_DEFAULT_SESSION"
  exec tmux attach -t "$TMUX_DEFAULT_SESSION"
fi
