# Docker credential helper borrowed by .zshrc. Keep it lean so stow can drop it into $ZSH_CONFIG_DIR.
DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/dotfiles}"
DOCKER_ENV_FILE="${DOCKER_ENV_FILE:-$DOTFILES_ROOT/.env.docker}"

if [[ -r "$DOCKER_ENV_FILE" ]]; then
  source "$DOCKER_ENV_FILE"
fi

# Run with the saved token so docker only needs one command from you.
docker-login() {
  if [[ -z "$DOCKER_USER" || -z "$DOCKER_TOKEN" ]]; then
    echo "Define DOCKER_USER and DOCKER_TOKEN in $DOCKER_ENV_FILE before logging in." >&2
    return 1
  fi

  printf '%s' "$DOCKER_TOKEN" | docker login --username "$DOCKER_USER" --password-stdin
}
