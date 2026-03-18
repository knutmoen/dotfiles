# -----------------------------------------------------------------------------
# Node.js and npm via Volta
# -----------------------------------------------------------------------------

export VOLTA_HOME="${VOLTA_HOME:-$HOME/.volta}"
PATH="$VOLTA_HOME/bin:$PATH"

# -----------------------------------------------------------------------------
# Felles Volta-hjelpere
# -----------------------------------------------------------------------------

_volta_install_tool() {
  local tool="$1"
  local version="$2"
  local usage="$3"
  local example="$4"

  [[ -n "$version" ]] || { echo "Bruk: $usage   (eks: $example)"; return 1; }
  volta install "${tool}@${version}"
}

_volta_pin_tool() {
  local tool="$1"
  local version="$2"
  local usage="$3"

  [[ -n "$version" ]] || { echo "Bruk: $usage   (kjør i prosjektet for å skrive til package.json/volta)"; return 1; }
  volta pin "${tool}@${version}"
}

_volta_list_tool() {
  local tool="$1"
  volta list "$tool"
}

# -----------------------------------------------------------------------------
# Node.js via Volta
# -----------------------------------------------------------------------------

node_install() {
  _volta_install_tool node "$1" "node_install <versjon>" "20.12.2 eller lts"
}

node_use() {
  node_install "$1"
}

node_pin() {
  _volta_pin_tool node "$1" "node_pin <versjon>"
}

node_ls() {
  _volta_list_tool node
}

# -----------------------------------------------------------------------------
# npm via Volta
# -----------------------------------------------------------------------------

npm_install() {
  _volta_install_tool npm "$1" "npm_install <versjon>" "10.9.2 eller latest"
}

npm_use() {
  npm_install "$1"
}

npm_pin() {
  _volta_pin_tool npm "$1" "npm_pin <versjon>"
}

npm_ls() {
  _volta_list_tool npm
}

# -----------------------------------------------------------------------------
# Bakoverkompatibilitet
# -----------------------------------------------------------------------------

vinstall() { node_install "$@"; }
vuse() { node_use "$@"; }
vpin() { node_pin "$@"; }
vls() { node_ls "$@"; }

ninstall() { npm_install "$@"; }
nuse() { npm_use "$@"; }
npin() { npm_pin "$@"; }
nls() { npm_ls "$@"; }
