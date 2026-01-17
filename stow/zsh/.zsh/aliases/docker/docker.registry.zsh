# ============================================================
# Registry + auto-generated help for docker.zsh modules
# ============================================================

: ${DOCKER_HELP_PAGER:=less}
: ${DOCKER_DANGER_CONFIRM:=1}

typeset -gA __D_DESC __D_USAGE __D_CAT
typeset -ga __D_KEYS

__dreg() {
  # __dreg <name> <category> <usage> <description>
  local name="$1" cat="$2" usage="$3" desc="$4"
  __D_CAT[$name]="$cat"
  __D_USAGE[$name]="$usage"
  __D_DESC[$name]="$desc"
  __D_KEYS+=("$name")
}

__dconfirm() {
  (( DOCKER_DANGER_CONFIRM )) || return 0
  local reply
  printf "⚠️  %s [y/N]: " "$1"
  read -r reply
  [[ "$reply" == "y" || "$reply" == "Y" ]]
}

__dhas() { command -v "$1" >/dev/null 2>&1; }

__dprint_help() {
  local -a cats
  cats=(
    "Status"
    "Containers"
    "Images"
    "Logs & Exec"
    "Build & Run"
    "Compose"
    "Networking"
    "Volumes"
    "System / Cleanup"
    "Desktop"
    "Tools"
  )

  {
    echo "🐳 Docker zsh — commands (auto-generated)"
    echo
    echo "Environment variables:"
    echo "  DOCKER_DANGER_CONFIRM=0      Disable confirmation prompts"
    echo "  DOCKER_HELP_PAGER=cat        Disable pager"
    echo
    echo "Tips:"
    echo "  dhelp <filter>               Filter by name/usage/description"
    echo

    local filter="${1:-}"
    local cat key printed hay
    for cat in "${cats[@]}"; do
      printed=0
      for key in "${__D_KEYS[@]}"; do
        [[ "${__D_CAT[$key]}" == "$cat" ]] || continue

        if [[ -n "$filter" ]]; then
          hay="${key} ${__D_USAGE[$key]} ${__D_DESC[$key]}"
          echo "$hay" | grep -qi -- "$filter" || continue
        fi

        if (( printed == 0 )); then
          echo "$cat"
          echo "  $(printf '%-12s %-20s %s' 'Command' 'Usage' 'Description')"
          printed=1
        fi
        printf "  %-12s %-20s %s\n" "$key" "${__D_USAGE[$key]}" "${__D_DESC[$key]}"
      done
      (( printed )) && echo
    done
  } | ${DOCKER_HELP_PAGER}
}

dhelp() { __dprint_help "${1:-}"; }
__dreg dhelp "Tools" "dhelp [filter]" "Show this help (auto-generated)"
