# -----------------------------------------------------------------------------
# Common aliases (always loaded)
# -----------------------------------------------------------------------------

alias c='clear'
alias home='cd ~'

# Zsh helpers
alias zshsource='source ~/.zshrc'
alias zshconfig='code ~/.zshrc'
alias zshdir='cd ~/.zsh'
alias codezsh='code ~/.zsh'

# Dotfiles
alias dotfiles='cd ~/dotfiles'
alias confdotfiles='code ~/dotfiles'

port() {
  [[ -n "$1" ]] || { echo "Bruk: port <port>"; return 1; }
  lsof -nP -iTCP:"$1" -sTCP:LISTEN
}

# Kill processes on a given port
killport() {
  [[ -n "$1" ]] || { echo "Bruk: killport <port>"; return 1; }
  # Find PIDs listening on the port and kill them
  local pids
  pids=($(lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2>/dev/null))
  if [[ ${#pids[@]} -eq 0 ]]; then
    echo "Ingen prosesser funnet på port $1."
    return 0
  fi
  echo "Dreper: ${pids[*]}"
  kill "${pids[@]}"
}

actuator() {
  local base_url="${ACTUATOR_BASE_URL:-http://localhost:8081/actuator}"
  local endpoint="$1"

  local url="$base_url"
  if [[ -n "$endpoint" ]]; then
    url="$base_url/$endpoint"
  fi

  # curl med progress-bar (ikke -s)
  local response
  response=$(curl -w "\n%{http_code}" "$url")

  local body=$(echo "$response" | sed '$d')
  local http_status=$(echo "$response" | tail -n1)

  if [[ "$http_status" != "200" ]]; then
    echo "❌ HTTP $http_status from $url" >&2
    echo "$body" | jq
    return 1
  fi

  echo "$body" | jq
}


actuator-links() {
  curl -s http://localhost:8081/actuator \
    | jq -r '._links | keys[]'
}
