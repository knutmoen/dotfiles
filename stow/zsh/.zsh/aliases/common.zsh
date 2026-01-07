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
