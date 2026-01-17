# ============================================================
# Docker Desktop (macOS)
# ============================================================

dstart() { open -a Docker; }
__dreg dstart "Desktop" "dstart" "Start Docker Desktop (macOS)"

docker-stop-all() {
  docker info >/dev/null 2>&1 || { echo "Docker is not running."; return 0; }
  local containers
  containers=$(docker ps -q)
  if [[ -z "$containers" ]]; then
    echo "No running containers."
  else
    echo "Stopping all running containers..."
    docker stop $containers
  fi
}

docker-desktop-stop() {
  echo "Stopping Docker Desktop..."
  osascript -e 'quit app "Docker"'
}

docker-stop-everything() {
  docker-stop-all
  docker-desktop-stop
}

alias dstop='docker-stop-all'
__dreg dstop "Desktop" "dstop" "Stop all running containers"

alias ddesk='docker-desktop-stop'
__dreg ddesk "Desktop" "ddesk" "Stop Docker Desktop (macOS)"

alias dstopall='docker-stop-everything'
__dreg dstopall "Desktop" "dstopall" "Stop containers + Docker Desktop"
