# -----------------------------------------------------------------------------
# Development tool aliases
# -----------------------------------------------------------------------------

# npm
alias rdev='npm run dev'
alias nst='npm start'
alias prt='npm run prettier'
alias nrt='npm run test'

# maven
alias mvnci='mvn clean install'
alias mvnist='mvn clean install -DskipTests'
alias mvncp='mvn clean package'
alias mvncc='mvn clean compile'
alias mvnt='mvn test'
alias mvnct='mvn clean test'
alias mvnc='mvn clean'
alias mvnd='mvn deploy'
alias mvns='mvn spring-boot:run'
alias mvnu='mvn clean install -U'
alias mvnver='mvn --version'
alias mvnfmt='mvn spotless:apply'
alias mvnsite='mvn site'
alias mvnverify='mvn verify'
alias mvnsh='mvn dependency:tree'
alias tmuxstatus='[ -n "$TMUX" ] && echo "i tmux" || echo "ikke i tmux"'
alias restkall="$HOME/dotfiles/scripts/rest-kall.sh"
kallrestlog() { ${EDITOR:-nvim} "${KALLREST_LOG:-$HOME/.cache/kallrest.log}"; }
kallrest() {
  setopt local_options no_nomatch  # allow URLs with ? and [] without glob errors
  local method="$1"; shift
  local url="$1"; shift
  local body=""
  local resp_file=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--data) body="$2"; shift 2;;
      -o|--output) resp_file="$2"; shift 2;;
      *) echo "Ukjent flagg: $1"; return 1;;
    esac
  done

  if [[ -z "$method" || -z "$url" ]]; then
    echo "Usage: kallrest <METHOD> <URL> [-d BODY] [-o RESP_FILE]"
    return 1
  fi

  local token_script="$HOME/dotfiles/scripts/rest-login-pkce-cache.sh"
  local token
  token="$("$token_script" | awk -F'"' '/export ACCESS_TOKEN/ {print $2}' | tail -n1)"
  if [[ -z "$token" ]]; then
    echo "❌ Fant ikke ACCESS_TOKEN fra $token_script"
    return 1
  fi

  echo "➡️  $method $url"
  if [[ -n "$body" ]]; then
    echo "Body: $body"
  fi

  local hdr bodyfile
  hdr=$(mktemp)
  bodyfile=$(mktemp)
  local start_ts end_ts
  if start_ts=$(date +%s%3N 2>/dev/null); then
    [[ $start_ts =~ ^[0-9]+$ ]] || start_ts=$(( $(date +%s) * 1000 ))
  else
    start_ts=$(( $(date +%s) * 1000 ))
  fi
  curl -s -D "$hdr" -o "$bodyfile" -X "$method" "$url" \
    -H "Authorization: Bearer $token" \
    -H "Accept: application/json" \
    ${body:+-d "$body"}
  if end_ts=$(date +%s%3N 2>/dev/null); then
    [[ $end_ts =~ ^[0-9]+$ ]] || end_ts=$(( $(date +%s) * 1000 ))
  else
    end_ts=$(( $(date +%s) * 1000 ))
  fi
  local duration_ms=$(( end_ts - start_ts ))
  echo "⏱️  ${duration_ms}ms"

  local log_file="${KALLREST_LOG:-$HOME/.cache/kallrest.log}"
  mkdir -p "$(dirname "$log_file")"
  local iso_ts
  if iso_ts=$(LC_ALL=C date -u "+%Y-%m-%dT%H:%M:%SZ" 2>/dev/null); then :; else iso_ts=$(date); fi
  {
    echo "[$iso_ts] $method $url (${duration_ms}ms)"
    cat "$hdr"
    echo
  } >>"$log_file"

  cat "$hdr"
  local ctype formatted
  ctype=$(grep -i '^Content-Type:' "$hdr" | tail -n1 | awk '{print $2}' | tr -d '\r')
  if [[ "$ctype" == application/json* && "$(command -v jq)" ]]; then
    formatted=$(jq . "$bodyfile" 2>/dev/null || cat "$bodyfile")
  else
    formatted=$(cat "$bodyfile")
  fi

  if [[ -n "$resp_file" ]]; then
    echo "$formatted" >"$resp_file"
    echo "↳ Response written to $resp_file"
  fi
  echo "$formatted"
  rm -f "$hdr" "$bodyfile"
}

# misc dev
alias loc="npx sloc --format cli-table --format-option head --exclude 'build|\\.svg$\\.xml' ./"
