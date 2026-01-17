# ============================================================
# Tools / workflows
# ============================================================

: ${DOCKER_JSONCOMPARE_DOCKER_TIMEOUT:=60}
: ${DOCKER_JSONCOMPARE_CONTAINER_TIMEOUT:=20}

jsoncompare() {
  set -euo pipefail

  local CONTAINER_NAME="jdd"
  local IMAGE="zgrossbart/jsondiff"
  local PORT="8080"
  local URL="http://localhost:${PORT}"
  local DOCKER_TIMEOUT="${DOCKER_JSONCOMPARE_DOCKER_TIMEOUT}"
  local CONTAINER_TIMEOUT="${DOCKER_JSONCOMPARE_CONTAINER_TIMEOUT}"
  local SLEEP=2

  __dhas curl || { echo "❌ curl is required for health checks"; return 1; }

  log() { echo "▶ $1"; }
  fail() { echo "❌ $1" >&2; return 1; }

  wait_for_docker() {
    local elapsed=0
    until docker info >/dev/null 2>&1; do
      (( elapsed >= DOCKER_TIMEOUT )) && fail "Docker did not start within ${DOCKER_TIMEOUT}s"
      sleep $SLEEP
      (( elapsed += SLEEP ))
    done
  }

  wait_for_container() {
    local elapsed=0
    until curl -fs "http://localhost:${PORT}" >/dev/null 2>&1; do
      (( elapsed >= CONTAINER_TIMEOUT )) && fail "Container did not respond within ${CONTAINER_TIMEOUT}s"
      sleep $SLEEP
      (( elapsed += SLEEP ))
    done
  }

  if ! docker info >/dev/null 2>&1; then
    log "Docker is not running — starting Docker Desktop"
    open -a Docker
    log "Waiting for Docker (timeout ${DOCKER_TIMEOUT}s)"
    wait_for_docker
  fi

  log "Docker is ready"
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

  log "Starting jsondiff container"
  docker run -d \
    --platform=linux/amd64 \
    --name "$CONTAINER_NAME" \
    --rm \
    -p ${PORT}:80 \
    "$IMAGE" >/dev/null

  log "Waiting for container (timeout ${CONTAINER_TIMEOUT}s)"
  wait_for_container

  log "Opening in Brave"
  open -a "Brave Browser" "$URL"
}
__dreg jsoncompare "Tools" "jsoncompare" "Start Docker + jsondiff + open in Brave"
