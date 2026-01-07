# -----------------------------------------------------------------------------
# Node.js via Volta
# -----------------------------------------------------------------------------

export VOLTA_HOME="${VOLTA_HOME:-$HOME/.volta}"
PATH="$VOLTA_HOME/bin:$PATH"

# -----------------------------------------------------------------------------
# Hjelpekommandoer
# -----------------------------------------------------------------------------

# Installer og sett global default (Volta gjør begge)
vinstall() {
  [[ -n "$1" ]] || { echo "Bruk: vinstall <versjon>   (eks: vinstall 20.12.2 eller vinstall lts)"; return 1; }
  volta install "node@$1"
}

# Alias for samme (tydelig navn)
vuse() {
  [[ -n "$1" ]] || { echo "Bruk: vuse <versjon>"; return 1; }
  volta install "node@$1"
}

# Pin per prosjekt (kjør i prosjektrot)
vpin() {
  [[ -n "$1" ]] || { echo "Bruk: vpin <versjon>   (kjør i prosjektet for å skrive til package.json/volta)"; return 1; }
  volta pin "node@$1"
}

# List installert/pinnet
vls() {
  volta list node
}
