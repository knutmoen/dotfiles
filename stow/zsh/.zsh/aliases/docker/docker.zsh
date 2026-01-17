# ============================================================
# Entry point: load docker modules
# ============================================================

DOCKER_ZSH_DIR="${0:A:h}"

source "${DOCKER_ZSH_DIR}/docker.registry.zsh"
source "${DOCKER_ZSH_DIR}/docker.core.zsh"
source "${DOCKER_ZSH_DIR}/docker.compose.zsh"
source "${DOCKER_ZSH_DIR}/docker.desktop.zsh"
source "${DOCKER_ZSH_DIR}/docker.tools.zsh"
