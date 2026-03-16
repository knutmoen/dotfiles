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
    dev)      [[ -n "$BACKEND_DIR"  ]] && start_dir="$BACKEND_DIR" ;;
    commands) [[ -n "$COMMANDS_DIR" ]] && start_dir="$COMMANDS_DIR" ;;
  esac

  if tmux has-session -t "$session" 2>/dev/null; then
    tmux attach -t "$session"
  else
    tmux new -s "$session" -c "$start_dir"
  fi
}

# Bootstrap sessions with pane layouts
#
# commands: ett pane for generelle kommandoer
# dev:      ai cli  (venstre) | api (høyre oppe) / web (høyre nede)
#
#  commands        dev
#  ┌──────────┐   ┌──────────┬──────────┐
#  │          │   │          │   api    │
#  │ commands │   │  ai cli  ├──────────┤
#  │          │   │          │   web    │
#  └──────────┘   └──────────┴──────────┘
tboot() {
  tmux start-server

  # commands: enkelt pane
  if ! tmux has-session -t commands 2>/dev/null; then
    tmux new-session -d -s commands -c "${COMMANDS_DIR:-$HOME}"
  fi

  # dev: api | web-client / web-cmds
  if ! tmux has-session -t dev 2>/dev/null; then
    tmux new-session  -d -s dev -c "${BACKEND_DIR:-$HOME}"       # pane: api
    tmux split-window -h -t dev -c "${FRONTEND_DIR:-$HOME}"      # pane: web-client (høyre)
    tmux split-window -v -t dev -c "${FRONTEND_DIR:-$HOME}"      # pane: web-cmds (under web-client)
    tmux select-pane  -t dev:1.1                                   # fokus: api
  fi
}

# -----------------------------------------------------------------------------
# Multi-project support
#
# Registrer prosjekter i ~/.zshrc:
#   tmux_project myapp  "$HOME/projects/myapp/api"  "$HOME/projects/myapp/web" "$HOME/projects/myapp/cli"
#   tmux_project otherapp "$HOME/projects/other/server" "$HOME/projects/other/client" "$HOME/projects/other/cli"
#
# Bruk:
#   tp            → list alle registrerte prosjekter
#   tp myapp      → opprett eller bytt til prosjektets session
#
# Hvert prosjekt får en egen navngitt session med layouten:
#   ai cli (venstre) | api (høyre oppe) / web (høyre nede)
# -----------------------------------------------------------------------------

typeset -gA _TMUX_PROJECT_BACKEND
typeset -gA _TMUX_PROJECT_FRONTEND

typeset -gA _TMUX_PROJECT_AICLI

# tmux_project <navn> <backend-dir> <frontend-dir> [ai cli-dir]
# ai cli-dir er valgfri; faller tilbake til backend-dir hvis ikke oppgitt.
tmux_project() {
  local name="$1" backend="$2" frontend="$3" aicli="${4:-$2}"
  _TMUX_PROJECT_BACKEND[$name]="$backend"
  _TMUX_PROJECT_FRONTEND[$name]="$frontend"
  _TMUX_PROJECT_AICLI[$name]="$aicli"
}

tp() {
  local project="${1:-}"

  if [[ -z "$project" ]]; then
    if [[ ${#_TMUX_PROJECT_BACKEND} -eq 0 ]]; then
      echo "Ingen prosjekter registrert. Legg til i ~/.zshrc:"
      echo "  tmux_project <navn> <backend-dir> <frontend-dir>"
    else
      echo "Tilgjengelige prosjekter:"
      for p in "${(@k)_TMUX_PROJECT_BACKEND}"; do
        echo "  $p"
        echo "    api:     ${_TMUX_PROJECT_BACKEND[$p]}"
        echo "    web:     ${_TMUX_PROJECT_FRONTEND[$p]}"
      done
    fi
    return
  fi

  local backend="${_TMUX_PROJECT_BACKEND[$project]}"
  local frontend="${_TMUX_PROJECT_FRONTEND[$project]}"
  local aicli="${_TMUX_PROJECT_AICLI[$project]}"

  if [[ -z "$backend" ]]; then
    echo "Ukjent prosjekt: '$project'. Kjør 'tp' for å se tilgjengelige."
    return 1
  fi

  if tmux has-session -t "$project" 2>/dev/null; then
    if [[ -n "$TMUX" ]]; then
      tmux switch-client -t "$project"
    else
      tmux attach -t "$project"
    fi
  else
    tmux new-session  -d -s "$project" -c "$aicli"    # pane: ai cli
    tmux split-window -h -t "$project" -c "$backend"   # pane: api
    tmux split-window -v -t "$project" -c "$frontend"  # pane: web
    tmux select-pane  -t "${project}:1.1"
    if [[ -n "$TMUX" ]]; then
      tmux switch-client -t "$project"
    else
      tmux attach -t "$project"
    fi
  fi
}

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
